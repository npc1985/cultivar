/// Frost date and hardiness zone models for the Cultivation tab
library;

/// USDA Hardiness Zone with temperature ranges and frost dates
class HardinessZone {
  const HardinessZone({
    required this.zone,
    required this.minTempF,
    required this.maxTempF,
    required this.avgLastFrostMonth,
    required this.avgLastFrostDay,
    required this.avgFirstFrostMonth,
    required this.avgFirstFrostDay,
    required this.growingSeasonDays,
  });

  final String zone; // "5a", "6b", "7a", etc.
  final double minTempF; // Minimum average annual temperature
  final double maxTempF; // Maximum average annual temperature
  final int avgLastFrostMonth; // 1-12
  final int avgLastFrostDay; // 1-31
  final int avgFirstFrostMonth; // 1-12
  final int avgFirstFrostDay; // 1-31
  final int growingSeasonDays; // Typical frost-free days

  /// Get the zone number (e.g., 6 from "6b")
  int get zoneNumber => int.tryParse(zone.replaceAll(RegExp(r'[ab]'), '')) ?? 0;

  /// Get the subzone (a or b)
  String get subzone => zone.contains('a') ? 'a' : 'b';

  /// Get average last frost date for a given year
  DateTime avgLastFrostDate(int year) {
    return DateTime(year, avgLastFrostMonth, avgLastFrostDay);
  }

  /// Get average first frost date for a given year
  DateTime avgFirstFrostDate(int year) {
    return DateTime(year, avgFirstFrostMonth, avgFirstFrostDay);
  }

  /// Zone description for display
  String get description {
    return 'Zone $zone: ${minTempF.round()}°F to ${maxTempF.round()}°F';
  }
}

/// User's frost dates (either from zone lookup or manual entry)
class FrostDates {
  const FrostDates({
    required this.lastSpringFrost,
    required this.firstFallFrost,
    this.zone,
    this.isManuallySet = false,
    this.lastUpdated,
  });

  final DateTime lastSpringFrost;
  final DateTime firstFallFrost;
  final HardinessZone? zone;
  final bool isManuallySet;
  final DateTime? lastUpdated;

  /// Number of frost-free growing days
  int get growingSeasonDays {
    return firstFallFrost.difference(lastSpringFrost).inDays;
  }

  /// Safe transplant date (2 weeks after last frost)
  DateTime get safeTransplantDate {
    return lastSpringFrost.add(const Duration(days: 14));
  }

  /// Start hardening off date (1 week before safe transplant)
  DateTime get hardenOffStartDate {
    return safeTransplantDate.subtract(const Duration(days: 7));
  }

  /// Calculate indoor seed start date for a plant
  DateTime? indoorStartDate(int weeksBeforeFrost) {
    return lastSpringFrost.subtract(Duration(days: weeksBeforeFrost * 7));
  }

  /// Calculate transplant date for a plant
  DateTime? transplantDate(int weeksAfterFrost) {
    return lastSpringFrost.add(Duration(days: weeksAfterFrost * 7));
  }

  /// Calculate direct sow date
  DateTime? directSowDate({int? weeksBeforeFrost, int? weeksAfterFrost}) {
    if (weeksBeforeFrost != null) {
      return lastSpringFrost.subtract(Duration(days: weeksBeforeFrost * 7));
    }
    if (weeksAfterFrost != null) {
      return lastSpringFrost.add(Duration(days: weeksAfterFrost * 7));
    }
    return null;
  }

  /// Calculate expected harvest date
  DateTime? expectedHarvestDate(DateTime plantDate, int daysToMaturity) {
    return plantDate.add(Duration(days: daysToMaturity));
  }

  /// Check if we're in the growing season
  bool isInGrowingSeason(DateTime date) {
    // Normalize to same year for comparison
    final springFrost = DateTime(date.year, lastSpringFrost.month, lastSpringFrost.day);
    final fallFrost = DateTime(date.year, firstFallFrost.month, firstFallFrost.day);
    return date.isAfter(springFrost) && date.isBefore(fallFrost);
  }

  /// Days until last spring frost (negative if past)
  int daysUntilLastFrost(DateTime from) {
    final thisYearFrost = DateTime(from.year, lastSpringFrost.month, lastSpringFrost.day);
    return thisYearFrost.difference(from).inDays;
  }

  /// Days until first fall frost
  int daysUntilFirstFrost(DateTime from) {
    final thisYearFrost = DateTime(from.year, firstFallFrost.month, firstFallFrost.day);
    return thisYearFrost.difference(from).inDays;
  }

  /// Create a copy with updated values
  FrostDates copyWith({
    DateTime? lastSpringFrost,
    DateTime? firstFallFrost,
    HardinessZone? zone,
    bool? isManuallySet,
    DateTime? lastUpdated,
  }) {
    return FrostDates(
      lastSpringFrost: lastSpringFrost ?? this.lastSpringFrost,
      firstFallFrost: firstFallFrost ?? this.firstFallFrost,
      zone: zone ?? this.zone,
      isManuallySet: isManuallySet ?? this.isManuallySet,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Serialize to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'lastSpringFrost': lastSpringFrost.toIso8601String(),
      'firstFallFrost': firstFallFrost.toIso8601String(),
      'zone': zone?.zone,
      'isManuallySet': isManuallySet,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  /// Deserialize from JSON
  factory FrostDates.fromJson(Map<String, dynamic> json) {
    return FrostDates(
      lastSpringFrost: DateTime.parse(json['lastSpringFrost'] as String),
      firstFallFrost: DateTime.parse(json['firstFallFrost'] as String),
      zone: null, // Zone needs to be looked up separately
      isManuallySet: json['isManuallySet'] as bool? ?? false,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
    );
  }
}

/// Frost warning based on weather forecast
class FrostWarning {
  const FrostWarning({
    required this.date,
    required this.lowTemp,
    required this.severity,
    this.affectedPlants = const [],
  });

  final DateTime date;
  final double lowTemp;
  final FrostSeverity severity;
  final List<String> affectedPlants; // Plant IDs that need protection

  String get message {
    final tempStr = '${lowTemp.round()}°F';
    return switch (severity) {
      FrostSeverity.light => 'Light frost possible ($tempStr)',
      FrostSeverity.moderate => 'Frost expected ($tempStr)',
      FrostSeverity.hard => 'Hard freeze warning ($tempStr)',
      FrostSeverity.severe => 'Severe freeze alert ($tempStr)',
    };
  }

  String get advice {
    return switch (severity) {
      FrostSeverity.light => 'Cover tender plants overnight',
      FrostSeverity.moderate => 'Protect all frost-sensitive plants',
      FrostSeverity.hard => 'Bring potted plants inside, heavily mulch beds',
      FrostSeverity.severe => 'Harvest remaining produce, protect perennials',
    };
  }
}

enum FrostSeverity {
  light, // 32-35°F
  moderate, // 28-32°F
  hard, // 24-28°F
  severe, // Below 24°F
}

/// Get frost severity from temperature
FrostSeverity getFrostSeverity(double tempF) {
  if (tempF >= 32) return FrostSeverity.light;
  if (tempF >= 28) return FrostSeverity.moderate;
  if (tempF >= 24) return FrostSeverity.hard;
  return FrostSeverity.severe;
}
