/// Riverpod providers for garden analytics and insights
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analytics.dart';
import '../models/garden.dart';
import '../models/plant.dart';
import 'garden_provider.dart';
import 'plant_provider.dart';

/// Main analytics provider with comprehensive metrics
final gardenAnalyticsProvider = Provider<GardenAnalytics>((ref) {
  final crops = ref.watch(gardenProvider).valueOrNull ?? [];
  final harvests = ref.watch(harvestsProvider).valueOrNull ?? [];
  final photos = ref.watch(photosProvider).valueOrNull ?? [];
  final plants = ref.watch(allPlantsProvider);

  if (crops.isEmpty) {
    return GardenAnalytics.empty();
  }

  // Basic counts
  final totalCrops = crops.length;
  final activeCrops = crops.where((c) => c.status.isActive).length;
  final completedCrops = crops.where((c) => c.status == CropStatus.completed).length;
  final failedCrops = crops.where((c) => c.status == CropStatus.failed).length;

  // Success rate calculation
  final finishedCrops = completedCrops + failedCrops;
  final successRate = finishedCrops > 0 ? (completedCrops / finishedCrops) * 100 : 0.0;

  // Harvests by month
  final harvestsByMonth = <String, int>{};
  for (final harvest in harvests) {
    final monthKey = '${harvest.harvestDate.year}-${harvest.harvestDate.month.toString().padLeft(2, '0')}';
    harvestsByMonth[monthKey] = (harvestsByMonth[monthKey] ?? 0) + 1;
  }

  // Crops by status
  final cropsByStatus = <CropStatus, int>{};
  for (final status in CropStatus.values) {
    cropsByStatus[status] = crops.where((c) => c.status == status).length;
  }

  // Top performers
  final topPerformers = _calculateTopPerformers(crops, harvests, plants);

  // Yield by plant
  final yieldByPlant = _calculateYieldByPlant(crops, harvests, plants);

  // Harvest trends
  final harvestTrends = _calculateHarvestTrends(harvests);

  // Seasonal distribution
  final seasonalDistribution = _calculateSeasonalDistribution(crops);

  // Average days to harvest
  final averageDaysToHarvest = _calculateAverageDaysToHarvest(crops);

  // Photo count by stage
  final photoCountByStage = <PhotoStage, int>{};
  for (final photo in photos) {
    if (photo.stage != null) {
      photoCountByStage[photo.stage!] = (photoCountByStage[photo.stage!] ?? 0) + 1;
    }
  }

  return GardenAnalytics(
    totalCrops: totalCrops,
    activeCrops: activeCrops,
    completedCrops: completedCrops,
    failedCrops: failedCrops,
    successRate: successRate,
    totalHarvests: harvests.length,
    totalPhotos: photos.length,
    harvestsByMonth: harvestsByMonth,
    cropsByStatus: cropsByStatus,
    topPerformers: topPerformers,
    yieldByPlant: yieldByPlant,
    harvestTrends: harvestTrends,
    seasonalDistribution: seasonalDistribution,
    averageDaysToHarvest: averageDaysToHarvest,
    photoCountByStage: photoCountByStage,
  );
});

/// Calculate top performing plants
List<PlantPerformance> _calculateTopPerformers(
  List<PlantedCrop> crops,
  List<Harvest> harvests,
  List<Plant> plants,
) {
  final Map<String, _PlantStats> statsMap = {};

  for (final crop in crops) {
    final stats = statsMap.putIfAbsent(
      crop.plantId,
      () => _PlantStats(plantId: crop.plantId),
    );

    stats.timesPlanted++;

    if (crop.status == CropStatus.completed) {
      stats.successful++;
    }

    // Calculate days to harvest
    if (crop.firstHarvestDate != null && crop.effectivePlantDate != null) {
      final daysToHarvest = crop.firstHarvestDate!.difference(crop.effectivePlantDate!).inDays;
      stats.daysToHarvestList.add(daysToHarvest);
    }

    // Sum up yields
    final cropHarvests = harvests.where((h) => h.cropId == crop.id);
    for (final harvest in cropHarvests) {
      stats.totalYield += harvest.quantity;
    }
  }

  // Convert to PlantPerformance list
  final performances = <PlantPerformance>[];
  for (final entry in statsMap.entries) {
    final plantId = entry.key;
    final stats = entry.value;
    final plant = plants.where((p) => p.id == plantId).firstOrNull;

    if (plant != null && stats.timesPlanted > 0) {
      final successRate = (stats.successful / stats.timesPlanted) * 100;
      final avgDays = stats.daysToHarvestList.isEmpty
          ? 0.0
          : stats.daysToHarvestList.reduce((a, b) => a + b) / stats.daysToHarvestList.length;

      performances.add(PlantPerformance(
        plantId: plantId,
        plantName: plant.name,
        timesPlanted: stats.timesPlanted,
        successfulHarvests: stats.successful,
        totalYield: stats.totalYield,
        averageDaysToHarvest: avgDays,
        successRate: successRate,
      ));
    }
  }

  // Sort by score and return top 10
  performances.sort((a, b) => b.score.compareTo(a.score));
  return performances.take(10).toList();
}

