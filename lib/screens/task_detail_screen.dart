import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/colors.dart';
import '../models/task_model.dart';
import '../core/supabase_service.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  Widget _getFileIcon(String extension) {
    IconData iconData;
    switch (extension.toLowerCase()) {
      case 'pdf':
        iconData = Icons.picture_as_pdf;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        iconData = Icons.image_outlined;
        break;
      case 'doc':
      case 'docx':
        iconData = Icons.description_outlined;
        break;
      case 'xls':
      case 'xlsx':
        iconData = Icons.table_chart_outlined;
        break;
      default:
        iconData = Icons.attach_file;
    }
    return Icon(iconData, color: AppColors.primary, size: 28);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.accentRed),
            onPressed: () async {
              if (task.id != null) {
                await SupabaseService().deleteTask(task.id!);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
          ),
        ],
        title: const Text(
          "Task Details",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category & Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    task.category ?? 'Uncategorized',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (task.scheduledDate != null)
                  Text(
                    DateFormat('MMM dd, yyyy').format(task.scheduledDate!),
                    style: const TextStyle(
                      color: AppColors.greyText,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            // Description
            if (task.description != null && task.description!.isNotEmpty) ...[
              const Text(
                "Description",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                task.description!,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.greyText,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
            ],
            // Files / Attachments
            if (task.attachments.isNotEmpty) ...[
              const Text(
                "Attachments",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              ...task.attachments.map((attachment) {
                final isImage = ['jpg', 'jpeg', 'png', 'gif']
                    .contains(attachment.type.toLowerCase());
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _getFileIcon(attachment.type),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              attachment.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (isImage) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            attachment.url,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              height: 100,
                              color: AppColors.greyLight,
                              child: const Center(
                                child: Icon(Icons.broken_image_outlined,
                                    color: AppColors.greyText),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
