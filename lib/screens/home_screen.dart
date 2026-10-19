import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'tasks_screen.dart';
import 'add_task_screen.dart';
import 'analytics_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabAnimationController;
  late AnimationController _borderRadiusAnimationController;
  late Animation<double> _fabAnimation;
  // ignore: unused_field
  late Animation<double> _borderRadiusAnimation;
  late CurvedAnimation _fabCurve;
  late CurvedAnimation _borderRadiusCurve;

  final List<IconData> iconList = [
    Icons.task_alt,
    Icons.analytics,
    Icons.person,
  ];

  final List<String> titleList = ['Tasks', 'Analytics', 'Profile'];

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      const TasksScreen(),
      const AnalyticsScreen(),
      const ProfileScreen(),
    ];

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _borderRadiusAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fabCurve = CurvedAnimation(
      parent: _fabAnimationController,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );
    _borderRadiusCurve = CurvedAnimation(
      parent: _borderRadiusAnimationController,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );

    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(_fabCurve);
    _borderRadiusAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_borderRadiusCurve);

    _fabAnimationController.forward();
    _borderRadiusAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _borderRadiusAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddTaskScreen()),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: iconList.length,
        tabBuilder: (int index, bool isActive) {
          final color = isActive
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant;
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(iconList[index], size: 24, color: color),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  titleList[index],
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
        backgroundColor: Theme.of(context).colorScheme.surface,
        activeIndex: _currentIndex,
        splashColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        notchSmoothness: NotchSmoothness.softEdge,
        leftCornerRadius: 32,
        rightCornerRadius: 0,
        onTap: (index) => setState(() => _currentIndex = index),
        hideAnimationController: _borderRadiusAnimationController,
        shadow: BoxShadow(
          offset: const Offset(0, 1),
          blurRadius: 12,
          color: Colors.black.withValues(alpha: 0.1),
        ),
      ),
    );
  }
}
