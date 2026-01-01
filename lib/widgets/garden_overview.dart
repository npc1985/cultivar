/// Garden overview widget for displaying user's planted crops
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/garden.dart';
import '../models/plant.dart';
import '../providers/garden_provider.dart';
import '../providers/plant_provider.dart';
import 'garden_manager.dart';
import 'plant_detail_sheet.dart';

/// Main garden overview showing user's planted crops
class GardenOverview extends ConsumerWidget {
  const GardenOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cropsAsync = ref.watch(gardenProvider);
    final stats = ref.watch(gardenStatsProvider);

    return cropsAsync.when(
      data: (crops) {
        if (crops.isEmpty) {
          return _EmptyGardenCard();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.yard_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'My Garden',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${stats['total']} plants',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  // Manage button for large gardens
                  if (crops.length > 4)
                    TextButton.icon(
                      onPressed: () => openGardenManager(context),
                      icon: const Icon(Icons.grid_view, size: 16),
                      label: const Text('Manage'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),
            ),

            // Status chips
            if (crops.isNotEmpty)
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    if (stats['startedIndoors']! > 0)
                      _StatusChip(
                        status: CropStatus.startedIndoors,
                        count: stats['startedIndoors']!,
                      ),
                    if (stats['hardeningOff']! > 0)
                      _StatusChip(
                        status: CropStatus.hardeningOff,
                        count: stats['hardeningOff']!,
                      ),
                    if (stats['transplanted']! > 0)
                      _StatusChip(
                        status: CropStatus.transplanted,
                        count: stats['transplanted']!,
                      ),
                    if (stats['growing']! > 0)
                      _StatusChip(
                        status: CropStatus.growing,
                        count: stats['growing']!,
                      ),
                    if (stats['harvesting']! > 0)
                      _StatusChip(
                        status: CropStatus.harvesting,
                        count: stats['harvesting']!,
                      ),
                    if (stats['planned']! > 0)
                      _StatusChip(
                        status: CropStatus.planned,
                        count: stats['planned']!,
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            // Crop grid
            _CropGrid(crops: crops),
          ],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text('Error loading garden'),
              TextButton(
                onPressed: () => ref.invalidate(gardenProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyGardenCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.yard_outlined,
              size: 48,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Your Garden is Empty',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Browse the plant database below and add plants to start tracking your garden.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.status,
    required this.count,
  });

  final CropStatus status;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getStatusColor(status);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getStatusIcon(status),
              size: 14,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              '$count ${status.displayName.toLowerCase()}',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(CropStatus status) {
    return switch (status) {
      CropStatus.planned => Colors.grey.shade600,
      CropStatus.ordered => Colors.indigo.shade300,
      CropStatus.startedIndoors => Colors.purple.shade400,
      CropStatus.hardeningOff => Colors.orange.shade400,
      CropStatus.transplanted => Colors.blue.shade400,
      CropStatus.directSowed => Colors.blue.shade300,
      CropStatus.growing => Colors.green.shade500,
      CropStatus.flowering => Colors.pink.shade400,
      CropStatus.fruiting => Colors.orange.shade500,
      CropStatus.harvesting => Colors.amber.shade600,
      CropStatus.dormant => Colors.blueGrey.shade400,
      CropStatus.completed => Colors.teal.shade400,
      CropStatus.failed => Colors.red.shade400,
    };
  }

  IconData _getStatusIcon(CropStatus status) {
    return switch (status) {
      CropStatus.planned => Icons.event_note,
      CropStatus.ordered => Icons.local_shipping,
      CropStatus.startedIndoors => Icons.home_outlined,
      CropStatus.hardeningOff => Icons.wb_sunny_outlined,
      CropStatus.transplanted => Icons.park_outlined,
      CropStatus.directSowed => Icons.grass,
      CropStatus.growing => Icons.eco,
      CropStatus.flowering => Icons.local_florist,
      CropStatus.fruiting => Icons.apple,
      CropStatus.harvesting => Icons.content_cut,
      CropStatus.dormant => Icons.bedtime,
      CropStatus.completed => Icons.check_circle_outline,
      CropStatus.failed => Icons.close,
    };
  }
}

class _CropGrid extends ConsumerWidget {
  const _CropGrid({required this.crops});

  final List<PlantedCrop> crops;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allPlants = ref.watch(allPlantsProvider);

    // Sort: active crops first, then by status priority
    final sortedCrops = List<PlantedCrop>.from(crops)..sort((a, b) {
      final aActive = a.status.needsFrostCheck ? 0 : 1;
      final bActive = b.status.needsFrostCheck ? 0 : 1;
      if (aActive != bActive) return aActive.compareTo(bActive);
      return a.status.index.compareTo(b.status.index);
    });

    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: sortedCrops.length,
        itemBuilder: (context, index) {
          final crop = sortedCrops[index];
          final plant = allPlants.where((p) => p.id == crop.plantId).firstOrNull;

          return _CropCard(
            crop: crop,
            plant: plant,
            onTap: () => _showCropDetails(context, ref, crop, plant),
          );
        },
      ),
    );
  }

