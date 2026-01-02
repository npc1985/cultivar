/// User's garden tracking models for the Cultivation tab
library;

/// A named location on the user's property
class GardenLocation {
  const GardenLocation({
    required this.id,
    required this.name,
    this.description,
    this.zone,
    this.icon,
    this.createdAt,
  });

  final String id;
  final String name; // e.g., "Raised Bed 1", "Forest Edge", "Kitchen Window"
  final String? description;
  final PermacultureZone? zone;
  final String? icon; // Emoji icon for the location
  final DateTime? createdAt;

  GardenLocation copyWith({
    String? id,
    String? name,
    String? description,
    PermacultureZone? zone,
    String? icon,
    DateTime? createdAt,
  }) {
    return GardenLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      zone: zone ?? this.zone,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'zone': zone?.name,
      'icon': icon,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory GardenLocation.fromJson(Map<String, dynamic> json) {
    return GardenLocation(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      zone: json['zone'] != null
          ? PermacultureZone.values.firstWhere(
              (z) => z.name == json['zone'],
              orElse: () => PermacultureZone.zone2,
            )
          : null,
      icon: json['icon'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Default suggested locations for new users
  static List<GardenLocation> get suggestions => [
        GardenLocation(id: 'raised_bed', name: 'Raised Bed', icon: '🪴', zone: PermacultureZone.zone2),
        GardenLocation(id: 'container', name: 'Containers', icon: '🪴', zone: PermacultureZone.zone1),
        GardenLocation(id: 'greenhouse', name: 'Greenhouse', icon: '🏠', zone: PermacultureZone.zone1),
        GardenLocation(id: 'orchard', name: 'Orchard', icon: '🍎', zone: PermacultureZone.zone3),
        GardenLocation(id: 'forest_garden', name: 'Forest Garden', icon: '🌳', zone: PermacultureZone.zone4),
        GardenLocation(id: 'herb_spiral', name: 'Herb Spiral', icon: '🌿', zone: PermacultureZone.zone1),
        GardenLocation(id: 'front_yard', name: 'Front Yard', icon: '🏡', zone: PermacultureZone.zone2),
        GardenLocation(id: 'back_yard', name: 'Back Yard', icon: '🌻', zone: PermacultureZone.zone2),
        GardenLocation(id: 'indoor', name: 'Indoor', icon: '🏠', zone: PermacultureZone.zone1),
      ];
}

/// Permaculture zone (1-5) for garden planning
enum PermacultureZone {
  zone1('Zone 1', 'Kitchen door area - daily visits', 1),
  zone2('Zone 2', 'Intensive garden - frequent visits', 2),
  zone3('Zone 3', 'Orchard & main crops - occasional visits', 3),
  zone4('Zone 4', 'Semi-wild, forage, timber', 4),
  zone5('Zone 5', 'Wilderness - minimal intervention', 5);

  const PermacultureZone(this.displayName, this.description, this.number);
  final String displayName;
  final String description;
  final int number;

  /// Get emoji representation
  String get emoji => switch (this) {
        zone1 => '🏠',
        zone2 => '🥬',
        zone3 => '🍎',
        zone4 => '🌲',
        zone5 => '🦌',
      };
}

/// Status of a planted crop in the user's garden
enum CropStatus {
  planned('Planned', '📋', 'Planning to grow'),
  ordered('Seeds Ordered', '📦', 'Seeds/starts on the way'),
  startedIndoors('Started Indoors', '🌱', 'Growing under lights'),
  hardeningOff('Hardening Off', '🌤️', 'Acclimating to outdoors'),
  transplanted('Transplanted', '🏡', 'Moved to garden'),
  directSowed('Direct Sowed', '🌾', 'Seeds planted in ground'),
  growing('Growing', '🌿', 'Actively growing'),
  flowering('Flowering', '🌸', 'In bloom'),
  fruiting('Fruiting', '🍅', 'Producing fruit'),
  harvesting('Harvesting', '🧺', 'Ready to pick'),
  dormant('Dormant', '💤', 'Overwintering'),
  completed('Completed', '✅', 'Done for season'),
  failed('Failed', '❌', 'Did not survive');

  const CropStatus(this.displayName, this.emoji, this.description);
  final String displayName;
  final String emoji;
  final String description;

  /// Is this an active growing status?
  bool get isActive => [
        startedIndoors,
        hardeningOff,
        transplanted,
        directSowed,
        growing,
        flowering,
        fruiting,
        harvesting,
      ].contains(this);

  /// Does this crop need frost protection?
  bool get needsFrostCheck => [
        startedIndoors,
        hardeningOff,
        transplanted,
        directSowed,
        growing,
        flowering,
        fruiting,
        harvesting,
      ].contains(this);
}

/// A single planted crop in the user's garden
class PlantedCrop {
  const PlantedCrop({
    required this.id,
    required this.plantId,
    required this.status,
    this.variety,
    this.location,
    this.zone,
    this.quantity = 1,
    this.startedIndoorsDate,
    this.hardenedOffDate,
    this.transplantedDate,
    this.directSowedDate,
    this.firstHarvestDate,
    this.expectedHarvestDate,
    this.lastHarvestDate,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String plantId; // References Plant.id
  final CropStatus status;
  final String? variety; // Specific variety name
  final String? location; // Where in garden (e.g., "Raised bed 1", "Container")
  final PermacultureZone? zone; // Permaculture zone for garden planning
  final int quantity; // Number of plants

  // Key dates
  final DateTime? startedIndoorsDate;
  final DateTime? hardenedOffDate;
  final DateTime? transplantedDate;
  final DateTime? directSowedDate;
  final DateTime? firstHarvestDate;
  final DateTime? expectedHarvestDate;
  final DateTime? lastHarvestDate;

  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Get the effective plant date (when it went in ground or started)
  DateTime? get effectivePlantDate {
    return transplantedDate ?? directSowedDate ?? startedIndoorsDate;
  }

  /// Days since planted
  int? get daysSincePlanted {
    final plantDate = effectivePlantDate;
    if (plantDate == null) return null;
    return DateTime.now().difference(plantDate).inDays;
  }

  /// Create a copy with updated values
  PlantedCrop copyWith({
    String? id,
    String? plantId,
    CropStatus? status,
    String? variety,
    String? location,
    PermacultureZone? zone,
    int? quantity,
    DateTime? startedIndoorsDate,
    DateTime? hardenedOffDate,
    DateTime? transplantedDate,
    DateTime? directSowedDate,
    DateTime? firstHarvestDate,
    DateTime? expectedHarvestDate,
    DateTime? lastHarvestDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlantedCrop(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      status: status ?? this.status,
      variety: variety ?? this.variety,
      location: location ?? this.location,
      zone: zone ?? this.zone,
      quantity: quantity ?? this.quantity,
      startedIndoorsDate: startedIndoorsDate ?? this.startedIndoorsDate,
      hardenedOffDate: hardenedOffDate ?? this.hardenedOffDate,
      transplantedDate: transplantedDate ?? this.transplantedDate,
      directSowedDate: directSowedDate ?? this.directSowedDate,
      firstHarvestDate: firstHarvestDate ?? this.firstHarvestDate,
      expectedHarvestDate: expectedHarvestDate ?? this.expectedHarvestDate,
      lastHarvestDate: lastHarvestDate ?? this.lastHarvestDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Serialize to JSON for SQLite storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plant_id': plantId,
      'status': status.name,
      'variety': variety,
      'location': location,
      'zone': zone?.name,
      'quantity': quantity,
      'started_indoors_date': startedIndoorsDate?.toIso8601String(),
      'hardened_off_date': hardenedOffDate?.toIso8601String(),
      'transplanted_date': transplantedDate?.toIso8601String(),
      'direct_sowed_date': directSowedDate?.toIso8601String(),
      'first_harvest_date': firstHarvestDate?.toIso8601String(),
      'expected_harvest_date': expectedHarvestDate?.toIso8601String(),
      'last_harvest_date': lastHarvestDate?.toIso8601String(),
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Deserialize from SQLite JSON
  factory PlantedCrop.fromJson(Map<String, dynamic> json) {
    return PlantedCrop(
      id: json['id'] as String,
      plantId: json['plant_id'] as String,
      status: CropStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => CropStatus.planned,
      ),
      variety: json['variety'] as String?,
      location: json['location'] as String?,
      zone: json['zone'] != null
          ? PermacultureZone.values.firstWhere(
              (z) => z.name == json['zone'],
              orElse: () => PermacultureZone.zone2,
            )
          : null,
      quantity: json['quantity'] as int? ?? 1,
      startedIndoorsDate: json['started_indoors_date'] != null
          ? DateTime.parse(json['started_indoors_date'] as String)
          : null,
      hardenedOffDate: json['hardened_off_date'] != null
          ? DateTime.parse(json['hardened_off_date'] as String)
          : null,
      transplantedDate: json['transplanted_date'] != null
          ? DateTime.parse(json['transplanted_date'] as String)
          : null,
      directSowedDate: json['direct_sowed_date'] != null
          ? DateTime.parse(json['direct_sowed_date'] as String)
          : null,
      firstHarvestDate: json['first_harvest_date'] != null
          ? DateTime.parse(json['first_harvest_date'] as String)
          : null,
      expectedHarvestDate: json['expected_harvest_date'] != null
          ? DateTime.parse(json['expected_harvest_date'] as String)
          : null,
      lastHarvestDate: json['last_harvest_date'] != null
          ? DateTime.parse(json['last_harvest_date'] as String)
          : null,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}

/// User's complete garden with all planted crops
class UserGarden {
  const UserGarden({
    this.crops = const [],
    this.lastModified,
  });

  final List<PlantedCrop> crops;
  final DateTime? lastModified;

  /// Get all active crops (currently growing)
  List<PlantedCrop> get activeCrops {
    return crops.where((c) => c.status.isActive).toList();
  }

  /// Get crops that need frost protection
  List<PlantedCrop> get frostSensitiveCrops {
    return crops.where((c) => c.status.needsFrostCheck).toList();
  }

  /// Get crops by status
  List<PlantedCrop> cropsByStatus(CropStatus status) {
    return crops.where((c) => c.status == status).toList();
  }

  /// Get crops by plant ID
  List<PlantedCrop> cropsByPlantId(String plantId) {
    return crops.where((c) => c.plantId == plantId).toList();
  }

  /// Get crops by permaculture zone
  List<PlantedCrop> cropsByZone(PermacultureZone zone) {
    return crops.where((c) => c.zone == zone).toList();
  }

  /// Get crops without a zone assigned
  List<PlantedCrop> cropsWithoutZone() {
    return crops.where((c) => c.zone == null).toList();
  }

  /// Check if a plant is already in the garden
  bool hasPlant(String plantId) {
    return crops.any((c) => c.plantId == plantId && c.status.isActive);
  }

  /// Get count of active crops
  int get activeCropCount => activeCrops.length;

  /// Get count of all crops this season
  int get totalCropCount => crops.length;

  /// Create empty garden
  factory UserGarden.empty() {
    return const UserGarden();
  }

  /// Create copy with updated crops
  UserGarden copyWith({
    List<PlantedCrop>? crops,
    DateTime? lastModified,
  }) {
    return UserGarden(
      crops: crops ?? this.crops,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}

/// Unit of measurement for harvest quantities
enum HarvestUnit {
  pounds('lbs', 'Pounds'),
  kilograms('kg', 'Kilograms'),
  ounces('oz', 'Ounces'),
  grams('g', 'Grams'),
  pieces('pcs', 'Pieces'),
  bunches('bunches', 'Bunches'),
  baskets('baskets', 'Baskets'),
  buckets('buckets', 'Buckets'),
  bags('bags', 'Bags');

  const HarvestUnit(this.abbreviation, this.displayName);
  final String abbreviation;
  final String displayName;
}

/// Quality rating for harvest
enum HarvestQuality {
  poor('Poor', '😞', 'Below expectations'),
  fair('Fair', '😐', 'Acceptable quality'),
  good('Good', '😊', 'Good quality'),
  excellent('Excellent', '🤩', 'Outstanding quality');

  const HarvestQuality(this.displayName, this.emoji, this.description);
  final String displayName;
  final String emoji;
  final String description;
}

/// What was done with the harvest
enum PreservationMethod {
  fresh('Fresh/Eaten', '🍽️'),
  frozen('Frozen', '❄️'),
  canned('Canned', '🥫'),
  dried('Dried', '🌾'),
  curing('Curing', '⏳'),
  trimmed('Trimmed', '✂️'),
  fermented('Fermented', '🫙'),
  stored('Cold Storage', '🧊'),
  shared('Shared/Gifted', '🎁'),
  sold('Sold', '💰'),
  composted('Composted', '♻️'),
  seeds('Saved Seeds', '🌱');

  const PreservationMethod(this.displayName, this.emoji);
  final String displayName;
  final String emoji;
}

/// Type/part of plant harvested
enum HarvestType {
  fruit('Fruit/Flower', '🌸'),
  leaves('Leaves', '🍃'),
  trim('Trim/Sugar Leaves', '✂️'),
  roots('Roots', '🥕'),
  wholePlant('Whole Plant', '🌿'),
  mixed('Mixed', '🌾');

  const HarvestType(this.displayName, this.emoji);
  final String displayName;
  final String emoji;
}

/// Growth stage of a crop when photo was taken
enum PhotoStage {
  seedling('Seedling', '🌱'),
  vegetative('Vegetative', '🌿'),
  flowering('Flowering', '🌸'),
  fruiting('Fruiting', '🍅'),
  harvest('Harvest', '🧺'),
  other('Other', '📷');

  const PhotoStage(this.displayName, this.emoji);
  final String displayName;
  final String emoji;
}

/// A photo of a planted crop at a specific growth stage
class CropPhoto {
  const CropPhoto({
    required this.id,
    required this.cropId,
    required this.filePath,
    required this.capturedAt,
    this.stage,
    this.caption,
    this.createdAt,
  });

  final String id;
  final String cropId; // References PlantedCrop.id
  final String filePath; // Local file path to the photo
  final DateTime capturedAt; // When the photo was taken
  final PhotoStage? stage; // Growth stage
  final String? caption; // Optional user caption
  final DateTime? createdAt; // When record was created

  CropPhoto copyWith({
    String? id,
    String? cropId,
    String? filePath,
    DateTime? capturedAt,
    PhotoStage? stage,
    String? caption,
    DateTime? createdAt,
  }) {
    return CropPhoto(
      id: id ?? this.id,
      cropId: cropId ?? this.cropId,
      filePath: filePath ?? this.filePath,
      capturedAt: capturedAt ?? this.capturedAt,
      stage: stage ?? this.stage,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'crop_id': cropId,
      'file_path': filePath,
      'captured_at': capturedAt.toIso8601String(),
      'stage': stage?.name,
      'caption': caption,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory CropPhoto.fromJson(Map<String, dynamic> json) {
    return CropPhoto(
      id: json['id'] as String,
      cropId: json['crop_id'] as String,
      filePath: json['file_path'] as String,
      capturedAt: DateTime.parse(json['captured_at'] as String),
      stage: json['stage'] != null
          ? PhotoStage.values.firstWhere(
              (s) => s.name == json['stage'],
              orElse: () => PhotoStage.other,
            )
          : null,
      caption: json['caption'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}

/// A single harvest event from a planted crop
class Harvest {
  const Harvest({
    required this.id,
    required this.cropId,
    required this.harvestDate,
    required this.quantity,
    required this.unit,
    this.harvestType,
    this.wetWeight,
    this.wetWeightUnit,
    this.quality,
    this.preservationMethods = const [],
    this.notes,
    this.createdAt,
  });

  final String id;
  final String cropId; // References PlantedCrop.id
  final DateTime harvestDate;
  final double quantity; // Numeric amount (dry weight for plants that need drying)
  final HarvestUnit unit;
  final HarvestType? harvestType; // Type/part harvested (flower, trim, leaves, etc.)
  final double? wetWeight; // Optional wet weight for plants like cannabis
  final HarvestUnit? wetWeightUnit;
  final HarvestQuality? quality;
  final List<PreservationMethod> preservationMethods;
  final String? notes;
  final DateTime? createdAt;

  /// Format quantity with unit
  String get quantityDisplay {
    final dryQty = quantity == quantity.truncateToDouble()
        ? '${quantity.toInt()} ${unit.abbreviation}'
        : '${quantity.toStringAsFixed(1)} ${unit.abbreviation}';

    // Include wet weight if available
    if (wetWeight != null && wetWeightUnit != null) {
      final wetQty = wetWeight == wetWeight!.truncateToDouble()
          ? '${wetWeight!.toInt()} ${wetWeightUnit!.abbreviation}'
          : '${wetWeight!.toStringAsFixed(1)} ${wetWeightUnit!.abbreviation}';
      return '$dryQty (wet: $wetQty)';
    }

    return dryQty;
  }

  /// Format with type if available
  String get fullDisplay {
    final typePrefix = harvestType != null ? '${harvestType!.emoji} ' : '';
    return '$typePrefix$quantityDisplay';
  }

  Harvest copyWith({
    String? id,
    String? cropId,
    DateTime? harvestDate,
    double? quantity,
    HarvestUnit? unit,
    HarvestType? harvestType,
    double? wetWeight,
    HarvestUnit? wetWeightUnit,
    HarvestQuality? quality,
    List<PreservationMethod>? preservationMethods,
    String? notes,
    DateTime? createdAt,
  }) {
    return Harvest(
      id: id ?? this.id,
      cropId: cropId ?? this.cropId,
      harvestDate: harvestDate ?? this.harvestDate,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      harvestType: harvestType ?? this.harvestType,
      wetWeight: wetWeight ?? this.wetWeight,
      wetWeightUnit: wetWeightUnit ?? this.wetWeightUnit,
      quality: quality ?? this.quality,
      preservationMethods: preservationMethods ?? this.preservationMethods,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'crop_id': cropId,
      'harvest_date': harvestDate.toIso8601String(),
      'quantity': quantity,
      'unit': unit.name,
      'harvest_type': harvestType?.name,
      'wet_weight': wetWeight,
      'wet_weight_unit': wetWeightUnit?.name,
      'quality': quality?.name,
      'preservation_methods': preservationMethods.map((m) => m.name).join(','),
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory Harvest.fromJson(Map<String, dynamic> json) {
    return Harvest(
      id: json['id'] as String,
      cropId: json['crop_id'] as String,
      harvestDate: DateTime.parse(json['harvest_date'] as String),
      quantity: (json['quantity'] as num).toDouble(),
      unit: HarvestUnit.values.firstWhere(
        (u) => u.name == json['unit'],
        orElse: () => HarvestUnit.pounds,
      ),
      harvestType: json['harvest_type'] != null
          ? HarvestType.values.firstWhere(
              (t) => t.name == json['harvest_type'],
              orElse: () => HarvestType.fruit,
            )
          : null,
      wetWeight: json['wet_weight'] != null ? (json['wet_weight'] as num).toDouble() : null,
      wetWeightUnit: json['wet_weight_unit'] != null
          ? HarvestUnit.values.firstWhere(
              (u) => u.name == json['wet_weight_unit'],
              orElse: () => HarvestUnit.grams,
            )
          : null,
      quality: json['quality'] != null
          ? HarvestQuality.values.firstWhere(
              (q) => q.name == json['quality'],
              orElse: () => HarvestQuality.good,
            )
          : null,
      preservationMethods: json['preservation_methods'] != null && json['preservation_methods'] != ''
          ? (json['preservation_methods'] as String).split(',').map((m) {
              return PreservationMethod.values.firstWhere(
                (pm) => pm.name == m,
                orElse: () => PreservationMethod.fresh,
              );
            }).toList()
          : [],
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}
