import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/colors.dart';
import '../core/supabase_service.dart';
import '../models/task_model.dart';
import '../widgets/circular_progress_card.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SupabaseService supabaseService = SupabaseService();

    return Scaffold(
      backgroundColor: AppColors.greyLight,
      appBar: AppBar(
        title: const Text(
          "My Statistics",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<List<Task>>(
        stream: supabaseService.getTasksStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          final tasks = snapshot.data ?? [];
          final completed = tasks.where((t) => t.isCompleted).length;
          final pending = tasks.length - completed;
          final progress = tasks.isEmpty ? 0.0 : completed / tasks.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircularProgressCard(
                  progress: progress,
                  title: "Overall Progress",
                  completedTasks: completed,
                  pendingTasks: pending,
                  isLarge: true,
                ),
                const SizedBox(height: 28),
                const Text(
                  "Weekly Overview",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _getMaxY(tasks),
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const days = [
                                'M', 'T', 'W', 'T', 'F', 'S', 'S'
                              ];
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  days[value.toInt()],
                                  style: const TextStyle(
                                    color: AppColors.greyText,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: _generateBarGroups(tasks),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                        child: _buildStatMiniCard(
                            "Completed", completed, Icons.check_circle_outline)),
                    const SizedBox(width: 14),
                    Expanded(
                        child: _buildStatMiniCard(
                            "In Progress", pending, Icons.timer_outlined)),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: _buildStatMiniCard(
                      "Total Tasks", tasks.length, Icons.assignment_outlined),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  double _getMaxY(List<Task> tasks) {
    int max = 0;
    for (var count in _getCompletedPerDay(tasks)) {
      if (count > max) max = count;
    }
    return max > 10 ? max.toDouble() : 10;
  }

  List<int> _getCompletedPerDay(List<Task> tasks) {
    List<int> completedPerDay = List.filled(7, 0);
    final now = DateTime.now();
    // Start of current week (Monday)
    final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    for (var task in tasks) {
      if (task.isCompleted && task.scheduledDate != null) {
        final date = task.scheduledDate!;
        final taskDate = DateTime(date.year, date.month, date.day);
        if (taskDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
            taskDate.isBefore(endOfWeek.add(const Duration(days: 1)))) {
           final dayIndex = date.weekday - 1; // 1 (Mon) -> 0, 7 (Sun) -> 6
           if (dayIndex >= 0 && dayIndex < 7) {
             completedPerDay[dayIndex]++;
           }
        }
      }
    }
    return completedPerDay;
  }

  List<BarChartGroupData> _generateBarGroups(List<Task> tasks) {
    final completedPerDay = _getCompletedPerDay(tasks);
    final todayIndex = DateTime.now().weekday - 1;

    return List.generate(7, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: completedPerDay[i].toDouble(),
            color: i == todayIndex
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.3),
            width: 14,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(8)),
          ),
        ],
      );
    });
  }

  Widget _buildStatMiniCard(String title, int count, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 10),
          Text(
            "$count",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.greyText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