  void _showCropDetails(BuildContext context, WidgetRef ref, PlantedCrop crop, Plant? plant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CropDetailSheet(crop: crop, plant: plant),
    );
  }
}

class _CropCard extends StatelessWidget {
  const _CropCard({
    required this.crop,
    this.plant,
    required this.onTap,
  });

  final PlantedCrop crop;
  final Plant? plant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getStatusColor(crop.status);

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 100,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Plant emoji
                Text(
                  plant?.emoji ?? '?',
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 8),

                // Plant name
                Text(
                  plant?.commonName ?? 'Unknown',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),

                // Status indicator
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    crop.status.emoji,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(CropStatus status) {
    return switch (status) {
      CropStatus.planned => Colors.grey.shade600,
      CropStatus.ordered => Colors.indigo.shade300,
      CropStatus.startedIndoors => Colors.purple.shade400,
      CropStatus.hardeningOff => Colors.orange.shade400,
      CropStatus.transplanted => Colors.blue.shade400,
      CropStatus.directSowed => Colors.blue.shade300,
      CropStatus.growing => Colors.green.shade500,
      CropStatus.flowering => Colors.pink.shade400,
      CropStatus.fruiting => Colors.orange.shade500,
      CropStatus.harvesting => Colors.amber.shade600,
      CropStatus.dormant => Colors.blueGrey.shade400,
      CropStatus.completed => Colors.teal.shade400,
      CropStatus.failed => Colors.red.shade400,
    };
  }
}

class _CropDetailSheet extends ConsumerWidget {
  const _CropDetailSheet({
    required this.crop,
    this.plant,
  });

  final PlantedCrop crop;
  final Plant? plant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = _getStatusColor(crop.status);

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
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          plant?.emoji ?? '?',
                          style: const TextStyle(fontSize: 36),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plant?.commonName ?? 'Unknown Plant',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      crop.status.emoji,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      crop.status.displayName,
                                      style: TextStyle(
                                        color: color,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (crop.quantity > 1) ...[
                                const SizedBox(width: 8),
                                Text(
                                  'x${crop.quantity}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Update status section
                Text(
                  'Update Status',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: CropStatus.values.map((status) {
                    final isSelected = crop.status == status;
                    final statusColor = _getStatusColor(status);

                    return FilterChip(
                      selected: isSelected,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(status.emoji),
                          const SizedBox(width: 4),
                          Text(status.displayName),
                        ],
                      ),
                      onSelected: isSelected
                          ? null
                          : (_) async {
                              await ref
                                  .read(gardenProvider.notifier)
                                  .updateStatus(crop.id, status);
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                      selectedColor: statusColor.withValues(alpha: 0.2),
                      checkmarkColor: statusColor,
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // View plant details button
                if (plant != null)
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      showPlantDetailSheet(context, plant!);
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text('View Plant Details'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),

                const SizedBox(height: 12),

                // Delete button
                TextButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Remove from Garden?'),
                        content: Text('Remove ${plant?.commonName ?? 'this plant'} from your garden?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Remove'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      await ref.read(gardenProvider.notifier).deleteCrop(crop.id);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text(
                    'Remove from Garden',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(CropStatus status) {
    return switch (status) {
      CropStatus.planned => Colors.grey.shade600,
      CropStatus.ordered => Colors.indigo.shade300,
      CropStatus.startedIndoors => Colors.purple.shade400,
      CropStatus.hardeningOff => Colors.orange.shade400,
      CropStatus.transplanted => Colors.blue.shade400,
      CropStatus.directSowed => Colors.blue.shade300,
      CropStatus.growing => Colors.green.shade500,
      CropStatus.flowering => Colors.pink.shade400,
      CropStatus.fruiting => Colors.orange.shade500,
      CropStatus.harvesting => Colors.amber.shade600,
      CropStatus.dormant => Colors.blueGrey.shade400,
      CropStatus.completed => Colors.teal.shade400,
      CropStatus.failed => Colors.red.shade400,
    };
  }
}

/// Compact garden summary for dashboard
class GardenSummaryCard extends ConsumerWidget {
  const GardenSummaryCard({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stats = ref.watch(gardenStatsProvider);
    final total = stats['total'] ?? 0;

    if (total == 0) return const SizedBox.shrink();

    final active = (stats['startedIndoors'] ?? 0) +
        (stats['hardeningOff'] ?? 0) +
        (stats['transplanted'] ?? 0) +
        (stats['growing'] ?? 0) +
        (stats['harvesting'] ?? 0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.yard, size: 18, color: Colors.green),
            const SizedBox(width: 8),
            Text(
              '$active growing',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
