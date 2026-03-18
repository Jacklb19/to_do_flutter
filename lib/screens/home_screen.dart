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
        child: StreamBuilder<List<Task>>(
          stream: _supabaseService.getTasksStream(),
          builder: (context, snapshot) {
            final tasks = snapshot.data ?? [];
            final completedCount = tasks.where((t) => t.isCompleted).length;
            final pendingCount = tasks.length - completedCount;
            final progress =
                tasks.isEmpty ? 0.0 : completedCount / tasks.length;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Circular Progress Card ───
                  CircularProgressCard(
                    progress: progress,
                    title: "Weekly Tasks",
                    completedTasks: completedCount,
                    pendingTasks: pendingCount,
                  ),

                  const SizedBox(height: 28),

                  // ─── "Today Tasks" header + count ───
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
                      Text(
                        "$completedCount of ${tasks.length}",
                        style: const TextStyle(
                          color: AppColors.greyText,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ─── Linear progress bar ───
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ─── Task list ───
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary),
                      ),
                    )
                  else if (tasks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.check_circle_outline,
                                size: 64,
                                color: AppColors.greyText.withValues(alpha: 0.5)),
                            const SizedBox(height: 12),
                            const Text(
                              "No tasks yet",
                              style: TextStyle(
                                color: AppColors.greyText,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return TaskCard(
                          task: task,
                          onToggle: (val) => _supabaseService.toggleComplete(
                              task.id!, val ?? false),
                          onDelete: () =>
                              _supabaseService.deleteTask(task.id!),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
