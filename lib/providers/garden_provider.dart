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

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final dbFilePath = path.join(dbPath, _dbName);

    return openDatabase(
      dbFilePath,
      version: 3,
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
