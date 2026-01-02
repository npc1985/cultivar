/// Riverpod providers for garden tracking with SQLite persistence
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import '../models/garden.dart';
import '../models/plant.dart';
import 'plant_provider.dart';

/// Database helper for garden storage
class GardenDatabase {
  static Database? _database;
  static const _dbName = 'garden.db';
  static const _tableName = 'planted_crops';
  static const _locationsTable = 'garden_locations';
  static const _completedTasksTable = 'completed_tasks';
  static const _harvestsTable = 'harvests';

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final dbFilePath = path.join(dbPath, _dbName);

    return openDatabase(
      dbFilePath,
      version: 6,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            plant_id TEXT NOT NULL,
            status TEXT NOT NULL,
            variety TEXT,
            location TEXT,
            zone TEXT,
            quantity INTEGER DEFAULT 1,
            started_indoors_date TEXT,
            hardened_off_date TEXT,
            transplanted_date TEXT,
            direct_sowed_date TEXT,
            first_harvest_date TEXT,
            expected_harvest_date TEXT,
            last_harvest_date TEXT,
            notes TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE $_locationsTable (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT,
            zone TEXT,
            icon TEXT,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE $_completedTasksTable (
            task_id TEXT PRIMARY KEY,
            completed_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE $_harvestsTable (
            id TEXT PRIMARY KEY,
            crop_id TEXT NOT NULL,
            harvest_date TEXT NOT NULL,
            quantity REAL NOT NULL,
            unit TEXT NOT NULL,
            harvest_type TEXT,
            wet_weight REAL,
            wet_weight_unit TEXT,
            quality TEXT,
            preservation_methods TEXT,
            notes TEXT,
            created_at TEXT NOT NULL,
            FOREIGN KEY (crop_id) REFERENCES $_tableName (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE INDEX idx_harvests_crop_id ON $_harvestsTable (crop_id)
        ''');
        await db.execute('''
          CREATE INDEX idx_harvests_date ON $_harvestsTable (harvest_date)
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE $_tableName ADD COLUMN zone TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS $_locationsTable (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              description TEXT,
              zone TEXT,
              icon TEXT,
              created_at TEXT NOT NULL
            )
          ''');
        }
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS $_completedTasksTable (
              task_id TEXT PRIMARY KEY,
              completed_at TEXT NOT NULL
            )
          ''');
        }
        if (oldVersion < 5) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS $_harvestsTable (
              id TEXT PRIMARY KEY,
              crop_id TEXT NOT NULL,
              harvest_date TEXT NOT NULL,
              quantity REAL NOT NULL,
              unit TEXT NOT NULL,
              quality TEXT,
              preservation_methods TEXT,
              notes TEXT,
              created_at TEXT NOT NULL,
              FOREIGN KEY (crop_id) REFERENCES $_tableName (id) ON DELETE CASCADE
            )
          ''');
          await db.execute('''
            CREATE INDEX IF NOT EXISTS idx_harvests_crop_id ON $_harvestsTable (crop_id)
          ''');
          await db.execute('''
            CREATE INDEX IF NOT EXISTS idx_harvests_date ON $_harvestsTable (harvest_date)
          ''');
        }
        if (oldVersion < 6) {
          // Add harvest type and wet weight columns
          await db.execute('ALTER TABLE $_harvestsTable ADD COLUMN harvest_type TEXT');
          await db.execute('ALTER TABLE $_harvestsTable ADD COLUMN wet_weight REAL');
          await db.execute('ALTER TABLE $_harvestsTable ADD COLUMN wet_weight_unit TEXT');
        }
      },
    );
  }

  // Location CRUD operations
  static Future<List<GardenLocation>> getAllLocations() async {
    final db = await database;
    final maps = await db.query(_locationsTable, orderBy: 'name ASC');
    return maps.map((map) => GardenLocation.fromJson(map)).toList();
  }

  static Future<void> insertLocation(GardenLocation location) async {
    final db = await database;
    final data = location.toJson();
    data['created_at'] = DateTime.now().toIso8601String();
    await db.insert(_locationsTable, data);
  }

  static Future<void> updateLocation(GardenLocation location) async {
    final db = await database;
    await db.update(
      _locationsTable,
      location.toJson(),
      where: 'id = ?',
      whereArgs: [location.id],
    );
  }

  static Future<void> deleteLocation(String id) async {
    final db = await database;
    await db.delete(_locationsTable, where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<PlantedCrop>> getAllCrops() async {
    final db = await database;
    final maps = await db.query(_tableName, orderBy: 'created_at DESC');
    return maps.map((map) => PlantedCrop.fromJson(map)).toList();
  }

  static Future<PlantedCrop?> getCrop(String id) async {
    final db = await database;
    final maps = await db.query(_tableName, where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return PlantedCrop.fromJson(maps.first);
  }

  static Future<void> insertCrop(PlantedCrop crop) async {
    final db = await database;
    final now = DateTime.now();
    final data = crop.toJson();
    data['created_at'] = now.toIso8601String();
    data['updated_at'] = now.toIso8601String();
    await db.insert(_tableName, data);
  }

  static Future<void> updateCrop(PlantedCrop crop) async {
    final db = await database;
    final data = crop.toJson();
    data['updated_at'] = DateTime.now().toIso8601String();
    await db.update(
      _tableName,
      data,
      where: 'id = ?',
      whereArgs: [crop.id],
    );
  }

  static Future<void> deleteCrop(String id) async {
    final db = await database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteAllCrops() async {
    final db = await database;
    await db.delete(_tableName);
  }

  // Completed task operations
  static Future<Set<String>> getCompletedTaskIds() async {
    final db = await database;
    final maps = await db.query(_completedTasksTable);
    return maps.map((map) => map['task_id'] as String).toSet();
  }

  static Future<void> markTaskComplete(String taskId) async {
    final db = await database;
    await db.insert(
      _completedTasksTable,
      {
        'task_id': taskId,
        'completed_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> unmarkTaskComplete(String taskId) async {
    final db = await database;
    await db.delete(
      _completedTasksTable,
      where: 'task_id = ?',
      whereArgs: [taskId],
    );
  }

  // Harvest CRUD operations
  static Future<List<Harvest>> getAllHarvests() async {
    final db = await database;
    final maps = await db.query(_harvestsTable, orderBy: 'harvest_date DESC');
    return maps.map((map) => Harvest.fromJson(map)).toList();
  }

  static Future<List<Harvest>> getHarvestsForCrop(String cropId) async {
    final db = await database;
    final maps = await db.query(
      _harvestsTable,
      where: 'crop_id = ?',
      whereArgs: [cropId],
      orderBy: 'harvest_date DESC',
    );
    return maps.map((map) => Harvest.fromJson(map)).toList();
  }

  static Future<List<Harvest>> getHarvestsInDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final maps = await db.query(
      _harvestsTable,
      where: 'harvest_date >= ? AND harvest_date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'harvest_date DESC',
    );
    return maps.map((map) => Harvest.fromJson(map)).toList();
  }

  static Future<void> insertHarvest(Harvest harvest) async {
    final db = await database;
    final data = harvest.toJson();
    data['created_at'] = DateTime.now().toIso8601String();
    await db.insert(_harvestsTable, data);
  }

  static Future<void> updateHarvest(Harvest harvest) async {
    final db = await database;
    await db.update(
      _harvestsTable,
      harvest.toJson(),
      where: 'id = ?',
      whereArgs: [harvest.id],
    );
  }

  static Future<void> deleteHarvest(String id) async {
    final db = await database;
    await db.delete(_harvestsTable, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteHarvestsForCrop(String cropId) async {
    final db = await database;
    await db.delete(_harvestsTable, where: 'crop_id = ?', whereArgs: [cropId]);
  }
}

/// State notifier for managing garden crops
class GardenNotifier extends AsyncNotifier<List<PlantedCrop>> {
  @override
  Future<List<PlantedCrop>> build() async {
    return GardenDatabase.getAllCrops();
  }

  /// Add a new crop to the garden
  Future<void> addCrop(PlantedCrop crop) async {
    await GardenDatabase.insertCrop(crop);
    state = AsyncData(await GardenDatabase.getAllCrops());
  }

  /// Update an existing crop
  Future<void> updateCrop(PlantedCrop crop) async {
    await GardenDatabase.updateCrop(crop);
    state = AsyncData(await GardenDatabase.getAllCrops());
  }

  /// Update crop status
  Future<void> updateStatus(String cropId, CropStatus newStatus) async {
    final crops = state.valueOrNull ?? [];
    final crop = crops.firstWhere((c) => c.id == cropId);

    final now = DateTime.now();
    final updated = crop.copyWith(
      status: newStatus,
      startedIndoorsDate: newStatus == CropStatus.startedIndoors
          ? now
          : crop.startedIndoorsDate,
      hardenedOffDate: newStatus == CropStatus.hardeningOff
          ? now
          : crop.hardenedOffDate,
      transplantedDate: newStatus == CropStatus.transplanted
          ? now
          : crop.transplantedDate,
      directSowedDate: newStatus == CropStatus.directSowed
          ? now
          : crop.directSowedDate,
      firstHarvestDate: newStatus == CropStatus.harvesting && crop.firstHarvestDate == null
          ? now
          : crop.firstHarvestDate,
      lastHarvestDate: newStatus == CropStatus.completed
          ? now
          : crop.lastHarvestDate,
    );

    await GardenDatabase.updateCrop(updated);
    state = AsyncData(await GardenDatabase.getAllCrops());
  }

  /// Update crop permaculture zone
  Future<void> updateZone(String cropId, PermacultureZone? zone) async {
    final crops = state.valueOrNull ?? [];
    final crop = crops.firstWhere((c) => c.id == cropId);

    final updated = crop.copyWith(zone: zone);
    await GardenDatabase.updateCrop(updated);
    state = AsyncData(await GardenDatabase.getAllCrops());
  }

  /// Update crop location
  Future<void> updateLocation(String cropId, String? location) async {
    final crops = state.valueOrNull ?? [];
    final crop = crops.firstWhere((c) => c.id == cropId);

    final updated = crop.copyWith(location: location);
    await GardenDatabase.updateCrop(updated);
    state = AsyncData(await GardenDatabase.getAllCrops());
  }

  /// Update crop quantity
  Future<void> updateQuantity(String cropId, int quantity) async {
    final crops = state.valueOrNull ?? [];
    final crop = crops.firstWhere((c) => c.id == cropId);

    final updated = crop.copyWith(quantity: quantity);
    await GardenDatabase.updateCrop(updated);
    state = AsyncData(await GardenDatabase.getAllCrops());
  }

  /// Delete a crop from the garden
  Future<void> deleteCrop(String cropId) async {
    await GardenDatabase.deleteCrop(cropId);
    state = AsyncData(await GardenDatabase.getAllCrops());
  }

  /// Clear all crops
  Future<void> clearGarden() async {
    await GardenDatabase.deleteAllCrops();
    state = const AsyncData([]);
  }

  /// Quick add a plant to garden with default status
  Future<void> quickAddPlant(String plantId) async {
    final crop = PlantedCrop(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      plantId: plantId,
      status: CropStatus.planned,
      quantity: 1,
    );
    await addCrop(crop);
  }
}

/// Main garden provider
final gardenProvider = AsyncNotifierProvider<GardenNotifier, List<PlantedCrop>>(() {
  return GardenNotifier();
});

/// Set of plant IDs currently in the garden
final gardenPlantIdsProvider = Provider<Set<String>>((ref) {
  final cropsAsync = ref.watch(gardenProvider);
  return cropsAsync.when(
    data: (crops) => crops.map((c) => c.plantId).toSet(),
    loading: () => {},
    error: (_, _) => {},
  );
});

/// Active crops (not completed or failed)
final activeCropsProvider = Provider<List<PlantedCrop>>((ref) {
  final cropsAsync = ref.watch(gardenProvider);
  return cropsAsync.when(
    data: (crops) => crops.where((c) => c.status.needsFrostCheck).toList(),
    loading: () => [],
    error: (_, _) => [],
  );
});

/// Crops grouped by status
final cropsByStatusProvider = Provider<Map<CropStatus, List<PlantedCrop>>>((ref) {
  final cropsAsync = ref.watch(gardenProvider);
  return cropsAsync.when(
    data: (crops) {
      final grouped = <CropStatus, List<PlantedCrop>>{};
      for (final status in CropStatus.values) {
        grouped[status] = crops.where((c) => c.status == status).toList();
      }
      return grouped;
    },
    loading: () => {},
    error: (_, _) => {},
  );
});

/// Garden statistics
final gardenStatsProvider = Provider<Map<String, int>>((ref) {
  final cropsAsync = ref.watch(gardenProvider);
  return cropsAsync.when(
    data: (crops) {
      return {
        'total': crops.length,
        'planned': crops.where((c) => c.status == CropStatus.planned).length,
        'startedIndoors': crops.where((c) => c.status == CropStatus.startedIndoors).length,
        'hardeningOff': crops.where((c) => c.status == CropStatus.hardeningOff).length,
        'transplanted': crops.where((c) => c.status == CropStatus.transplanted).length,
        'growing': crops.where((c) => c.status == CropStatus.growing).length,
        'harvesting': crops.where((c) => c.status == CropStatus.harvesting).length,
        'completed': crops.where((c) => c.status == CropStatus.completed).length,
        'failed': crops.where((c) => c.status == CropStatus.failed).length,
      };
    },
    loading: () => {'total': 0},
    error: (_, _) => {'total': 0},
  );
});

/// Enhanced planted crop with plant data
class PlantedCropWithPlant {
  final PlantedCrop crop;
  final Plant? plant;

  PlantedCropWithPlant({required this.crop, this.plant});
}

/// Crops with plant data
final cropsWithPlantDataProvider = Provider<List<PlantedCropWithPlant>>((ref) {
  final cropsAsync = ref.watch(gardenProvider);
  final allPlants = ref.watch(allPlantsProvider);

  return cropsAsync.when(
    data: (crops) {
      return crops.map((crop) {
        final plant = allPlants.where((p) => p.id == crop.plantId).firstOrNull;
        return PlantedCropWithPlant(crop: crop, plant: plant);
      }).toList();
    },
    loading: () => [],
    error: (_, _) => [],
  );
});

/// Active crops with plant data (for frost warnings, etc)
final activeCropsWithPlantDataProvider = Provider<List<PlantedCropWithPlant>>((ref) {
  final all = ref.watch(cropsWithPlantDataProvider);
  return all.where((c) => c.crop.status.needsFrostCheck).toList();
});

// ==================== Location Management ====================

/// State notifier for managing garden locations
class LocationNotifier extends AsyncNotifier<List<GardenLocation>> {
  @override
  Future<List<GardenLocation>> build() async {
    return GardenDatabase.getAllLocations();
  }

  /// Add a new location
  Future<void> addLocation(GardenLocation location) async {
    await GardenDatabase.insertLocation(location);
    state = AsyncData(await GardenDatabase.getAllLocations());
  }

  /// Update an existing location
  Future<void> updateLocation(GardenLocation location) async {
    await GardenDatabase.updateLocation(location);
    state = AsyncData(await GardenDatabase.getAllLocations());
  }

  /// Delete a location
  Future<void> deleteLocation(String locationId) async {
    await GardenDatabase.deleteLocation(locationId);
    state = AsyncData(await GardenDatabase.getAllLocations());
  }

  /// Create a new location with a unique ID
  Future<void> createLocation({
    required String name,
    String? description,
    PermacultureZone? zone,
    String? icon,
  }) async {
    final location = GardenLocation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      zone: zone,
      icon: icon ?? '📍',
    );
    await addLocation(location);
  }
}

/// Main locations provider
final locationsProvider = AsyncNotifierProvider<LocationNotifier, List<GardenLocation>>(() {
  return LocationNotifier();
});

/// Location names for easy lookup
final locationNamesProvider = Provider<Map<String, String>>((ref) {
  final locationsAsync = ref.watch(locationsProvider);
  return locationsAsync.when(
    data: (locations) => {for (final loc in locations) loc.id: loc.name},
    loading: () => {},
    error: (_, _) => {},
  );
});

/// Crops grouped by location
final cropsByLocationProvider = Provider<Map<String?, List<PlantedCrop>>>((ref) {
  final cropsAsync = ref.watch(gardenProvider);
  return cropsAsync.when(
    data: (crops) {
      final grouped = <String?, List<PlantedCrop>>{};
      for (final crop in crops) {
        grouped.putIfAbsent(crop.location, () => []).add(crop);
      }
      return grouped;
    },
    loading: () => {},
    error: (_, _) => {},
  );
});

/// Task completion notifier
class TaskCompletionNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    return GardenDatabase.getCompletedTaskIds();
  }

  Future<void> markComplete(String taskId) async {
    await GardenDatabase.markTaskComplete(taskId);
    state = AsyncData(await GardenDatabase.getCompletedTaskIds());
  }

  Future<void> unmarkComplete(String taskId) async {
    await GardenDatabase.unmarkTaskComplete(taskId);
    state = AsyncData(await GardenDatabase.getCompletedTaskIds());
  }
}

/// Completed task IDs provider
final completedTaskIdsProvider = AsyncNotifierProvider<TaskCompletionNotifier, Set<String>>(() {
  return TaskCompletionNotifier();
});

// ==================== Harvest Management ====================

/// State notifier for managing harvests
class HarvestNotifier extends AsyncNotifier<List<Harvest>> {
  @override
  Future<List<Harvest>> build() async {
    return GardenDatabase.getAllHarvests();
  }

  /// Add a new harvest
  Future<void> addHarvest(Harvest harvest) async {
    await GardenDatabase.insertHarvest(harvest);
    state = AsyncData(await GardenDatabase.getAllHarvests());
  }

  /// Update an existing harvest
  Future<void> updateHarvest(Harvest harvest) async {
    await GardenDatabase.updateHarvest(harvest);
    state = AsyncData(await GardenDatabase.getAllHarvests());
  }

  /// Delete a harvest
  Future<void> deleteHarvest(String harvestId) async {
    await GardenDatabase.deleteHarvest(harvestId);
    state = AsyncData(await GardenDatabase.getAllHarvests());
  }

  /// Quick add harvest with current date
  Future<void> quickAddHarvest({
    required String cropId,
    required double quantity,
    required HarvestUnit unit,
    HarvestType? harvestType,
    double? wetWeight,
    HarvestUnit? wetWeightUnit,
    HarvestQuality? quality,
    List<PreservationMethod>? preservationMethods,
    String? notes,
  }) async {
    final harvest = Harvest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cropId: cropId,
      harvestDate: DateTime.now(),
      quantity: quantity,
      unit: unit,
      harvestType: harvestType,
      wetWeight: wetWeight,
      wetWeightUnit: wetWeightUnit,
      quality: quality,
      preservationMethods: preservationMethods ?? [],
      notes: notes,
    );
    await addHarvest(harvest);
  }
}

/// Main harvests provider
final harvestsProvider = AsyncNotifierProvider<HarvestNotifier, List<Harvest>>(() {
  return HarvestNotifier();
});

/// Harvests for a specific crop
final harvestsForCropProvider = Provider.family<List<Harvest>, String>((ref, cropId) {
  final harvestsAsync = ref.watch(harvestsProvider);
  return harvestsAsync.when(
    data: (harvests) => harvests.where((h) => h.cropId == cropId).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Total harvest quantity by unit for a crop
final totalHarvestByCropProvider = Provider.family<Map<HarvestUnit, double>, String>((ref, cropId) {
  final harvests = ref.watch(harvestsForCropProvider(cropId));
  final totals = <HarvestUnit, double>{};

  for (final harvest in harvests) {
    totals[harvest.unit] = (totals[harvest.unit] ?? 0) + harvest.quantity;
  }

  return totals;
});

/// Recent harvests (last 30 days)
final recentHarvestsProvider = Provider<List<Harvest>>((ref) {
  final harvestsAsync = ref.watch(harvestsProvider);
  final cutoff = DateTime.now().subtract(const Duration(days: 30));

  return harvestsAsync.when(
    data: (harvests) => harvests.where((h) => h.harvestDate.isAfter(cutoff)).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Harvest statistics
final harvestStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final harvestsAsync = ref.watch(harvestsProvider);

  return harvestsAsync.when(
    data: (harvests) {
      if (harvests.isEmpty) {
        return {
          'totalHarvests': 0,
          'totalCrops': 0,
          'thisWeek': 0,
          'thisMonth': 0,
          'thisYear': 0,
        };
      }

      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final monthAgo = now.subtract(const Duration(days: 30));
      final yearStart = DateTime(now.year, 1, 1);

      return {
        'totalHarvests': harvests.length,
        'totalCrops': harvests.map((h) => h.cropId).toSet().length,
        'thisWeek': harvests.where((h) => h.harvestDate.isAfter(weekAgo)).length,
        'thisMonth': harvests.where((h) => h.harvestDate.isAfter(monthAgo)).length,
        'thisYear': harvests.where((h) => h.harvestDate.isAfter(yearStart)).length,
        'earliestHarvest': harvests.last.harvestDate,
        'latestHarvest': harvests.first.harvestDate,
      };
    },
    loading: () => {'totalHarvests': 0},
    error: (_, __) => {'totalHarvests': 0},
  );
});

/// Enhanced harvest with crop and plant data
class HarvestWithDetails {
  final Harvest harvest;
  final PlantedCrop? crop;
  final Plant? plant;

  HarvestWithDetails({
    required this.harvest,
    this.crop,
    this.plant,
  });
}

/// Harvests with full crop and plant details
final harvestsWithDetailsProvider = Provider<List<HarvestWithDetails>>((ref) {
  final harvestsAsync = ref.watch(harvestsProvider);
  final cropsAsync = ref.watch(gardenProvider);
  final allPlants = ref.watch(allPlantsProvider);

  return harvestsAsync.when(
    data: (harvests) {
      return cropsAsync.when(
        data: (crops) {
          return harvests.map((harvest) {
            final crop = crops.where((c) => c.id == harvest.cropId).firstOrNull;
            final plant = crop != null
                ? allPlants.where((p) => p.id == crop.plantId).firstOrNull
                : null;
            return HarvestWithDetails(
              harvest: harvest,
              crop: crop,
              plant: plant,
            );
          }).toList();
        },
        loading: () => harvests.map((h) => HarvestWithDetails(harvest: h)).toList(),
        error: (_, __) => harvests.map((h) => HarvestWithDetails(harvest: h)).toList(),
      );
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
