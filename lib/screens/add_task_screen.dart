import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? taskToEdit;

  const AddTaskScreen({super.key, this.taskToEdit});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  TaskPriority _selectedPriority = TaskPriority.medium;
  TaskCategory _selectedCategory = TaskCategory.personal;
  DateTime? _selectedDueDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      _initializeWithExistingTask();
    }
  }

  void _initializeWithExistingTask() {
    final task = widget.taskToEdit!;
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _selectedPriority = task.priority;
    _selectedCategory = task.category;
    _selectedDueDate = task.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final stateContext = context;
    if (!stateContext.mounted) return;

    final DateTime? picked = await showDatePicker(
      context: stateContext,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (!stateContext.mounted) return;

    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: stateContext,
        initialTime: TimeOfDay.fromDateTime(_selectedDueDate ?? DateTime.now()),
      );

      if (!stateContext.mounted) return;

      if (pickedTime != null) {
        setState(() {
          _selectedDueDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _isLoading = true;
    });

    try {
      final task = Task(
        id: widget.taskToEdit?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
        category: _selectedCategory,
        dueDate: _selectedDueDate,
        isCompleted: widget.taskToEdit?.isCompleted ?? false,
        createdAt: widget.taskToEdit?.createdAt,
      );

      if (widget.taskToEdit != null) {
        await TaskService.updateTask(task);
      } else {
        await TaskService.addTask(task);
      }

      if (mounted) {
        navigator.pop(true); // Return true to indicate success
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              widget.taskToEdit != null
                  ? 'Task updated successfully!'
                  : 'Task created successfully!',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error saving task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }

  IconData _getCategoryIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.personal:
        return Icons.person;
      case TaskCategory.work:
        return Icons.work;
      case TaskCategory.shopping:
        return Icons.shopping_cart;
      case TaskCategory.health:
        return Icons.health_and_safety;
      case TaskCategory.education:
        return Icons.school;
      case TaskCategory.other:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskToEdit != null ? 'Edit Task' : 'Add New Task'),
        actions: [
          if (widget.taskToEdit != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);

                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Task'),
                    content: const Text(
                      'Are you sure you want to delete this task?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  try {
                    await TaskService.deleteTask(widget.taskToEdit!.id);
                    if (mounted) {
                      navigator.pop(true);
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Task deleted successfully!'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      messenger.showSnackBar(
                        SnackBar(content: Text('Error deleting task: $e')),
                      );
                    }
                  }
                }
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'Enter task title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Enter task description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Priority Selection
              Text(
                'Priority',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: TaskPriority.values.map((priority) {
                  return FilterChip(
                    selected: _selectedPriority == priority,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 12,
                          color: _getPriorityColor(priority),
                        ),
                        const SizedBox(width: 4),
                        Text(priority.name.toUpperCase()),
                      ],
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedPriority = priority;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Category Selection
              Text(
                'Category',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TaskCategory.values.map((category) {
                  return FilterChip(
                    selected: _selectedCategory == category,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getCategoryIcon(category), size: 16),
                        const SizedBox(width: 4),
                        Text(category.name.toUpperCase()),
                      ],
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Due Date Selection
              Text(
                'Due Date (Optional)',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    _selectedDueDate != null
                        ? DateFormat(
                            'MMM dd, yyyy - HH:mm',
                          ).format(_selectedDueDate!)
                        : 'No due date set',
                  ),
                  trailing: _selectedDueDate != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _selectedDueDate = null;
                            });
                          },
                        )
                      : const Icon(Icons.arrow_forward_ios),
                  onTap: _selectDueDate,
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveTask,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          widget.taskToEdit != null
                              ? 'Update Task'
                              : 'Create Task',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
