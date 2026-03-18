import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
import 'dart:async';
import '../models/task_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final _client = Supabase.instance.client;

  // ─── Manual broadcast stream (no dependency on Supabase Realtime) ───
  final _tasksController = StreamController<List<Task>>.broadcast();
  List<Task> _cachedTasks = [];
  bool _initialized = false;

  Stream<List<Task>> getTasksStream() {
    if (!_initialized) {
      _initialized = true;
      refreshTasks();
    }
    // Emit the cached data immediately for new listeners
    Future.microtask(() {
      if (_cachedTasks.isNotEmpty) {
        _tasksController.add(_cachedTasks);
      }
    });
    return _tasksController.stream;
  }

  Future<void> refreshTasks() async {
    try {
      final response = await _client
          .from('tasks')
          .select()
          .order('created_at', ascending: false);

      _cachedTasks =
          (response as List).map((json) => Task.fromJson(json)).toList();
      _tasksController.add(_cachedTasks);
    } catch (e) {
      _tasksController.addError(e);
    }
  }

  Future<List<Task>> getTasks() async {
    final response = await _client
        .from('tasks')
        .select()
        .order('created_at', ascending: false);

    return (response as List).map((json) => Task.fromJson(json)).toList();
  }

  Future<List<Task>> getTodayTasks() async {
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final response = await _client
        .from('tasks')
        .select()
        .eq('scheduled_date', today)
        .order('scheduled_time', ascending: true);

    return (response as List).map((json) => Task.fromJson(json)).toList();
  }

  /// Creates a task and returns the created record (with its ID)
  Future<Task> addTask(Task task) async {
    final response =
        await _client.from('tasks').insert(task.toJson()).select().single();
    final createdTask = Task.fromJson(response);
    await refreshTasks();
    return createdTask;
  }

  Future<void> toggleComplete(String id, bool status) async {
    await _client.from('tasks').update({'is_completed': status}).eq('id', id);
    // Optimistic local update for instant UI feedback
    _cachedTasks = _cachedTasks.map((t) {
      if (t.id == id) return t.copyWith(isCompleted: status);
      return t;
    }).toList();
    _tasksController.add(_cachedTasks);
    // Also refresh from server to stay in sync
    refreshTasks();
  }

  Future<void> deleteTask(String id) async {
    await _client.from('tasks').delete().eq('id', id);
    // Optimistic local update
    _cachedTasks = _cachedTasks.where((t) => t.id != id).toList();
    _tasksController.add(_cachedTasks);
    refreshTasks();
  }

  Future<Map<String, int>> getStats() async {
    final response = await _client.from('tasks').select('is_completed');
    final tasks = response as List;

    int completed = tasks.where((t) => t['is_completed'] == true).length;
    int pending = tasks.where((t) => t['is_completed'] == false).length;

    return {
      'completed': completed,
      'pending': pending,
      'total': tasks.length,
    };
  }

  // ─── File Attachments ───

  Future<String> uploadFile(String taskId, File file) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}';
    final storagePath = '$taskId/$fileName';

    await _client.storage.from('task-attachments').upload(storagePath, file);

    final publicUrl =
        _client.storage.from('task-attachments').getPublicUrl(storagePath);

    return publicUrl;
  }

  Future<void> deleteFile(String storagePath) async {
    await _client.storage.from('task-attachments').remove([storagePath]);
  }

  Future<void> updateTaskAttachments(
      String taskId, List<TaskAttachment> attachments) async {
    await _client.from('tasks').update({
      'attachments': attachments.map((a) => a.toJson()).toList(),
    }).eq('id', taskId);
    await refreshTasks();
  }
}