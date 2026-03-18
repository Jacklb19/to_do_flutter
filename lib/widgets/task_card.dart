import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../models/task_model.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Function(bool?) onToggle;
  final Function() onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isMorning = task.scheduledTime != null && task.scheduledTime!.hour < 12;

    return Dismissible(
      key: Key(task.id ?? task.title),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.accentRed,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular checkbox
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onToggle(!task.isCompleted),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: task.isCompleted
                      ? AppColors.lightGreen
                      : Colors.transparent,
                  border: Border.all(
                    color: task.isCompleted
                        ? Colors.transparent
                        : AppColors.borderGrey,
                    width: 2,
                  ),
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check, color: AppColors.primary, size: 18)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            // Title — NO strikethrough, just normal text
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: task.isCompleted
                      ? AppColors.greyText
                      : AppColors.textDark,
                ),
              ),
            ),
            // Time badge
            if (task.scheduledTime != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isMorning ? AppColors.timeChipBg : AppColors.timeChipBgAfternoon,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _formatTime(task.scheduledTime!),
                  style: TextStyle(
                    color: isMorning ? AppColors.timeChipTextMorning : AppColors.timeChipTextAfternoon,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            // Attachment indicator
            if (task.attachments.isNotEmpty) ...[
              const SizedBox(width: 8),
              const Icon(Icons.attach_file, size: 16, color: AppColors.greyText),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour == 0 || time.hour == 12 ? 12 : time.hour % 12;
    final amPm = time.hour < 12 ? 'A.M' : 'P.M';
    return '$hour $amPm';
  }
}
