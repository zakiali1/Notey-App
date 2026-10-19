import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggleCompletion;
  final VoidCallback onEdit;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleCompletion,
    required this.onEdit,
  });

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

  bool _isOverdue() {
    if (task.dueDate == null || task.isCompleted) return false;
    return task.dueDate!.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = _isOverdue();
    final theme = Theme.of(context);
    
    return Card(
      elevation: task.isCompleted ? 1 : 3,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getPriorityColor(task.priority).withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Completion Checkbox
                    GestureDetector(
                      onTap: onToggleCompletion,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: task.isCompleted
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline,
                            width: 2,
                          ),
                          color: task.isCompleted
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                        ),
                        child: task.isCompleted
                            ? Icon(
                                Icons.check,
                                size: 16,
                                color: theme.colorScheme.onPrimary,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Category Icon
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getCategoryIcon(task.category),
                        size: 16,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Priority Indicator
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getPriorityColor(task.priority),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Priority Text
                    Text(
                      task.priority.name.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _getPriorityColor(task.priority),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    
                    // More Options
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: onEdit,
                      iconSize: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Task Title
                Text(
                  task.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: task.isCompleted
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSurface,
                  ),
                ),
                
                // Task Description (if not empty)
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: task.isCompleted
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.onSurfaceVariant,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                const SizedBox(height: 12),
                
                // Footer Row
                Row(
                  children: [
                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        task.category.name.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    
                    // Due Date
                    if (task.dueDate != null) ...[
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: isOverdue
                            ? Colors.red
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd, HH:mm').format(task.dueDate!),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isOverdue
                              ? Colors.red
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ],
                ),
                
                // Overdue Warning
                if (isOverdue) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning,
                          size: 16,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'OVERDUE',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}