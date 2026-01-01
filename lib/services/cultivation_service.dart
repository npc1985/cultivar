/// Cultivation service for generating planting tasks and recommendations
library;

import '../models/plant.dart';
import '../models/garden.dart';
import '../models/frost_dates.dart';
import '../models/planting_task.dart';

/// Service for generating smart planting recommendations
class CultivationService {
  const CultivationService();

  /// Generate all upcoming tasks based on frost dates and garden
  List<PlantingTask> generateUpcomingTasks({
    required FrostDates frostDates,
    required List<PlantedCrop> plantedCrops,
    required List<Plant> plantDatabase,
    int daysAhead = 30,
  }) {
    final tasks = <PlantingTask>[];
    final now = DateTime.now();
    final cutoffDate = now.add(Duration(days: daysAhead));

    // Generate tasks for plants in garden
    for (final crop in plantedCrops) {
      final plant = plantDatabase.where((p) => p.id == crop.plantId).firstOrNull;
      if (plant == null) continue;

      final cropTasks = _generateTasksForCrop(
        crop: crop,
        plant: plant,
        frostDates: frostDates,
        now: now,
        cutoffDate: cutoffDate,
      );
      tasks.addAll(cropTasks);
    }

    // Generate suggestions for plants not yet in garden (seasonal recommendations)
    final gardenPlantIds = plantedCrops.map((c) => c.plantId).toSet();
    final suggestions = _generateSeasonalSuggestions(
      frostDates: frostDates,
      plantDatabase: plantDatabase,
      gardenPlantIds: gardenPlantIds,
      now: now,
      cutoffDate: cutoffDate,
    );
    tasks.addAll(suggestions);

    // Sort by due date
    tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return tasks;
  }

  /// Generate tasks for a specific planted crop
  List<PlantingTask> _generateTasksForCrop({
    required PlantedCrop crop,
    required Plant plant,
    required FrostDates frostDates,
    required DateTime now,
    required DateTime cutoffDate,
  }) {
    final tasks = <PlantingTask>[];

    switch (crop.status) {
      case CropStatus.planned:
        // Check if it's time to start indoors
        if (plant.indoorStartWeeks != null) {
          final startDate = frostDates.indoorStartDate(plant.indoorStartWeeks!);
          if (startDate != null && _isInWindow(startDate, now, cutoffDate)) {
            tasks.add(PlantingTask(
              id: '${crop.id}_start_indoors',
              plantId: plant.id,
              plantName: plant.commonName,
              cropId: crop.id,
              type: TaskType.startIndoors,
              title: 'Start ${plant.commonName} indoors',
              description: 'Start seeds indoors ${plant.indoorStartWeeks} weeks before last frost',
              dueDate: startDate,
            ));
          }
        } else if (plant.directSowWeeksBeforeFrost != null) {
          final sowDate = frostDates.directSowDate(
            weeksBeforeFrost: plant.directSowWeeksBeforeFrost,
          );
          if (sowDate != null && _isInWindow(sowDate, now, cutoffDate)) {
            tasks.add(PlantingTask(
              id: '${crop.id}_direct_sow',
              plantId: plant.id,
              plantName: plant.commonName,
              cropId: crop.id,
              type: TaskType.directSow,
              title: 'Direct sow ${plant.commonName}',
              description: 'Sow seeds directly in garden',
              dueDate: sowDate,
            ));
          }
        } else if (plant.directSowWeeksAfterFrost != null) {
          final sowDate = frostDates.directSowDate(
            weeksAfterFrost: plant.directSowWeeksAfterFrost,
          );
          if (sowDate != null && _isInWindow(sowDate, now, cutoffDate)) {
            tasks.add(PlantingTask(
              id: '${crop.id}_direct_sow',
              plantId: plant.id,
              plantName: plant.commonName,
              cropId: crop.id,
              type: TaskType.directSow,
              title: 'Direct sow ${plant.commonName}',
              description: 'Sow seeds directly in garden after frost danger passes',
              dueDate: sowDate,
            ));
          }
        }
        break;

      case CropStatus.startedIndoors:
        // Time to harden off?
        final hardenDate = frostDates.hardenOffStartDate;
        if (_isInWindow(hardenDate, now, cutoffDate)) {
          tasks.add(PlantingTask(
            id: '${crop.id}_harden',
            plantId: plant.id,
            plantName: plant.commonName,
            cropId: crop.id,
            type: TaskType.hardenOff,
            title: 'Begin hardening off ${plant.commonName}',
            description: 'Start acclimating seedlings to outdoor conditions',
            dueDate: hardenDate,
          ));
        }
        break;

      case CropStatus.hardeningOff:
        // Time to transplant?
        final transplantWeeks = plant.transplantWeeksAfterFrost ?? 2;
        final transplantDate = frostDates.transplantDate(transplantWeeks);
        if (transplantDate != null && _isInWindow(transplantDate, now, cutoffDate)) {
          tasks.add(PlantingTask(
            id: '${crop.id}_transplant',
            plantId: plant.id,
            plantName: plant.commonName,
            cropId: crop.id,
            type: TaskType.transplant,
            title: 'Transplant ${plant.commonName}',
            description: 'Move to garden after hardening off',
            dueDate: transplantDate,
          ));
        }
        break;

      case CropStatus.growing:
      case CropStatus.flowering:
      case CropStatus.fruiting:
        // Check for expected harvest
        if (crop.expectedHarvestDate != null &&
            _isInWindow(crop.expectedHarvestDate!, now, cutoffDate)) {
          tasks.add(PlantingTask(
            id: '${crop.id}_harvest',
            plantId: plant.id,
            plantName: plant.commonName,
            cropId: crop.id,
            type: TaskType.harvest,
            title: 'Harvest ${plant.commonName}',
            description: 'Expected harvest time',
            dueDate: crop.expectedHarvestDate!,
          ));
        }
        break;

      default:
        break;
    }

    return tasks;
  }