/// Calculate yield summaries by plant
Map<String, YieldSummary> _calculateYieldByPlant(
  List<PlantedCrop> crops,
  List<Harvest> harvests,
  List<Plant> plants,
) {
  final Map<String, YieldSummary> summaries = {};

  // Group harvests by plant ID
  final Map<String, List<Harvest>> harvestsByPlant = {};
  for (final harvest in harvests) {
    final crop = crops.where((c) => c.id == harvest.cropId).firstOrNull;
    if (crop != null) {
      harvestsByPlant.putIfAbsent(crop.plantId, () => []).add(harvest);
    }
  }

  // Calculate summaries
  for (final entry in harvestsByPlant.entries) {
    final plantId = entry.key;
    final plantHarvests = entry.value;
    final plant = plants.where((p) => p.id == plantId).firstOrNull;

    if (plant != null && plantHarvests.isNotEmpty) {
      // Group by unit (in case same plant has different units)
      final Map<HarvestUnit, List<double>> quantitiesByUnit = {};
      for (final harvest in plantHarvests) {
        quantitiesByUnit.putIfAbsent(harvest.unit, () => []).add(harvest.quantity);
      }

      // Use the most common unit
      final mainUnit = quantitiesByUnit.entries
          .reduce((a, b) => a.value.length > b.value.length ? a : b)
          .key;
      final quantities = quantitiesByUnit[mainUnit] ?? [];

      if (quantities.isNotEmpty) {
        final total = quantities.reduce((a, b) => a + b);
        final average = total / quantities.length;
        final best = quantities.reduce((a, b) => a > b ? a : b);
        final worst = quantities.reduce((a, b) => a < b ? a : b);

        summaries[plantId] = YieldSummary(
          plantId: plantId,
          plantName: plant.name,
          totalWeight: total,
          unit: mainUnit,
          harvestCount: quantities.length,
          averagePerHarvest: average,
          bestHarvest: best,
          worstHarvest: worst,
        );
      }
    }
  }

  return summaries;
}

/// Calculate harvest trends over time (monthly)
List<HarvestTrend> _calculateHarvestTrends(List<Harvest> harvests) {
  final Map<String, _TrendData> trendMap = {};

  for (final harvest in harvests) {
    final monthKey = '${harvest.harvestDate.year}-${harvest.harvestDate.month.toString().padLeft(2, '0')}';
    final trend = trendMap.putIfAbsent(
      monthKey,
      () => _TrendData(period: monthKey),
    );

    trend.harvestCount++;
    trend.totalYield += harvest.quantity;
    trend.plantIds.add(harvest.cropId);
  }

  // Convert to list and sort by period
  final trends = trendMap.values
      .map((t) => HarvestTrend(
            period: t.period,
            harvestCount: t.harvestCount,
            totalYield: t.totalYield,
            uniquePlants: t.plantIds.length,
          ))
      .toList();

  trends.sort((a, b) => a.period.compareTo(b.period));
  return trends;
}

/// Calculate seasonal distribution of crops
Map<String, int> _calculateSeasonalDistribution(List<PlantedCrop> crops) {
  final distribution = <String, int>{
    'Spring': 0,
    'Summer': 0,
    'Fall': 0,
    'Winter': 0,
  };

  for (final crop in crops) {
    final plantDate = crop.effectivePlantDate;
    if (plantDate != null) {
      final season = SeasonalStats.getSeason(plantDate.month);
      distribution[season] = (distribution[season] ?? 0) + 1;
    }
  }

  return distribution;
}

/// Calculate average days from planting to first harvest
double? _calculateAverageDaysToHarvest(List<PlantedCrop> crops) {
  final daysList = <int>[];

  for (final crop in crops) {
    if (crop.firstHarvestDate != null && crop.effectivePlantDate != null) {
      final days = crop.firstHarvestDate!.difference(crop.effectivePlantDate!).inDays;
      if (days > 0) {
        daysList.add(days);
      }
    }
  }

  if (daysList.isEmpty) return null;
  return daysList.reduce((a, b) => a + b) / daysList.length;
}

/// Helper class for plant statistics
class _PlantStats {
  _PlantStats({required this.plantId});

  final String plantId;
  int timesPlanted = 0;
  int successful = 0;
  double totalYield = 0.0;
  List<int> daysToHarvestList = [];
}

