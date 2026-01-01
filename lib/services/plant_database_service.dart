/// Plant database service for the Cultivation tab
/// Provides access to the comprehensive plant database with search and filtering
library;

import '../models/plant.dart';
import '../data/plants/vegetables.dart';
import '../data/plants/fruits.dart';
import '../data/plants/berries.dart';
import '../data/plants/herbs.dart';
import '../data/plants/roses.dart';
import '../data/plants/bees.dart';
import '../data/plants/medicinal.dart';

/// Service for accessing and querying the plant database
class PlantDatabaseService {
  PlantDatabaseService();

  /// Cached combined plant list
  List<Plant>? _allPlants;

  /// Get all plants from all categories
  List<Plant> getAllPlants() {
    _allPlants ??= [
      ...vegetables,
      ...fruits,
      ...berries,
      ...herbs,
      ...roses,
      ...bees,
      ...medicinalPlants,
    ];
    return _allPlants!;
  }

  /// Get plants by category
  List<Plant> getPlantsByCategory(PlantCategory category) {
    return switch (category) {
      PlantCategory.vegetable => vegetables,
      PlantCategory.fruit => fruits,
      PlantCategory.berry => berries,
      PlantCategory.herb => herbs,
      PlantCategory.rose => roses,
      PlantCategory.bees => bees,
    };
  }

