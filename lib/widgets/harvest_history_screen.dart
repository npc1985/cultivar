/// Harvest history screen showing all harvests with filtering and analytics
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/garden.dart';
import '../models/plant.dart';
import '../providers/garden_provider.dart';

/// Opens the harvest history screen
void openHarvestHistory(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => const HarvestHistoryScreen(),
    ),
  );
}

/// Full screen showing all harvests with filtering and stats
class HarvestHistoryScreen extends ConsumerStatefulWidget {
  const HarvestHistoryScreen({super.key});

  @override
  ConsumerState<HarvestHistoryScreen> createState() => _HarvestHistoryScreenState();
}

class _HarvestHistoryScreenState extends ConsumerState<HarvestHistoryScreen> {
  String _filter = 'all'; // 'all', 'week', 'month', 'year'

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvestsWithDetails = ref.watch(harvestsWithDetailsProvider);
    final stats = ref.watch(harvestStatsProvider);

    // Filter harvests based on selected time period
    final filteredHarvests = _filterHarvests(harvestsWithDetails);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Harvest History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights),
            tooltip: 'Analytics',
            onPressed: () => _showAnalytics(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats summary
          _buildStatsSummary(theme, stats),

          // Time filter
          _buildTimeFilter(theme),

          const Divider(height: 1),

          // Harvests list
          Expanded(
            child: filteredHarvests.isEmpty
                ? _buildEmptyState(theme)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredHarvests.length,
                    itemBuilder: (context, index) {
                      final item = filteredHarvests[index];
                      return _buildHarvestCard(theme, item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<HarvestWithDetails> _filterHarvests(List<HarvestWithDetails> harvests) {
    final now = DateTime.now();
    return harvests.where((h) {
      return switch (_filter) {
        'week' => h.harvest.harvestDate.isAfter(now.subtract(const Duration(days: 7))),
        'month' => h.harvest.harvestDate.isAfter(now.subtract(const Duration(days: 30))),
        'year' => h.harvest.harvestDate.year == now.year,
        _ => true,
      };
    }).toList();
  }

  Widget _buildStatsSummary(ThemeData theme, Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(theme, '🧺', 'Total\nHarvests', '${stats['totalHarvests'] ?? 0}'),
          _buildStatItem(theme, '🌱', 'Crops\nHarvested', '${stats['totalCrops'] ?? 0}'),
          _buildStatItem(theme, '📅', 'This\nMonth', '${stats['thisMonth'] ?? 0}'),
          _buildStatItem(theme, '🗓️', 'This\nYear', '${stats['thisYear'] ?? 0}'),
        ],
      ),
    );
  }

  Widget _buildStatItem(ThemeData theme, String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTimeFilter(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('All Time', 'all'),
          const SizedBox(width: 8),
          _buildFilterChip('This Week', 'week'),
          const SizedBox(width: 8),
          _buildFilterChip('This Month', 'month'),
          const SizedBox(width: 8),
          _buildFilterChip('This Year', 'year'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _filter = value),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '🧺',
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          Text(
            'No Harvests Yet',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Record your first harvest from a crop!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHarvestCard(ThemeData theme, HarvestWithDetails item) {
    final harvest = item.harvest;
    final plant = item.plant;
    final crop = item.crop;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                // Plant emoji
                if (plant != null) ...[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        plant.emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                // Plant name and quantity
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant?.commonName ?? 'Unknown Plant',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        harvest.quantityDisplay,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Quality
                if (harvest.quality != null)
                  Column(
                    children: [
                      Text(
                        harvest.quality!.emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                      Text(
                        harvest.quality!.displayName,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Date and Type
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(harvest.harvestDate),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                if (harvest.harvestType != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          harvest.harvestType!.emoji,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          harvest.harvestType!.displayName,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            // Preservation methods
            if (harvest.preservationMethods.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: harvest.preservationMethods.map((method) {
                  return Chip(
                    avatar: Text(method.emoji),
                    label: Text(
                      method.displayName,
                      style: const TextStyle(fontSize: 12),
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],

            // Notes
            if (harvest.notes != null && harvest.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  harvest.notes!,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],

            // Variety info
            if (crop?.variety != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.label_outline,
                    size: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Variety: ${crop!.variety}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAnalytics(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _HarvestAnalyticsSheet(),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';

    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

/// Analytics sheet showing harvest statistics and insights
class _HarvestAnalyticsSheet extends ConsumerWidget {
  const _HarvestAnalyticsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final harvestsWithDetails = ref.watch(harvestsWithDetailsProvider);

    // Calculate analytics
    final analytics = _calculateAnalytics(harvestsWithDetails);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(Icons.insights, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Harvest Analytics',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Top crops by quantity
                if (analytics['topCrops'] != null && (analytics['topCrops'] as List).isNotEmpty) ...[
                  Text(
                    'Top Producers',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...(analytics['topCrops'] as List<Map<String, dynamic>>).take(5).map((crop) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Text(
                            crop['emoji'] as String? ?? '🌱',
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  crop['name'] as String,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  crop['totalQuantity'] as String,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${crop['count']} harvests',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],

                // Quality breakdown
                if (analytics['qualityBreakdown'] != null) ...[
                  Text(
                    'Quality Breakdown',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...(analytics['qualityBreakdown'] as Map<String, dynamic>).entries.map((entry) {
                    final total = analytics['totalHarvests'] as int;
                    final percentage = total > 0 ? ((entry.value as int) / total * 100).round() : 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 80,
                            child: Text(entry.key),
                          ),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('$percentage%'),
                        ],
                      ),
                    );
                  }),
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateAnalytics(List<HarvestWithDetails> harvests) {
    if (harvests.isEmpty) {
      return {
        'topCrops': [],
        'qualityBreakdown': {},
        'totalHarvests': 0,
      };
    }

    // Group by plant and calculate totals
    final cropTotals = <String, Map<String, dynamic>>{};
    for (final h in harvests) {
      final plantId = h.crop?.plantId ?? 'unknown';
      if (!cropTotals.containsKey(plantId)) {
        cropTotals[plantId] = {
          'name': h.plant?.commonName ?? 'Unknown',
          'emoji': h.plant?.emoji ?? '🌱',
          'count': 0,
          'quantities': <HarvestUnit, double>{},
        };
      }
      cropTotals[plantId]!['count'] = (cropTotals[plantId]!['count'] as int) + 1;
      final quantities = cropTotals[plantId]!['quantities'] as Map<HarvestUnit, double>;
      quantities[h.harvest.unit] = (quantities[h.harvest.unit] ?? 0) + h.harvest.quantity;
    }

    // Format top crops
    final topCrops = cropTotals.entries.map((entry) {
      final quantities = entry.value['quantities'] as Map<HarvestUnit, double>;
      final totalQuantity = quantities.entries.map((e) {
        final qty = e.value == e.value.truncateToDouble()
            ? e.value.toInt().toString()
            : e.value.toStringAsFixed(1);
        return '$qty ${e.key.abbreviation}';
      }).join(', ');

      return {
        'name': entry.value['name'],
        'emoji': entry.value['emoji'],
        'count': entry.value['count'],
        'totalQuantity': totalQuantity,
      };
    }).toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

    // Quality breakdown
    final qualityBreakdown = <String, int>{};
    for (final h in harvests) {
      final quality = h.harvest.quality?.displayName ?? 'Not Rated';
      qualityBreakdown[quality] = (qualityBreakdown[quality] ?? 0) + 1;
    }

    return {
      'topCrops': topCrops,
      'qualityBreakdown': qualityBreakdown,
      'totalHarvests': harvests.length,
    };
  }
}
