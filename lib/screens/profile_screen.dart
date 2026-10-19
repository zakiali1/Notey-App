import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/theme_provider.dart';
import '../services/task_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'Task Master';
  bool _notificationsEnabled = true;
  int _totalCompletedTasks = 0;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadStats();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Task Master';
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  Future<void> _loadStats() async {
    final stats = await TaskService.getTaskStats();
    setState(() {
      _totalCompletedTasks = stats['totalCompletedAllTime'] ?? 0;
    });
  }

  Future<void> _saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    setState(() {
      _userName = name;
    });
  }

  Future<void> _saveNotificationPreference(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', enabled);
    setState(() {
      _notificationsEnabled = enabled;
    });
  }

  void _showEditNameDialog() {
    final controller = TextEditingController(text: _userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Your Name',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _saveUserName(controller.text.trim());
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your tasks and reset your statistics. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('tasks');
                await prefs.remove('completed_tasks_count');

                setState(() {
                  _totalCompletedTasks = 0;
                });

                if (!mounted) return;
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('All data cleared successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Error clearing data: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All Data'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Profile',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(
                        _userName.isNotEmpty ? _userName[0].toUpperCase() : 'T',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _userName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$_totalCompletedTasks tasks completed',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  _buildSectionTitle('Profile'),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text('Name'),
                          subtitle: Text(_userName),
                          trailing: const Icon(Icons.edit),
                          onTap: _showEditNameDialog,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // App Settings Section
                  _buildSectionTitle('App Settings'),
                  Card(
                    child: Column(
                      children: [
                        SwitchListTile(
                          secondary: const Icon(Icons.dark_mode),
                          title: const Text('Dark Mode'),
                          subtitle: const Text('Toggle dark/light theme'),
                          value: themeProvider?.isDarkMode ?? false,
                          onChanged: (value) {
                            themeProvider?.toggleTheme();
                          },
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          secondary: const Icon(Icons.notifications),
                          title: const Text('Notifications'),
                          subtitle: const Text('Receive task reminders'),
                          value: _notificationsEnabled,
                          onChanged: _saveNotificationPreference,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Statistics Section
                  _buildSectionTitle('Statistics'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.emoji_events,
                                  size: 32,
                                  color: Colors.amber,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$_totalCompletedTasks',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                                Text(
                                  'Tasks Completed',
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // About Section
                  _buildSectionTitle('About'),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.info),
                          title: const Text('About TaskMaster'),
                          subtitle: const Text('Version 1.0.0'),
                          onTap: () {
                            showAboutDialog(
                              context: context,
                              applicationName: 'TaskMaster',
                              applicationVersion: '1.0.0',
                              applicationIcon: const Icon(Icons.task_alt, size: 48),
                              children: const [
                                Text('A comprehensive task management app built with Flutter.'),
                              ],
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.help),
                          title: const Text('Help & Support'),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Help & Support'),
                                content: const SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Getting Started:',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text('• Tap the + button to create your first task'),
                                      Text('• Swipe tasks left to access quick actions'),
                                      Text('• Use filters to organize your view'),
                                      SizedBox(height: 16),
                                      Text(
                                        'Features:',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text('• Set due dates and priorities'),
                                      Text('• Organize tasks by category'),
                                      Text('• View detailed analytics'),
                                      Text('• Switch between light/dark themes'),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Got it!'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Data Management Section
                  _buildSectionTitle('Data Management'),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.delete_sweep, color: Colors.red),
                          title: Text(
                            'Clear All Data',
                            style: TextStyle(color: Colors.red),
                          ),
                          subtitle: const Text('Remove all tasks and reset statistics'),
                          onTap: _showClearDataDialog,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}