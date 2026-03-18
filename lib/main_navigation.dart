import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/all_tasks_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/add_task_screen.dart';
import 'widgets/bottom_nav_bar.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AllTasksScreen(),
    const StatsScreen(),
    const AddTaskScreen(), // This is just a placeholder for the index, we'll navigate to it
  ];

  void _onTap(int index) {
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddTaskScreen()),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens.sublist(0, 3), // Only stack the first 3 screens
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
