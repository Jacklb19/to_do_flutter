import 'package:flutter/material.dart';
import '../core/colors.dart';

class CircularProgressCard extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String title;
  final int completedTasks;
  final int pendingTasks;
  final bool isLarge;

  const CircularProgressCard({
    super.key,
    required this.progress,
    required this.title,
    required this.completedTasks,
    required this.pendingTasks,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final double circleSize = isLarge ? 100 : 80;
    final double strokeWidth = isLarge ? 10 : 8;
    final double fontSize = isLarge ? 20 : 16;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular progress indicator
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: circleSize,
                height: circleSize,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: strokeWidth,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          // Right side content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward,
                        size: 18, color: AppColors.textDark),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildBadge(
                      '$completedTasks',
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    _buildBadge(
                      '$pendingTasks',
                      AppColors.accentRed.withValues(alpha: 0.1),
                      AppColors.accentRed,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
