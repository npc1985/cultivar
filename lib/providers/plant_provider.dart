/// Riverpod providers for the plant database
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/plant.dart';
import '../services/plant_database_service.dart';

/// Provider for the plant database service
final plantDatabaseServiceProvider = Provider<PlantDatabaseService>((ref) {
  return PlantDatabaseService();
});

/// Provider for all plants
final allPlantsProvider = Provider<List<Plant>>((ref) {
  final service = ref.watch(plantDatabaseServiceProvider);
  return service.getAllPlants();
});

/// Provider for plants by category
final plantsByCategoryProvider =
    Provider.family<List<Plant>, PlantCategory>((ref, category) {
  final service = ref.watch(plantDatabaseServiceProvider);
  return service.getPlantsByCategory(category);
});

/// Provider for a single plant by ID
final plantByIdProvider = Provider.family<Plant?, String>((ref, id) {
  final service = ref.watch(plantDatabaseServiceProvider);
  return service.getPlantById(id);
});

/// State provider for search query
final plantSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for search results
final plantSearchResultsProvider = Provider<List<Plant>>((ref) {
  final query = ref.watch(plantSearchQueryProvider);
  final service = ref.watch(plantDatabaseServiceProvider);

  if (query.isEmpty) {
    return service.getAllPlants();
  }
  return service.searchPlants(query);
});

/// State provider for selected category filter
final selectedPlantCategoryProvider = StateProvider<PlantCategory?>((ref) => null);

/// Provider for filtered plants (by category if selected, otherwise all)
final filteredPlantsProvider = Provider<List<Plant>>((ref) {
  final category = ref.watch(selectedPlantCategoryProvider);
  final searchQuery = ref.watch(plantSearchQueryProvider);
  final service = ref.watch(plantDatabaseServiceProvider);

  List<Plant> plants;
  if (category != null) {
    plants = service.getPlantsByCategory(category);
  } else {
    plants = service.getAllPlants();
  }

  if (searchQuery.isNotEmpty) {
    final lowerQuery = searchQuery.toLowerCase();
    plants = plants.where((plant) {
      return plant.commonName.toLowerCase().contains(lowerQuery) ||
          (plant.scientificName?.toLowerCase().contains(lowerQuery) ?? false) ||
          plant.varieties.any((v) => v.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  return plants;
});

/// Provider for plants with medicinal uses
final medicinalPlantsProvider = Provider<List<Plant>>((ref) {
  final service = ref.watch(plantDatabaseServiceProvider);
  return service.getMedicinalPlants();
});

/// Provider for native plants
final nativePlantsProvider = Provider<List<Plant>>((ref) {
  final service = ref.watch(plantDatabaseServiceProvider);
  return service.getNativePlants();
});

/// Provider for heirloom plants
final heirloomPlantsProvider = Provider<List<Plant>>((ref) {
  final service = ref.watch(plantDatabaseServiceProvider);
  return service.getHeirloomPlants();
});

/// Provider for frost-tolerant plants
final frostTolerantPlantsProvider = Provider<List<Plant>>((ref) {
  final service = ref.watch(plantDatabaseServiceProvider);
  return service.getFrostTolerantPlants();
});

/// Provider for plants that can grow indoors
final indoorGrowablePlantsProvider = Provider<List<Plant>>((ref) {
  final service = ref.watch(plantDatabaseServiceProvider);
  return service.getIndoorGrowablePlants();
});

/// Provider for database statistics
final plantDatabaseStatsProvider = Provider<Map<String, int>>((ref) {
  final service = ref.watch(plantDatabaseServiceProvider);
  return service.getDatabaseStats();
});

/// Provider for plants optimal for current moon sign
final plantsForCurrentMoonSignProvider =
    Provider.family<List<Plant>, String>((ref, moonSign) {
  final service = ref.watch(plantDatabaseServiceProvider);
  return service.getPlantsForMoonSign(moonSign);
});

/// Provider for companion plants of a given plant
final companionPlantsProvider =
    Provider.family<List<Plant>, Plant>((ref, plant) {
  final service = ref.watch(plantDatabaseServiceProvider);
  return service.getCompanionPlants(plant);
});

/// Provider for incompatible plants (plants to avoid near a given plant)
final incompatiblePlantsProvider =
    Provider.family<List<Plant>, Plant>((ref, plant) {
  final service = ref.watch(plantDatabaseServiceProvider);
  return service.getIncompatiblePlants(plant);
});
