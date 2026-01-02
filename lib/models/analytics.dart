/// Garden analytics models for metrics and insights
library;

import 'package:cultivar/models/garden.dart';

/// Comprehensive garden analytics data
class GardenAnalytics {
  const GardenAnalytics({
    required this.totalCrops,
    required this.activeCrops,
    required this.completedCrops,
    required this.failedCrops,
    required this.successRate,
    required this.totalHarvests,
    required this.totalPhotos,
    required this.harvestsByMonth,
    required this.cropsByStatus,
    required this.topPerformers,
    required this.yieldByPlant,
    required this.harvestTrends,
    required this.seasonalDistribution,
    required this.averageDaysToHarvest,
    required this.photoCountByStage,
  });

  final int totalCrops;
  final int activeCrops;
  final int completedCrops;
  final int failedCrops;
  final double successRate; // Percentage (0-100)

  final int totalHarvests;
  final int totalPhotos;

  // Time-based metrics
  final Map<String, int> harvestsByMonth; // 'YYYY-MM' -> count
  final Map<CropStatus, int> cropsByStatus;

  // Performance metrics
  final List<PlantPerformance> topPerformers;
  final Map<String, YieldSummary> yieldByPlant; // plantId -> yields
  final List<HarvestTrend> harvestTrends; // Weekly/monthly trends

  // Seasonal insights
  final Map<String, int> seasonalDistribution; // Season -> crop count
  final double? averageDaysToHarvest;

  // Photo analytics
  final Map<PhotoStage, int> photoCountByStage;

  /// Create empty analytics
  factory GardenAnalytics.empty() {
    return const GardenAnalytics(
      totalCrops: 0,
      activeCrops: 0,
      completedCrops: 0,
      failedCrops: 0,
      successRate: 0.0,
      totalHarvests: 0,
      totalPhotos: 0,
      harvestsByMonth: {},
      cropsByStatus: {},
      topPerformers: [],
      yieldByPlant: {},
      harvestTrends: [],
      seasonalDistribution: {},
      averageDaysToHarvest: null,
      photoCountByStage: {},
    );
  }
}

/// Performance metrics for a specific plant type
class PlantPerformance {
  const PlantPerformance({
    required this.plantId,
    required this.plantName,
    required this.timesPlanted,
    required this.successfulHarvests,
    required this.totalYield,
    required this.averageDaysToHarvest,
    required this.successRate,
  });

  final String plantId;
  final String plantName;
  final int timesPlanted;
  final int successfulHarvests;
  final double totalYield;
  final double averageDaysToHarvest;
  final double successRate; // Percentage (0-100)

  /// Sort key for ranking (higher is better)
  double get score => successRate * timesPlanted;
}

/// Yield summary for a plant
class YieldSummary {
  const YieldSummary({
    required this.plantId,
    required this.plantName,
    required this.totalWeight,
    required this.unit,
    required this.harvestCount,
    required this.averagePerHarvest,
    required this.bestHarvest,
    required this.worstHarvest,
  });

  final String plantId;
  final String plantName;
  final double totalWeight;
  final HarvestUnit unit;
  final int harvestCount;
  final double averagePerHarvest;
  final double bestHarvest;
  final double worstHarvest;
}

/// Harvest trend over time
class HarvestTrend {
  const HarvestTrend({
    required this.period,
    required this.harvestCount,
    required this.totalYield,
    required this.uniquePlants,
  });

  final String period; // 'YYYY-MM' or 'YYYY-WW'
  final int harvestCount;
  final double totalYield;
  final int uniquePlants;
}

/// Year-over-year comparison data
class YearComparison {
  const YearComparison({
    required this.year,
    required this.totalCrops,
    required this.totalHarvests,
    required this.successRate,
    required this.mostGrownPlants,
  });

  final int year;
  final int totalCrops;
  final int totalHarvests;
  final double successRate;
  final List<String> mostGrownPlants; // Plant IDs
}

/// Seasonal planting statistics
class SeasonalStats {
  const SeasonalStats({
    required this.spring,
    required this.summer,
    required this.fall,
    required this.winter,
  });

  final int spring; // March, April, May
  final int summer; // June, July, August
  final int fall; // September, October, November
  final int winter; // December, January, February

  /// Get season from month (1-12)
  static String getSeason(int month) {
    if (month >= 3 && month <= 5) return 'Spring';
    if (month >= 6 && month <= 8) return 'Summer';
    if (month >= 9 && month <= 11) return 'Fall';
    return 'Winter';
  }
}

/// Space efficiency metrics
class SpaceEfficiency {
  const SpaceEfficiency({
    required this.locationId,
    required this.locationName,
    required this.totalCrops,
    required this.totalYield,
    required this.successRate,
  });

  final String locationId;
  final String locationName;
  final int totalCrops;
  final double totalYield;
  final double successRate;
}