  /// Get a plant by its ID
  Plant? getPlantById(String id) {
    final plants = getAllPlants();
    try {
      return plants.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Search plants by name (common name or scientific name)
  List<Plant> searchPlants(String query) {
    if (query.isEmpty) return getAllPlants();

    final lowerQuery = query.toLowerCase();
    return getAllPlants().where((plant) {
      return plant.commonName.toLowerCase().contains(lowerQuery) ||
          (plant.scientificName?.toLowerCase().contains(lowerQuery) ?? false) ||
          plant.varieties.any((v) => v.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Get plants optimal for a given moon sign (biodynamic gardening)
  List<Plant> getPlantsForMoonSign(String moonSign) {
    return getAllPlants()
        .where((plant) => plant.bestMoonSigns.contains(moonSign))
        .toList();
  }

  /// Get plants optimal for a given moon phase
  List<Plant> getPlantsForMoonPhase(MoonPhasePreference phase) {
    if (phase == MoonPhasePreference.any) return getAllPlants();
    return getAllPlants()
        .where((plant) =>
            plant.bestMoonPhase == phase ||
            plant.bestMoonPhase == MoonPhasePreference.any)
        .toList();
  }

  /// Get plants by plant part (for biodynamic element days)
  List<Plant> getPlantsByPart(PlantPart part) {
    return getAllPlants().where((plant) => plant.plantPart == part).toList();
  }

  /// Get frost-tolerant plants (can be planted before last frost)
  List<Plant> getFrostTolerantPlants() {
    return getAllPlants().where((plant) => plant.isFrostTolerant).toList();
  }

  /// Get freeze-tolerant plants (extremely cold hardy)
  List<Plant> getFreezeTolerantPlants() {
    return getAllPlants().where((plant) => plant.isFreezeTolerant).toList();
  }

  /// Get tender plants (need frost protection)
  List<Plant> getTenderPlants() {
    return getAllPlants()
        .where((plant) => !plant.isFrostTolerant && plant.minTempTolerance > 32)
        .toList();
  }

  /// Get plants that can be started indoors
  List<Plant> getIndoorStartPlants() {
    return getAllPlants()
        .where((plant) => plant.indoorStartWeeks != null)
        .toList();
  }

  /// Get plants that can be direct sowed
  List<Plant> getDirectSowPlants() {
    return getAllPlants()
        .where((plant) =>
            plant.directSowWeeksBeforeFrost != null ||
            plant.directSowWeeksAfterFrost != null)
        .toList();
  }

  /// Get plants with medicinal uses
  List<Plant> getMedicinalPlants() {
    return getAllPlants()
        .where((plant) => plant.medicinalUses.isNotEmpty)
        .toList();
  }

  /// Get plants with edible parts
  List<Plant> getEdiblePlants() {
    return getAllPlants()
        .where((plant) => plant.edibleParts.isNotEmpty)
        .toList();
  }

  /// Get native plants
  List<Plant> getNativePlants() {
    return getAllPlants().where((plant) => plant.isNative).toList();
  }

  /// Get heirloom/antique varieties
  List<Plant> getHeirloomPlants() {
    return getAllPlants().where((plant) => plant.isHeirloom).toList();
  }

  /// Get plants suitable for indoor growing
  List<Plant> getIndoorGrowablePlants() {
    return getAllPlants().where((plant) => plant.canGrowIndoors).toList();
  }

  /// Get plants that should be started indoors NOW based on frost date
  List<Plant> getPlantsToStartIndoorsNow(DateTime lastFrostDate) {
    final now = DateTime.now();
    final weeksUntilFrost = lastFrostDate.difference(now).inDays ~/ 7;

    return getIndoorStartPlants().where((plant) {
      final startWeeks = plant.indoorStartWeeks!;
      // Should start if we're within the window (give 1 week buffer)
      return weeksUntilFrost <= startWeeks && weeksUntilFrost >= startWeeks - 2;
    }).toList();
  }

  /// Get plants that can be transplanted NOW based on frost date
  List<Plant> getPlantsToTransplantNow(DateTime lastFrostDate) {
    final now = DateTime.now();
    final weeksSinceFrost = now.difference(lastFrostDate).inDays ~/ 7;

    if (now.isBefore(lastFrostDate)) {
      // Before last frost - only frost-tolerant transplants
      final weeksBeforeFrost = lastFrostDate.difference(now).inDays ~/ 7;
      return getAllPlants().where((plant) {
        if (plant.transplantWeeksBeforeFrost == null) return false;
        return weeksBeforeFrost <= plant.transplantWeeksBeforeFrost! &&
            weeksBeforeFrost >= plant.transplantWeeksBeforeFrost! - 2;
      }).toList();
    } else {
      // After last frost - warm season transplants
      return getAllPlants().where((plant) {
        if (plant.transplantWeeksAfterFrost == null) return false;
        return weeksSinceFrost >= plant.transplantWeeksAfterFrost! &&
            weeksSinceFrost <= plant.transplantWeeksAfterFrost! + 2;
      }).toList();
    }
  }

  /// Get plants that can be direct sowed NOW based on frost date
  List<Plant> getPlantsToDirectSowNow(DateTime lastFrostDate) {
    final now = DateTime.now();

    if (now.isBefore(lastFrostDate)) {
      // Before last frost - cold hardy direct sow
      final weeksBeforeFrost = lastFrostDate.difference(now).inDays ~/ 7;
      return getAllPlants().where((plant) {
        if (plant.directSowWeeksBeforeFrost == null) return false;
        return weeksBeforeFrost <= plant.directSowWeeksBeforeFrost! &&
            weeksBeforeFrost >= 0;
      }).toList();
    } else {
      // After last frost - warm season direct sow
      final weeksSinceFrost = now.difference(lastFrostDate).inDays ~/ 7;
      return getAllPlants().where((plant) {
        if (plant.directSowWeeksAfterFrost == null) return false;
        return weeksSinceFrost >= plant.directSowWeeksAfterFrost! &&
            weeksSinceFrost <= plant.directSowWeeksAfterFrost! + 4;
      }).toList();
    }
  }

  /// Get companion plants for a given plant
  List<Plant> getCompanionPlants(Plant plant) {
    final companionNames =
        plant.companionPlants.map((c) => c.toLowerCase()).toSet();
    return getAllPlants().where((p) {
      return companionNames.contains(p.commonName.toLowerCase()) ||
          p.varieties.any((v) => companionNames.contains(v.toLowerCase()));
    }).toList();
  }

  /// Get plants to avoid planting near a given plant
  List<Plant> getIncompatiblePlants(Plant plant) {
    final avoidNames =
        plant.avoidPlanting.map((a) => a.toLowerCase()).toSet();
    return getAllPlants().where((p) {
      return avoidNames.contains(p.commonName.toLowerCase()) ||
          p.varieties.any((v) => avoidNames.contains(v.toLowerCase()));
    }).toList();
  }

  /// Get statistics about the database
  Map<String, int> getDatabaseStats() {
    final all = getAllPlants();
    return {
      'total': all.length,
      'vegetables': vegetables.length,
      'fruits': fruits.length,
      'berries': berries.length,
      'herbs': herbs.length,
      'roses': roses.length,
      'bees': bees.length,
      'medicinal': getMedicinalPlants().length,
      'native': getNativePlants().length,
      'heirloom': getHeirloomPlants().length,
      'indoor': getIndoorGrowablePlants().length,
    };
  }
}
