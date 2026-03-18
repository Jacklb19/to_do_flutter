import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
import '../models/task_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final _client = Supabase.instance.client;

  // ─── Cached stream (single source of truth) ───
  Stream<List<Task>>? _tasksStream;

  Stream<List<Task>> getTasksStream() {
    _tasksStream ??= _client
        .from('tasks')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => Task.fromJson(json)).toList());
    return _tasksStream!;
  }

  /// Forces a fresh stream (call after add/update/delete to guarantee refresh)
  void invalidateStream() {
    _tasksStream = null;
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

  Future<void> addTask(Task task) async {
    await _client.from('tasks').insert(task.toJson());
    invalidateStream();
  }

  Future<void> toggleComplete(String id, bool status) async {
    await _client.from('tasks').update({'is_completed': status}).eq('id', id);
  }

  Future<void> deleteTask(String id) async {
    await _client.from('tasks').delete().eq('id', id);
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
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}';
    final storagePath = '$taskId/$fileName';

    await _client.storage
        .from('task-attachments')
        .upload(storagePath, file);

    final publicUrl = _client.storage
        .from('task-attachments')
        .getPublicUrl(storagePath);

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
  }
}
