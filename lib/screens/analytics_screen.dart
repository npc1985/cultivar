/// Analytics dashboard screen with comprehensive garden insights
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/analytics.dart';
import '../models/garden.dart';
import '../providers/analytics_provider.dart';

/// Main analytics dashboard screen
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(gardenAnalyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Garden Analytics'),
      ),
      body: analytics.totalCrops == 0
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No data yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start planting to see analytics',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _OverviewSection(analytics: analytics),
                const SizedBox(height: 16),
                _SuccessRateSection(analytics: analytics),
                const SizedBox(height: 16),
                _HarvestTrendsSection(analytics: analytics),
                const SizedBox(height: 16),
                _SeasonalDistributionSection(analytics: analytics),
                const SizedBox(height: 16),
                _TopPerformersSection(analytics: analytics),
                const SizedBox(height: 16),
                _YieldSummarySection(analytics: analytics),
                const SizedBox(height: 16),
                _PhotoInsightsSection(analytics: analytics),
              ],
            ),
    );
  }
}

/// Overview statistics cards
class _OverviewSection extends StatelessWidget {
  const _OverviewSection({required this.analytics});

  final GardenAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Total Crops',
                    value: analytics.totalCrops.toString(),
                    icon: Icons.local_florist,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Active',
                    value: analytics.activeCrops.toString(),
                    icon: Icons.eco,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Harvests',
                    value: analytics.totalHarvests.toString(),
                    icon: Icons.agriculture,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Photos',
                    value: analytics.totalPhotos.toString(),
                    icon: Icons.photo_camera,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual stat card
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Success rate pie chart
class _SuccessRateSection extends StatelessWidget {
  const _SuccessRateSection({required this.analytics});

  final GardenAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    if (analytics.completedCrops == 0 && analytics.failedCrops == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Success Rate',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '${analytics.successRate.toStringAsFixed(1)}% of crops completed successfully',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: analytics.completedCrops.toDouble(),
                      title: '${analytics.completedCrops}\nCompleted',
                      color: Colors.green,
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: analytics.failedCrops.toDouble(),
                      title: '${analytics.failedCrops}\nFailed',
                      color: Colors.red,
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Harvest trends line chart
class _HarvestTrendsSection extends StatelessWidget {
  const _HarvestTrendsSection({required this.analytics});

  final GardenAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    if (analytics.harvestTrends.isEmpty) {
      return const SizedBox.shrink();
    }

    final trends = analytics.harvestTrends.take(12).toList(); // Last 12 months

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Harvest Trends',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Monthly harvest activity',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < trends.length) {
                            final month = trends[value.toInt()].period.split('-')[1];
                            return Text(month, style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        trends.length,
                        (i) => FlSpot(i.toDouble(), trends[i].harvestCount.toDouble()),
                      ),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Seasonal distribution bar chart
class _SeasonalDistributionSection extends StatelessWidget {
  const _SeasonalDistributionSection({required this.analytics});

  final GardenAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    if (analytics.seasonalDistribution.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seasonal Distribution',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'When you plant throughout the year',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: analytics.seasonalDistribution.values.reduce((a, b) => a > b ? a : b).toDouble() * 1.2,
                  barGroups: [
                    _makeBarGroup(0, analytics.seasonalDistribution['Spring']?.toDouble() ?? 0, Colors.pink),
                    _makeBarGroup(1, analytics.seasonalDistribution['Summer']?.toDouble() ?? 0, Colors.orange),
                    _makeBarGroup(2, analytics.seasonalDistribution['Fall']?.toDouble() ?? 0, Colors.brown),
                    _makeBarGroup(3, analytics.seasonalDistribution['Winter']?.toDouble() ?? 0, Colors.blue),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const seasons = ['Spring', 'Summer', 'Fall', 'Winter'];
                          if (value.toInt() >= 0 && value.toInt() < seasons.length) {
                            return Text(seasons[value.toInt()], style: const TextStyle(fontSize: 12));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  gridData: FlGridData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 40,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }
}

/// Top performing plants list
class _TopPerformersSection extends StatelessWidget {
  const _TopPerformersSection({required this.analytics});

  final GardenAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    if (analytics.topPerformers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Performers',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Your most successful plants',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ...analytics.topPerformers.take(5).map((performer) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: performer.successRate >= 80
                      ? Colors.green
                      : performer.successRate >= 50
                          ? Colors.orange
                          : Colors.red,
                  child: Text(
                    '${performer.successRate.toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(performer.plantName),
                subtitle: Text(
                  'Planted ${performer.timesPlanted}x • Avg ${performer.averageDaysToHarvest.toInt()} days',
                ),
                trailing: Text(
                  '${performer.totalYield.toStringAsFixed(1)} total yield',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Yield summary section
class _YieldSummarySection extends StatelessWidget {
  const _YieldSummarySection({required this.analytics});

  final GardenAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    if (analytics.yieldByPlant.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedYields = analytics.yieldByPlant.values.toList()
      ..sort((a, b) => b.totalWeight.compareTo(a.totalWeight));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yield Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Total harvest by plant',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ...sortedYields.take(5).map((yield) {
              return ListTile(
                leading: const Icon(Icons.agriculture, color: Colors.green),
                title: Text(yield.plantName),
                subtitle: Text(
                  '${yield.harvestCount} harvests • Avg: ${yield.averagePerHarvest.toStringAsFixed(1)} ${yield.unit.abbreviation}',
                ),
                trailing: Text(
                  '${yield.totalWeight.toStringAsFixed(1)} ${yield.unit.abbreviation}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Photo insights section
class _PhotoInsightsSection extends StatelessWidget {
  const _PhotoInsightsSection({required this.analytics});

  final GardenAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    if (analytics.photoCountByStage.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Photo Documentation',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Photos by growth stage',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ...analytics.photoCountByStage.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Text(entry.key.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.key.displayName),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: entry.value / analytics.totalPhotos,
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${entry.value}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
