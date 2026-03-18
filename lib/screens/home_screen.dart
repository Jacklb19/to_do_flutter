import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../core/supabase_service.dart';
import '../models/task_model.dart';
import '../widgets/task_card.dart';
import '../widgets/circular_progress_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<List<Task>>(
                stream: _supabaseService.getTasksStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressCard(
                      progress: 0.0,
                      title: "Loading...",
                      completedTasks: 0,
                      pendingTasks: 0,
                    );
                  }
                  
                  final tasks = snapshot.data ?? [];
                  final completedCount = tasks.where((t) => t.isCompleted).length;
                  final pendingCount = tasks.length - completedCount;
                  final progress = tasks.isEmpty ? 0.0 : completedCount / tasks.length;
                  
                  return CircularProgressCard(
                    progress: progress,
                    title: "Weekly Tasks",
                    completedTasks: completedCount,
                    pendingTasks: pendingCount,
                  );
                },
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Today Tasks",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  StreamBuilder<List<Task>>(
                    stream: _supabaseService.getTasksStream(),
                    builder: (context, snapshot) {
                      final tasks = snapshot.data ?? [];
                      final completed = tasks.where((t) => t.isCompleted).length;
                      return Text(
                        "$completed of ${tasks.length}",
                        style: const TextStyle(
                          color: AppColors.greyText,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<Task>>(
                stream: _supabaseService.getTasksStream(),
                builder: (context, snapshot) {
                  final tasks = snapshot.data ?? [];
                  final progress = tasks.isEmpty ? 0.0 : tasks.where((t) => t.isCompleted).length / tasks.length;
                  
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              StreamBuilder<List<Task>>(
                stream: _supabaseService.getTasksStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  
                  final tasks = snapshot.data ?? [];
                  if (tasks.isEmpty) {
                    return const Center(child: Text("No tasks for today"));
                  }
                  
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskCard(
                        task: task,
                        onToggle: (val) => _supabaseService.toggleComplete(task.id!, val ?? false),
                        onDelete: () => _supabaseService.deleteTask(task.id!),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
