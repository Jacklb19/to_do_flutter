import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../core/supabase_service.dart';
import '../models/task_model.dart';
import '../widgets/task_card.dart';
import '../widgets/category_chip.dart';

class AllTasksScreen extends StatefulWidget {
  const AllTasksScreen({super.key});

  @override
  State<AllTasksScreen> createState() => _AllTasksScreenState();
}

class _AllTasksScreenState extends State<AllTasksScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  String _selectedCategory = 'All';
  
  final List<String> _categories = [
    'All', 'Healthy', 'Design', 'Job', 'Education', 'Sport'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyLight,
      appBar: AppBar(
        title: const Text("All Tasks", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: _categories.map((cat) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CategoryChip(
                  label: cat,
                  isSelected: _selectedCategory == cat,
                  onSelected: () => setState(() => _selectedCategory = cat),
                ),
              )).toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: _supabaseService.getTasksStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                
                var tasks = snapshot.data ?? [];
                if (_selectedCategory != 'All') {
                  tasks = tasks.where((t) => t.category == _selectedCategory).toList();
                }
                
                if (tasks.isEmpty) {
                  return const Center(child: Text("No tasks found"));
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
          ),
        ],
      ),
    );
  }
}
