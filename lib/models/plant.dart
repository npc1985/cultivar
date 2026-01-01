/// Plant database model for the Cultivation tab
library;

/// Category of plant for organization
enum PlantCategory {
  vegetable('Vegetables', '🥬'),
  fruit('Fruits', '🍎'),
  berry('Berries', '🫐'),
  herb('Herbs', '🌿'),
  rose('Roses', '🌹'),
  bees('Bees', '🐝');

  const PlantCategory(this.displayName, this.emoji);
  final String displayName;
  final String emoji;
}

/// Part of plant harvested (for biodynamic moon sign matching)
enum PlantPart {
  root, // Carrots, potatoes - Earth signs (Taurus, Virgo, Capricorn)
  leaf, // Lettuce, spinach - Water signs (Cancer, Scorpio, Pisces)
  fruit, // Tomatoes, peppers - Fire signs (Aries, Leo, Sagittarius)
  flower, // Broccoli, cauliflower - Air signs (Gemini, Libra, Aquarius)
  seed, // Beans, peas - Fire/Air signs
}

/// Moon phase preference for planting
enum MoonPhasePreference {
  waxingFirstQuarter, // New moon to first quarter - leafy crops
  waxingSecondQuarter, // First quarter to full - fruiting crops
  waningThirdQuarter, // Full to last quarter - root crops
  waningFourthQuarter, // Last quarter to new - rest, maintenance
  any, // No strong preference
}

/// Complete plant data with timing, care, and biodynamic info
class Plant {
  const Plant({
    required this.id,
    required this.commonName,
    this.scientificName,
    required this.category,
    required this.plantPart,
    required this.emoji,
    this.indoorStartWeeks,
    this.transplantWeeksBeforeFrost,
    this.transplantWeeksAfterFrost,
    this.directSowWeeksBeforeFrost,
    this.directSowWeeksAfterFrost,
    required this.daysToMaturity,
    this.harvestWindowDays = 30,
    required this.minTempTolerance,
    this.isFrostTolerant = false,
    this.isFreezeTolerant = false,
    required this.spacing,
    required this.sunRequirement,
    this.wateringNotes = '',
    this.feedingNotes = '',
    this.pestNotes = const [],
    this.companionPlants = const [],
    this.avoidPlanting = const [],
    this.bestMoonSigns = const [],
    this.bestMoonPhase = MoonPhasePreference.any,
    this.careNotes = '',
    this.varieties = const [],
    this.medicinalUses = const [],
    this.edibleParts = const [],
    this.preparationNotes = '',
    this.isNative = false,
    this.isHeirloom = false,
    this.propagationNotes = '',
    this.canGrowIndoors = false,
    this.permacultureZone,
    this.permacultureFunctions = const [],
    this.guilds = const [],
  });

  final String id;
  final String commonName;
  final String? scientificName;
  final PlantCategory category;
  final PlantPart plantPart;
  final String emoji;

  // Timing (weeks relative to last frost date)
  final int? indoorStartWeeks; // Weeks BEFORE last frost to start indoors
  final int? transplantWeeksBeforeFrost; // Weeks BEFORE last frost to transplant (cool season)
  final int? transplantWeeksAfterFrost; // Weeks AFTER last frost to transplant
  final int? directSowWeeksBeforeFrost; // Weeks BEFORE last frost for cold-hardy direct sow
  final int? directSowWeeksAfterFrost; // Weeks AFTER last frost for warm-season direct sow

  // Maturity
  final int daysToMaturity; // Days from transplant/sow to harvest
  final int harvestWindowDays; // How long harvest period lasts

  // Cold tolerance
  final double minTempTolerance; // Minimum temperature (F) plant survives
  final bool isFrostTolerant; // Can handle light frost (32F)
  final bool isFreezeTolerant; // Can handle hard freeze (28F)

  // Care
  final String spacing;
  final String sunRequirement;
  final String wateringNotes;
  final String feedingNotes;
  final List<String> pestNotes;
  final List<String> companionPlants;
  final List<String> avoidPlanting;
  final String careNotes;
  final List<String> varieties;

  // Herbalism & Provenance
  final List<String> medicinalUses; // Health/medicinal benefits
  final List<String> edibleParts; // Which parts are edible (leaves, roots, flowers, etc.)
  final String preparationNotes; // How to prepare/use medicinally (tea, tincture, salve, etc.)
  final bool isNative; // Native to North America
  final bool isHeirloom; // Heirloom/antique variety
  final String propagationNotes; // Seed saving, cuttings, divisions
  final bool canGrowIndoors; // Suitable for indoor growing

