import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
// ignore: unused_import
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  bool _isLoading = true;
  TaskCategory? _selectedCategory;
  TaskPriority? _selectedPriority;
  bool _showCompleted = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tasks = await TaskService.getTasks();
      setState(() {
        _tasks = tasks;
        _filterTasks();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading tasks: $e')));
      }
    }
  }

  void _filterTasks() {
    _filteredTasks = _tasks.where((task) {
      bool matchesCategory =
          _selectedCategory == null || task.category == _selectedCategory;
      bool matchesPriority =
          _selectedPriority == null || task.priority == _selectedPriority;
      bool matchesCompletion = _showCompleted || !task.isCompleted;
      bool matchesSearch =
          _searchQuery.isEmpty ||
          task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesCategory &&
          matchesPriority &&
          matchesCompletion &&
          matchesSearch;
    }).toList();

    // Sort tasks: incomplete first, then by priority, then by due date
    _filteredTasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      if (a.priority != b.priority) {
        return b.priority.index.compareTo(a.priority.index);
      }
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      return a.createdAt.compareTo(b.createdAt);
    });
  }

  Future<void> _toggleTaskCompletion(String taskId) async {
    try {
      await TaskService.toggleTaskCompletion(taskId);
      await _loadTasks();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task updated successfully'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating task: $e')));
      }
    }
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      await TaskService.deleteTask(taskId);
      await _loadTasks();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task deleted successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting task: $e')));
      }
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Filter Tasks'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: _selectedCategory == null,
                          onSelected: (selected) {
                            setStateDialog(() {
                              _selectedCategory = selected
                                  ? null
                                  : _selectedCategory;
                            });
                          },
                        ),
                        ...TaskCategory.values.map(
                          (category) => Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: FilterChip(
                              label: Text(category.name.toUpperCase()),
                              selected: _selectedCategory == category,
                              onSelected: (selected) {
                                setStateDialog(() {
                                  _selectedCategory = selected
                                      ? category
                                      : null;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Priority:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: _selectedPriority == null,
                          onSelected: (selected) {
                            setStateDialog(() {
                              _selectedPriority = selected
                                  ? null
                                  : _selectedPriority;
                            });
                          },
                        ),
                        ...TaskPriority.values.map(
                          (priority) => Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: FilterChip(
                              label: Text(priority.name.toUpperCase()),
                              selected: _selectedPriority == priority,
                              onSelected: (selected) {
                                setStateDialog(() {
                                  _selectedPriority = selected
                                      ? priority
                                      : null;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Show Completed Tasks'),
                      value: _showCompleted,
                      onChanged: (value) {
                        setStateDialog(() {
                          _showCompleted = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _filterTasks();
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'My Tasks',
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
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterDialog,
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadTasks,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _filterTasks();
                  });
                },
              ),
            ),
          ),
          _isLoading
              ? const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              : _filteredTasks.isEmpty
              ? SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 64,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _tasks.isEmpty
                                ? 'No tasks yet!'
                                : 'No tasks match your filters',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _tasks.isEmpty
                                ? 'Tap the + button to create your first task'
                                : 'Try adjusting your filters',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final task = _filteredTasks[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                      child: Slidable(
                        key: Key(task.id),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) => _toggleTaskCompletion(task.id),
                              backgroundColor: task.isCompleted
                                  ? Colors.orange
                                  : Colors.green,
                              foregroundColor: Colors.white,
                              icon: task.isCompleted ? Icons.undo : Icons.check,
                              label: task.isCompleted ? 'Undo' : 'Complete',
                            ),
                            SlidableAction(
                              onPressed: (_) => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddTaskScreen(taskToEdit: task),
                                ),
                              ),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'Edit',
                            ),
                            SlidableAction(
                              onPressed: (_) => _deleteTask(task.id),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: TaskCard(
                          task: task,
                          onToggleCompletion: () =>
                              _toggleTaskCompletion(task.id),
                          onEdit: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddTaskScreen(taskToEdit: task),
                            ),
                          ),
                        ),
                      ),
                    );
                  }, childCount: _filteredTasks.length),
                ),
        ],
      ),
    );
  }
}
