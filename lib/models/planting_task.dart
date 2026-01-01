/// Planting task models for the Cultivation tab
library;

/// Type of planting/gardening task
enum TaskType {
  startIndoors('Start Indoors', '🌱', 'Begin seeds under grow lights'),
  hardenOff('Harden Off', '🌤️', 'Gradually expose to outdoor conditions'),
  transplant('Transplant', '🏡', 'Move to permanent garden location'),
  directSow('Direct Sow', '🌾', 'Plant seeds directly in ground'),
  frostProtection('Frost Protection', '❄️', 'Cover or bring plants inside'),
  harvest('Harvest', '🧺', 'Pick ripe produce'),
  prune('Prune', '✂️', 'Cut back for health or shape'),
  feed('Feed', '🧪', 'Apply fertilizer'),
  water('Water', '💧', 'Deep watering needed'),
  pestControl('Pest Control', '🐛', 'Check for and treat pests'),
  weed('Weed', '🌿', 'Remove weeds from beds'),
  mulch('Mulch', '🍂', 'Apply or refresh mulch'),
  soilPrep('Soil Prep', '🪨', 'Prepare beds for planting'),
  cleanUp('Clean Up', '🧹', 'End of season cleanup'),
  winterize('Winterize', '🧊', 'Prepare for winter dormancy'),
  beeTask('Bee Task', '🐝', 'Hive maintenance'),
  roseCare('Rose Care', '🌹', 'Rose-specific maintenance');

  const TaskType(this.displayName, this.emoji, this.description);
  final String displayName;
  final String emoji;
  final String description;
}

/// Priority level for tasks
enum TaskPriority {
  low('Low', 0.5),
  normal('Normal', 1.0),
  high('High', 1.5),
  urgent('Urgent', 2.0);

  const TaskPriority(this.displayName, this.weight);
  final String displayName;
  final double weight;
}

/// A generated planting/gardening task
class PlantingTask {
  const PlantingTask({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.dueDate,
    this.windowStart,
    this.windowEnd,
    this.plantId,
    this.plantName,
    this.cropId,
    this.priority = TaskPriority.normal,
    this.isWeatherTriggered = false,
    this.weatherCondition,
    this.isCompleted = false,
    this.completedDate,
  });

  final String id;
  final TaskType type;
  final String title;
  final String description;
  final DateTime dueDate;
  final DateTime? windowStart; // Start of optimal window
  final DateTime? windowEnd; // End of optimal window
  final String? plantId; // Related plant ID
  final String? plantName; // Plant name for display
  final String? cropId; // Related planted crop ID
  final TaskPriority priority;
  final bool isWeatherTriggered; // Frost warning vs scheduled
  final String? weatherCondition; // e.g., "28°F expected"
  final bool isCompleted;
  final DateTime? completedDate;

  /// Is this task overdue?
  bool get isOverdue => !isCompleted && DateTime.now().isAfter(dueDate);

  /// Is this task due today?
  bool get isDueToday {
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }

  /// Is this task due this week?
  bool get isDueThisWeek {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));
    return dueDate.isAfter(now) && dueDate.isBefore(weekFromNow);
  }

  /// Days until due (negative if overdue)
  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;

  /// Is within optimal window?
  bool get isInOptimalWindow {
    if (windowStart == null || windowEnd == null) return true;
    final now = DateTime.now();
    return now.isAfter(windowStart!) && now.isBefore(windowEnd!);
  }

  /// Get urgency description
  String get urgencyDescription {
    if (isOverdue) return 'Overdue';
    if (isDueToday) return 'Today';
    if (daysUntilDue == 1) return 'Tomorrow';
    if (isDueThisWeek) return 'This week';
    if (daysUntilDue <= 14) return 'In $daysUntilDue days';
    return 'Upcoming';
  }

  /// Create a copy with updated values
  PlantingTask copyWith({
    String? id,
    TaskType? type,
    String? title,
    String? description,
    DateTime? dueDate,
    DateTime? windowStart,
    DateTime? windowEnd,
    String? plantId,
    String? plantName,
    String? cropId,
    TaskPriority? priority,
    bool? isWeatherTriggered,
    String? weatherCondition,
    bool? isCompleted,
    DateTime? completedDate,
  }) {
    return PlantingTask(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      windowStart: windowStart ?? this.windowStart,
      windowEnd: windowEnd ?? this.windowEnd,
      plantId: plantId ?? this.plantId,
      plantName: plantName ?? this.plantName,
      cropId: cropId ?? this.cropId,
      priority: priority ?? this.priority,
      isWeatherTriggered: isWeatherTriggered ?? this.isWeatherTriggered,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      isCompleted: isCompleted ?? this.isCompleted,
      completedDate: completedDate ?? this.completedDate,
    );
  }
}

/// Planting schedule for a specific plant based on frost dates
class PlantingSchedule {
  const PlantingSchedule({
    required this.plantId,
    required this.plantName,
    this.indoorStartDate,
    this.indoorStartDeadline,
    this.hardenOffStartDate,
    this.transplantWindowStart,
    this.transplantDeadline,
    this.directSowWindowStart,
    this.directSowDeadline,
    this.expectedHarvestStart,
    this.expectedHarvestEnd,
  });

  final String plantId;
  final String plantName;

  // Indoor starting window
  final DateTime? indoorStartDate;
  final DateTime? indoorStartDeadline;

  // Hardening off period
  final DateTime? hardenOffStartDate;

  // Transplant window
  final DateTime? transplantWindowStart;
  final DateTime? transplantDeadline;

  // Direct sow window
  final DateTime? directSowWindowStart;
  final DateTime? directSowDeadline;

  // Expected harvest
  final DateTime? expectedHarvestStart;
  final DateTime? expectedHarvestEnd;

  /// Get current phase based on date
  String currentPhase(DateTime date) {
    if (indoorStartDate != null && date.isBefore(indoorStartDate!)) {
      return 'Not yet time to start';
    }
    if (indoorStartDate != null &&
        hardenOffStartDate != null &&
        date.isAfter(indoorStartDate!) &&
        date.isBefore(hardenOffStartDate!)) {
      return 'Start indoors now';
    }
    if (hardenOffStartDate != null &&
        transplantWindowStart != null &&
        date.isAfter(hardenOffStartDate!) &&
        date.isBefore(transplantWindowStart!)) {
      return 'Harden off seedlings';
    }
    if (transplantWindowStart != null &&
        date.isAfter(transplantWindowStart!)) {
      return 'Ready to transplant';
    }
    if (directSowWindowStart != null &&
        date.isAfter(directSowWindowStart!)) {
      return 'Direct sow now';
    }
    return 'Check timing';
  }

  /// Is it time to start this plant indoors?
  bool isIndoorStartTime(DateTime date) {
    if (indoorStartDate == null || indoorStartDeadline == null) return false;
    return date.isAfter(indoorStartDate!) && date.isBefore(indoorStartDeadline!);
  }

  /// Is it time to transplant?
  bool isTransplantTime(DateTime date) {
    if (transplantWindowStart == null) return false;
    final deadline = transplantDeadline ?? transplantWindowStart!.add(const Duration(days: 30));
    return date.isAfter(transplantWindowStart!) && date.isBefore(deadline);
  }

  /// Is it time to direct sow?
  bool isDirectSowTime(DateTime date) {
    if (directSowWindowStart == null) return false;
    final deadline = directSowDeadline ?? directSowWindowStart!.add(const Duration(days: 30));
    return date.isAfter(directSowWindowStart!) && date.isBefore(deadline);
  }
}
