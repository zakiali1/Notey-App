import 'package:uuid/uuid.dart';

enum TaskPriority { low, medium, high }
enum TaskCategory { personal, work, shopping, health, education, other }

class Task {
  final String id;
  String title;
  String description;
  bool isCompleted;
  DateTime createdAt;
  DateTime? dueDate;
  TaskPriority priority;
  TaskCategory category;

  Task({
    String? id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    DateTime? createdAt,
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.category = TaskCategory.personal,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority.index,
      'category': category.index,
    };
  }

  static Task fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      priority: TaskPriority.values[json['priority'] ?? 1],
      category: TaskCategory.values[json['category'] ?? 0],
    );
  }

  Task copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskCategory? category,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      category: category ?? this.category,
    );
  }
}