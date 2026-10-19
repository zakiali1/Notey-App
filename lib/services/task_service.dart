import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskService {
  static const String _tasksKey = 'tasks';
  static const String _completedTasksCountKey = 'completed_tasks_count';

  static Future<List<Task>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList(_tasksKey) ?? [];
    return tasksJson.map((taskJson) => Task.fromJson(jsonDecode(taskJson))).toList();
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList(_tasksKey, tasksJson);
  }

  static Future<void> addTask(Task task) async {
    final tasks = await getTasks();
    tasks.add(task);
    await saveTasks(tasks);
  }

  static Future<void> updateTask(Task updatedTask) async {
    final tasks = await getTasks();
    final index = tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      tasks[index] = updatedTask;
      await saveTasks(tasks);
    }
  }

  static Future<void> deleteTask(String taskId) async {
    final tasks = await getTasks();
    tasks.removeWhere((task) => task.id == taskId);
    await saveTasks(tasks);
  }

  static Future<void> toggleTaskCompletion(String taskId) async {
    final tasks = await getTasks();
    final index = tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final wasCompleted = tasks[index].isCompleted;
      tasks[index].isCompleted = !wasCompleted;
      
      // Update completed tasks count
      if (!wasCompleted && tasks[index].isCompleted) {
        await _incrementCompletedTasksCount();
      } else if (wasCompleted && !tasks[index].isCompleted) {
        await _decrementCompletedTasksCount();
      }
      
      await saveTasks(tasks);
    }
  }

  static Future<Map<String, dynamic>> getTaskStats() async {
    final tasks = await getTasks();
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    final pendingTasks = tasks.length - completedTasks;
    final totalCompletedAllTime = await _getCompletedTasksCount();
    
    // Tasks by category
    Map<TaskCategory, int> tasksByCategory = {};
    for (var category in TaskCategory.values) {
      tasksByCategory[category] = tasks.where((task) => task.category == category).length;
    }
    
    // Tasks by priority
    Map<TaskPriority, int> tasksByPriority = {};
    for (var priority in TaskPriority.values) {
      tasksByPriority[priority] = tasks.where((task) => task.priority == priority && !task.isCompleted).length;
    }
    
    return {
      'totalTasks': tasks.length,
      'completedTasks': completedTasks,
      'pendingTasks': pendingTasks,
      'completionRate': tasks.isEmpty ? 0.0 : (completedTasks / tasks.length) * 100,
      'totalCompletedAllTime': totalCompletedAllTime,
      'tasksByCategory': tasksByCategory,
      'tasksByPriority': tasksByPriority,
    };
  }

  static Future<int> _getCompletedTasksCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_completedTasksCountKey) ?? 0;
  }

  static Future<void> _incrementCompletedTasksCount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = await _getCompletedTasksCount();
    await prefs.setInt(_completedTasksCountKey, currentCount + 1);
  }

  static Future<void> _decrementCompletedTasksCount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = await _getCompletedTasksCount();
    if (currentCount > 0) {
      await prefs.setInt(_completedTasksCountKey, currentCount - 1);
    }
  }

  static Future<List<Task>> getTasksByCategory(TaskCategory category) async {
    final tasks = await getTasks();
    return tasks.where((task) => task.category == category).toList();
  }

  static Future<List<Task>> getTasksByPriority(TaskPriority priority) async {
    final tasks = await getTasks();
    return tasks.where((task) => task.priority == priority).toList();
  }

  static Future<List<Task>> getOverdueTasks() async {
    final tasks = await getTasks();
    final now = DateTime.now();
    return tasks.where((task) => 
      task.dueDate != null && 
      task.dueDate!.isBefore(now) && 
      !task.isCompleted
    ).toList();
  }
}