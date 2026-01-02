/// Riverpod providers for cultivation tasks and recommendations
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/planting_task.dart';
import '../services/cultivation_service.dart';
import 'frost_provider.dart';
import 'garden_provider.dart';
import 'plant_provider.dart';

/// Cultivation service instance
final cultivationServiceProvider = Provider<CultivationService>((ref) {
  return const CultivationService();
});

/// All upcoming planting tasks (excluding completed)
final upcomingTasksProvider = Provider<List<PlantingTask>>((ref) {
  final service = ref.watch(cultivationServiceProvider);
  final frostDatesAsync = ref.watch(frostDatesProvider);
  final cropsAsync = ref.watch(gardenProvider);
  final plants = ref.watch(allPlantsProvider);
  final completedIdsAsync = ref.watch(completedTaskIdsProvider);

  return frostDatesAsync.when(
    data: (frostDates) {
      if (frostDates == null) return [];

      return cropsAsync.when(
        data: (crops) {
          final allTasks = service.generateUpcomingTasks(
            frostDates: frostDates,
            plantedCrops: crops,
            plantDatabase: plants,
          );

          // Filter out completed tasks
          return completedIdsAsync.when(
            data: (completedIds) {
              return allTasks.where((task) => !completedIds.contains(task.id)).toList();
            },
            loading: () => allTasks,
            error: (_, _) => allTasks,
          );
        },
        loading: () => [],
        error: (_, _) => [],
      );
    },
    loading: () => [],
    error: (_, _) => [],
  );
});

/// Tasks for the current week
final thisWeekTasksProvider = Provider<List<PlantingTask>>((ref) {
  final tasks = ref.watch(upcomingTasksProvider);
  return tasks.where((t) => t.isDueThisWeek || t.isOverdue).toList();
});

/// Overdue tasks
final overdueTasksProvider = Provider<List<PlantingTask>>((ref) {
  final tasks = ref.watch(upcomingTasksProvider);
  return tasks.where((t) => t.isOverdue).toList();
});

/// Task count by urgency
final taskCountsByUrgencyProvider = Provider<Map<TaskUrgency, int>>((ref) {
  final tasks = ref.watch(upcomingTasksProvider);
  final service = ref.watch(cultivationServiceProvider);

  final counts = <TaskUrgency, int>{};
  for (final urgency in TaskUrgency.values) {
    counts[urgency] = tasks.where((t) => service.getUrgency(t) == urgency).length;
  }
  return counts;
});

/// Top priority tasks (max 5)
final topPriorityTasksProvider = Provider<List<PlantingTask>>((ref) {
  final tasks = ref.watch(upcomingTasksProvider);
  final service = ref.watch(cultivationServiceProvider);

  // Sort by urgency then by date
  final sorted = List<PlantingTask>.from(tasks)..sort((a, b) {
    final urgencyA = service.getUrgency(a).index;
    final urgencyB = service.getUrgency(b).index;
    if (urgencyA != urgencyB) return urgencyA.compareTo(urgencyB);
    return a.dueDate.compareTo(b.dueDate);
  });

  return sorted.take(5).toList();
});

/// Suggestions for plants not yet in garden
final plantingSuggestionsProvider = Provider<List<PlantingTask>>((ref) {
  final tasks = ref.watch(upcomingTasksProvider);
  return tasks.where((t) => t.priority == TaskPriority.low).toList();
});

/// Active garden tasks (not suggestions)
final gardenTasksProvider = Provider<List<PlantingTask>>((ref) {
  final tasks = ref.watch(upcomingTasksProvider);
  return tasks.where((t) => t.priority != TaskPriority.low).toList();
});

/// Check if there are any urgent tasks
final hasUrgentTasksProvider = Provider<bool>((ref) {
  final counts = ref.watch(taskCountsByUrgencyProvider);
  return (counts[TaskUrgency.overdue] ?? 0) > 0 ||
      (counts[TaskUrgency.urgent] ?? 0) > 0;
});

/// Summary text for task status
final taskSummaryProvider = Provider<String>((ref) {
  final tasks = ref.watch(gardenTasksProvider);
  final overdue = ref.watch(overdueTasksProvider);

  if (tasks.isEmpty) {
    return 'No upcoming tasks';
  }

  if (overdue.isNotEmpty) {
    return '${overdue.length} overdue task${overdue.length > 1 ? 's' : ''}';
  }

  final thisWeek = tasks.where((t) => t.isDueThisWeek).length;
  if (thisWeek > 0) {
    return '$thisWeek task${thisWeek > 1 ? 's' : ''} this week';
  }

  return '${tasks.length} upcoming task${tasks.length > 1 ? 's' : ''}';
});