  /// Generate seasonal suggestions for plants not in garden
  List<PlantingTask> _generateSeasonalSuggestions({
    required FrostDates frostDates,
    required List<Plant> plantDatabase,
    required Set<String> gardenPlantIds,
    required DateTime now,
    required DateTime cutoffDate,
    int maxSuggestions = 5,
  }) {
    final suggestions = <PlantingTask>[];

    for (final plant in plantDatabase) {
      if (gardenPlantIds.contains(plant.id)) continue;

      // Check if now is a good time to start this plant
      DateTime? actionDate;
      TaskType? taskType;
      String? description;

      if (plant.indoorStartWeeks != null) {
        actionDate = frostDates.indoorStartDate(plant.indoorStartWeeks!);
        taskType = TaskType.startIndoors;
        description = 'Good time to start seeds indoors';
      } else if (plant.directSowWeeksBeforeFrost != null) {
        actionDate = frostDates.directSowDate(weeksBeforeFrost: plant.directSowWeeksBeforeFrost);
        taskType = TaskType.directSow;
        description = 'Good time to direct sow';
      } else if (plant.directSowWeeksAfterFrost != null) {
        actionDate = frostDates.directSowDate(weeksAfterFrost: plant.directSowWeeksAfterFrost);
        taskType = TaskType.directSow;
        description = 'Good time to direct sow after frost';
      }

      if (actionDate != null &&
          taskType != null &&
          _isInWindow(actionDate, now, cutoffDate)) {
        suggestions.add(PlantingTask(
          id: 'suggest_${plant.id}',
          plantId: plant.id,
          plantName: plant.commonName,
          type: taskType,
          title: 'Consider planting ${plant.commonName}',
          description: description ?? '',
          dueDate: actionDate,
          priority: TaskPriority.low,
        ));
      }

      if (suggestions.length >= maxSuggestions) break;
    }

    return suggestions;
  }

  /// Check if a date falls within the task window
  bool _isInWindow(DateTime date, DateTime now, DateTime cutoff) {
    // Allow tasks from 7 days ago (overdue) to cutoff date ahead
    final windowStart = now.subtract(const Duration(days: 7));
    return date.isAfter(windowStart) && date.isBefore(cutoff);
  }

  /// Get the optimal moon phase for a plant type
  String getMoonPhaseAdvice(Plant plant) {
    final phase = plant.bestMoonPhase;
    return switch (phase) {
      MoonPhasePreference.waxingFirstQuarter =>
        'Best planted during new moon to first quarter (increasing light, leafy growth)',
      MoonPhasePreference.waxingSecondQuarter =>
        'Best planted during first quarter to full moon (maximum light, fruiting)',
      MoonPhasePreference.waningThirdQuarter =>
        'Best planted during full moon to last quarter (root development)',
      MoonPhasePreference.waningFourthQuarter =>
        'Best planted during last quarter to new moon (rest period, maintenance)',
      MoonPhasePreference.any => 'Can be planted during any moon phase',
    };
  }

  /// Get biodynamic planting advice for a plant
  String getBiodynamicAdvice(Plant plant) {
    if (plant.bestMoonSigns.isEmpty) {
      return 'No specific moon sign preference';
    }

    final signs = plant.bestMoonSigns.join(', ');
    final partType = switch (plant.plantPart) {
      PlantPart.root => 'root crop',
      PlantPart.leaf => 'leaf crop',
      PlantPart.flower => 'flower crop',
      PlantPart.fruit => 'fruit crop',
      PlantPart.seed => 'seed crop',
    };

    return 'As a $partType, plant when moon is in $signs for best results';
  }

  /// Calculate days until a task is due
  int daysUntilDue(PlantingTask task) {
    return task.dueDate.difference(DateTime.now()).inDays;
  }

  /// Check if a task is overdue
  bool isOverdue(PlantingTask task) {
    return task.dueDate.isBefore(DateTime.now());
  }

  /// Get urgency level for a task
  TaskUrgency getUrgency(PlantingTask task) {
    final days = daysUntilDue(task);
    if (days < 0) return TaskUrgency.overdue;
    if (days <= 3) return TaskUrgency.urgent;
    if (days <= 7) return TaskUrgency.soon;
    if (days <= 14) return TaskUrgency.upcoming;
    return TaskUrgency.later;
  }
}

/// Task urgency levels
enum TaskUrgency {
  overdue,
  urgent,
  soon,
  upcoming,
  later,
}

extension TaskUrgencyExtension on TaskUrgency {
  String get displayName {
    return switch (this) {
      TaskUrgency.overdue => 'Overdue',
      TaskUrgency.urgent => 'Do Now',
      TaskUrgency.soon => 'This Week',
      TaskUrgency.upcoming => 'Coming Up',
      TaskUrgency.later => 'Later',
    };
  }

  String get emoji {
    return switch (this) {
      TaskUrgency.overdue => '⚠️',
      TaskUrgency.urgent => '🔴',
      TaskUrgency.soon => '🟠',
      TaskUrgency.upcoming => '🟡',
      TaskUrgency.later => '🟢',
    };
  }
}