/// Helper class for trend data
class _TrendData {
  _TrendData({required this.period});

  final String period;
  int harvestCount = 0;
  double totalYield = 0.0;
  Set<String> plantIds = {};
}

/// Year-over-year comparison provider
final yearComparisonProvider = Provider<List<YearComparison>>((ref) {
  final crops = ref.watch(gardenProvider).valueOrNull ?? [];
  final harvests = ref.watch(harvestsProvider).valueOrNull ?? [];

  if (crops.isEmpty) return [];

  final Map<int, _YearData> yearMap = {};

  // Group crops by year
  for (final crop in crops) {
    final plantDate = crop.effectivePlantDate;
    if (plantDate != null) {
      final year = plantDate.year;
      final yearData = yearMap.putIfAbsent(year, () => _YearData(year: year));

      yearData.totalCrops++;
      if (crop.status == CropStatus.completed) {
        yearData.successful++;
      } else if (crop.status == CropStatus.failed) {
        yearData.failed++;
      }

      yearData.plantIds.add(crop.plantId);
    }
  }

  // Count harvests by year
  for (final harvest in harvests) {
    final year = harvest.harvestDate.year;
    yearMap[year]?.harvestCount++;
  }

  // Convert to YearComparison list
  final comparisons = yearMap.values.map((data) {
    final finished = data.successful + data.failed;
    final successRate = finished > 0 ? (data.successful / finished) * 100 : 0.0;

    return YearComparison(
      year: data.year,
      totalCrops: data.totalCrops,
      totalHarvests: data.harvestCount,
      successRate: successRate,
      mostGrownPlants: data.plantIds.take(5).toList(),
    );
  }).toList();

  comparisons.sort((a, b) => b.year.compareTo(a.year));
  return comparisons;
});

/// Helper class for year data
class _YearData {
  _YearData({required this.year});

  final int year;
  int totalCrops = 0;
  int successful = 0;
  int failed = 0;
  int harvestCount = 0;
  Set<String> plantIds = {};
}

/// Seasonal statistics provider
final seasonalStatsProvider = Provider<SeasonalStats>((ref) {
  final crops = ref.watch(gardenProvider).valueOrNull ?? [];

  final counts = {'Spring': 0, 'Summer': 0, 'Fall': 0, 'Winter': 0};

  for (final crop in crops) {
    final plantDate = crop.effectivePlantDate;
    if (plantDate != null) {
      final season = SeasonalStats.getSeason(plantDate.month);
      counts[season] = (counts[season] ?? 0) + 1;
    }
  }

  return SeasonalStats(
    spring: counts['Spring'] ?? 0,
    summer: counts['Summer'] ?? 0,
    fall: counts['Fall'] ?? 0,
    winter: counts['Winter'] ?? 0,
  );
});

/// Space efficiency by location provider
final spaceEfficiencyProvider = Provider<List<SpaceEfficiency>>((ref) {
  final crops = ref.watch(gardenProvider).valueOrNull ?? [];
  final harvests = ref.watch(harvestsProvider).valueOrNull ?? [];
  final locations = ref.watch(locationsProvider).valueOrNull ?? [];

  final Map<String, _LocationStats> statsMap = {};

  for (final crop in crops) {
    if (crop.location == null) continue;

    final stats = statsMap.putIfAbsent(
      crop.location!,
      () => _LocationStats(locationId: crop.location!),
    );

    stats.totalCrops++;
    if (crop.status == CropStatus.completed) {
      stats.successful++;
    }

    // Sum yields for this location
    final cropHarvests = harvests.where((h) => h.cropId == crop.id);
    for (final harvest in cropHarvests) {
      stats.totalYield += harvest.quantity;
    }
  }

  // Convert to SpaceEfficiency list
  final efficiencies = <SpaceEfficiency>[];
  for (final entry in statsMap.entries) {
    final locationId = entry.key;
    final stats = entry.value;
    final location = locations.where((l) => l.id == locationId).firstOrNull;

    final successRate = stats.totalCrops > 0 ? (stats.successful / stats.totalCrops) * 100 : 0.0;

    efficiencies.add(SpaceEfficiency(
      locationId: locationId,
      locationName: location?.name ?? locationId,
      totalCrops: stats.totalCrops,
      totalYield: stats.totalYield,
      successRate: successRate,
    ));
  }

  efficiencies.sort((a, b) => b.totalYield.compareTo(a.totalYield));
  return efficiencies;
});

/// Helper class for location statistics
class _LocationStats {
  _LocationStats({required this.locationId});

  final String locationId;
  int totalCrops = 0;
  int successful = 0;
  double totalYield = 0.0;
}