  // Permaculture
  final int? permacultureZone; // 1-5, null if flexible
  final List<String> permacultureFunctions; // Nitrogen fixer, dynamic accumulator, etc.
  final List<String> guilds; // Permaculture guild suggestions

  // Biodynamic
  final List<String> bestMoonSigns;
  final MoonPhasePreference bestMoonPhase;

  /// Get timing description for display
  String get timingDescription {
    final parts = <String>[];

    if (indoorStartWeeks != null) {
      parts.add('Start indoors $indoorStartWeeks weeks before last frost');
    }
    if (transplantWeeksBeforeFrost != null) {
      parts.add('Transplant $transplantWeeksBeforeFrost weeks before last frost');
    }
    if (transplantWeeksAfterFrost != null) {
      if (transplantWeeksAfterFrost == 0) {
        parts.add('Transplant after last frost');
      } else {
        parts.add(
            'Transplant $transplantWeeksAfterFrost weeks after last frost');
      }
    }
    if (directSowWeeksBeforeFrost != null) {
      parts.add('Direct sow $directSowWeeksBeforeFrost weeks before last frost');
    }
    if (directSowWeeksAfterFrost != null) {
      if (directSowWeeksAfterFrost == 0) {
        parts.add('Direct sow after last frost');
      } else {
        parts.add('Direct sow $directSowWeeksAfterFrost weeks after last frost');
      }
    }

    return parts.join('\n');
  }

  /// Get cold hardiness description
  String get hardinessDescription {
    if (isFreezeTolerant) {
      return 'Freeze tolerant (survives below 28°F)';
    } else if (isFrostTolerant) {
      return 'Frost tolerant (survives light frost)';
    } else {
      return 'Tender (protect from frost)';
    }
  }

  /// Check if this plant needs frost protection at a given temperature
  bool needsFrostProtection(double tempF) {
    return tempF <= minTempTolerance;
  }

  /// Get biodynamic planting advice
  String get biodynamicAdvice {
    if (bestMoonSigns.isEmpty) return '';

    final signList = bestMoonSigns.join(', ');
    final phaseAdvice = switch (bestMoonPhase) {
      MoonPhasePreference.waxingFirstQuarter =>
        'Plant during waxing moon (new to first quarter)',
      MoonPhasePreference.waxingSecondQuarter =>
        'Plant during waxing moon (first quarter to full)',
      MoonPhasePreference.waningThirdQuarter =>
        'Plant during waning moon (full to last quarter)',
      MoonPhasePreference.waningFourthQuarter =>
        'Best for maintenance during waning moon',
      MoonPhasePreference.any => '',
    };

    return 'Best moon signs: $signList${phaseAdvice.isNotEmpty ? '\n$phaseAdvice' : ''}';
  }
}

/// Bee management task (special category - not a plant but managed similarly)
class BeeTask {
  const BeeTask({
    required this.id,
    required this.name,
    required this.emoji,
    required this.monthsActive,
    required this.description,
    this.urgency = TaskUrgency.normal,
    this.weatherDependent = false,
    this.minTempF,
    this.maxTempF,
    this.notes = '',
  });

  final String id;
  final String name;
  final String emoji;
  final List<int> monthsActive; // 1-12
  final String description;
  final TaskUrgency urgency;
  final bool weatherDependent;
  final double? minTempF; // Min temp for this task
  final double? maxTempF; // Max temp for this task
  final String notes;

  bool isActiveInMonth(int month) => monthsActive.contains(month);
}

enum TaskUrgency { low, normal, high, critical }

/// Rose care task (special category with seasonal timing)
class RoseCareTask {
  const RoseCareTask({
    required this.id,
    required this.name,
    required this.emoji,
    required this.monthsActive,
    required this.description,
    this.weeksBeforeLastFrost,
    this.weeksAfterLastFrost,
    this.notes = '',
  });

  final String id;
  final String name;
  final String emoji;
  final List<int> monthsActive;
  final String description;
  final int? weeksBeforeLastFrost;
  final int? weeksAfterLastFrost;
  final String notes;

  bool isActiveInMonth(int month) => monthsActive.contains(month);
}
