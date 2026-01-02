/// Full-screen garden management widget for large gardens
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/garden.dart';
import '../models/plant.dart';
import '../providers/garden_provider.dart';
import '../providers/plant_provider.dart';
import 'plant_detail_sheet.dart';
import 'crop_photo_gallery.dart';

/// Opens the full garden manager as a bottom sheet
void openGardenManager(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const GardenManagerSheet(),
  );
}

/// Full screen garden manager with filtering, sorting, and search
class GardenManagerSheet extends ConsumerStatefulWidget {
  const GardenManagerSheet({super.key});

  @override
  ConsumerState<GardenManagerSheet> createState() => _GardenManagerSheetState();
}

class _GardenManagerSheetState extends ConsumerState<GardenManagerSheet> {
  final TextEditingController _searchController = TextEditingController();
  CropStatus? _filterStatus;
  PermacultureZone? _filterZone;
  _SortOption _sortOption = _SortOption.status;
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cropsAsync = ref.watch(gardenProvider);
    final stats = ref.watch(gardenStatsProvider);
    final allPlants = ref.watch(allPlantsProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
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

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
            child: Row(
              children: [
                Icon(Icons.yard, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Garden',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${stats['total']} plants',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(_showSearch ? Icons.close : Icons.search),
                  onPressed: () {
                    setState(() {
                      _showSearch = !_showSearch;
                      if (!_showSearch) _searchController.clear();
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Search bar
          if (_showSearch)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search plants...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),

          // Filter chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // All chip
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text('All (${stats['total']})'),
                    selected: _filterStatus == null,
                    onSelected: (_) => setState(() => _filterStatus = null),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    selectedColor: theme.colorScheme.primaryContainer,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                // Status filter chips
                ...CropStatus.values.where((s) => (stats[_statusKey(s)] ?? 0) > 0).map((status) {
                  final count = stats[_statusKey(status)] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(status.emoji),
                          const SizedBox(width: 4),
                          Text('$count'),
                        ],
                      ),
                      selected: _filterStatus == status,
                      onSelected: (_) => setState(() {
                        _filterStatus = _filterStatus == status ? null : status;
                      }),
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      selectedColor: _getStatusColor(status).withValues(alpha: 0.2),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Zone filter chips
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    'Zone:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                ...PermacultureZone.values.map((zone) {
                  final isSelected = _filterZone == zone;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ActionChip(
                      label: Text(
                        '${zone.emoji} ${zone.number}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected ? Colors.green.shade700 : null,
                        ),
                      ),
                      backgroundColor: isSelected
                          ? Colors.green.withValues(alpha: 0.2)
                          : theme.colorScheme.surfaceContainerHighest,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => setState(() {
                        _filterZone = isSelected ? null : zone;
                      }),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Sort dropdown
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Text(
                  'Sort by:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<_SortOption>(
                  value: _sortOption,
                  underline: const SizedBox(),
                  isDense: true,
                  items: _SortOption.values.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(option.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _sortOption = value);
                    }
                  },
                ),
              ],
            ),
          ),

          // Plant list
          Expanded(
            child: cropsAsync.when(
              data: (crops) {
                // Apply filters
                var filtered = crops.where((crop) {
                  if (_filterStatus != null && crop.status != _filterStatus) {
                    return false;
                  }
                  if (_filterZone != null && crop.zone != _filterZone) {
                    return false;
                  }
                  if (_searchController.text.isNotEmpty) {
                    final plant = allPlants.where((p) => p.id == crop.plantId).firstOrNull;
                    final name = plant?.commonName.toLowerCase() ?? '';
                    if (!name.contains(_searchController.text.toLowerCase())) {
                      return false;
                    }
                  }
                  return true;
                }).toList();

                // Apply sorting
                filtered = _sortCrops(filtered, allPlants);

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _filterStatus != null || _searchController.text.isNotEmpty
                              ? 'No plants match filters'
                              : 'Your garden is empty',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final crop = filtered[index];
                    final plant = allPlants.where((p) => p.id == crop.plantId).firstOrNull;
                    return _GardenPlantCard(
                      crop: crop,
                      plant: plant,
                      onTap: () => _showCropDetails(context, crop, plant),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    const Text('Error loading garden'),
                    TextButton(
                      onPressed: () => ref.invalidate(gardenProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PlantedCrop> _sortCrops(List<PlantedCrop> crops, List<Plant> allPlants) {
    return List<PlantedCrop>.from(crops)
      ..sort((a, b) {
        switch (_sortOption) {
          case _SortOption.status:
            // Active statuses first
            final aActive = a.status.needsFrostCheck ? 0 : 1;
            final bActive = b.status.needsFrostCheck ? 0 : 1;
            if (aActive != bActive) return aActive.compareTo(bActive);
            return a.status.index.compareTo(b.status.index);
          case _SortOption.name:
            final aName = allPlants.where((p) => p.id == a.plantId).firstOrNull?.commonName ?? '';
            final bName = allPlants.where((p) => p.id == b.plantId).firstOrNull?.commonName ?? '';
            return aName.compareTo(bName);
          case _SortOption.dateAdded:
            final aDate = a.createdAt ?? DateTime(2000);
            final bDate = b.createdAt ?? DateTime(2000);
            return bDate.compareTo(aDate); // Newest first
          case _SortOption.category:
            final aPlant = allPlants.where((p) => p.id == a.plantId).firstOrNull;
            final bPlant = allPlants.where((p) => p.id == b.plantId).firstOrNull;
            final aCat = aPlant?.category.index ?? 999;
            final bCat = bPlant?.category.index ?? 999;
            return aCat.compareTo(bCat);
          case _SortOption.zone:
            final aZone = a.zone?.number ?? 999;
            final bZone = b.zone?.number ?? 999;
            return aZone.compareTo(bZone);
        }
      });
  }

  String _statusKey(CropStatus status) {
    return switch (status) {
      CropStatus.planned => 'planned',
      CropStatus.ordered => 'ordered',
      CropStatus.startedIndoors => 'startedIndoors',
      CropStatus.hardeningOff => 'hardeningOff',
      CropStatus.transplanted => 'transplanted',
      CropStatus.directSowed => 'directSowed',
      CropStatus.growing => 'growing',
      CropStatus.flowering => 'flowering',
      CropStatus.fruiting => 'fruiting',
      CropStatus.harvesting => 'harvesting',
      CropStatus.dormant => 'dormant',
      CropStatus.completed => 'completed',
      CropStatus.failed => 'failed',
    };
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

  void _showCropDetails(BuildContext context, PlantedCrop crop, Plant? plant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CropDetailSheet(crop: crop, plant: plant),
    );
  }
}

enum _SortOption {
  status('Status'),
  name('Name'),
  dateAdded('Date Added'),
  category('Category'),
  zone('Zone');

  const _SortOption(this.displayName);
  final String displayName;
}

/// Card for displaying a plant in the garden list
class _GardenPlantCard extends StatelessWidget {
  const _GardenPlantCard({
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

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Emoji
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    plant?.emoji ?? '?',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Name and status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            plant?.commonName ?? 'Unknown',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (crop.quantity > 1)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'x${crop.quantity}',
                              style: theme.textTheme.labelSmall,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(crop.status.emoji, style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(
                                crop.status.displayName,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (plant?.category != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            plant!.category.emoji,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                        if (crop.zone != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${crop.zone!.emoji}${crop.zone!.number}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Chevron
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
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

/// Detail sheet for a single crop
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

                // Harvest section
                _buildHarvestSection(context, ref),

                const SizedBox(height: 24),

                // Photo gallery section
                _buildPhotoGallerySection(context, ref),

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

                // Zone selection
                Text(
                  'Permaculture Zone',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // No zone option
                    ActionChip(
                      label: Text(
                        'None',
                        style: TextStyle(
                          color: crop.zone == null ? Colors.green.shade700 : null,
                        ),
                      ),
                      backgroundColor: crop.zone == null
                          ? Colors.green.withValues(alpha: 0.2)
                          : null,
                      onPressed: crop.zone == null
                          ? null
                          : () async {
                              await ref
                                  .read(gardenProvider.notifier)
                                  .updateZone(crop.id, null);
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                    ),
                    ...PermacultureZone.values.map((zone) {
                      final isSelected = crop.zone == zone;
                      return ActionChip(
                        avatar: Text(zone.emoji, style: const TextStyle(fontSize: 14)),
                        label: Text(
                          '${zone.number}',
                          style: TextStyle(
                            color: isSelected ? Colors.green.shade700 : null,
                          ),
                        ),
                        backgroundColor: isSelected
                            ? Colors.green.withValues(alpha: 0.2)
                            : null,
                        onPressed: isSelected
                            ? null
                            : () async {
                                await ref
                                    .read(gardenProvider.notifier)
                                    .updateZone(crop.id, zone);
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              },
                      );
                    }),
                  ],
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

  Widget _buildHarvestSection(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final harvests = ref.watch(harvestsForCropProvider(crop.id));
    final totals = ref.watch(totalHarvestByCropProvider(crop.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '🧺 Harvests',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: () => _showAddHarvestDialog(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Record'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: const Size(0, 32),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Total harvests summary
        if (totals.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Harvested',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                ...totals.entries.map((entry) {
                  final quantity = entry.value;
                  final displayQty = quantity == quantity.truncateToDouble()
                      ? quantity.toInt().toString()
                      : quantity.toStringAsFixed(1);
                  return Text(
                    '$displayQty ${entry.key.abbreviation}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Recent harvests list
        if (harvests.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'No harvests recorded yet',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...harvests.take(3).map((harvest) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Quality emoji
                    if (harvest.quality != null) ...[
                      Text(
                        harvest.quality!.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 12),
                    ],
                    // Harvest info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            harvest.quantityDisplay,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 12,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(harvest.harvestDate),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                          if (harvest.notes != null && harvest.notes!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              harvest.notes!,
                              style: theme.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Preservation methods
                    if (harvest.preservationMethods.isNotEmpty)
                      Text(
                        harvest.preservationMethods.map((m) => m.emoji).join(' '),
                        style: const TextStyle(fontSize: 16),
                      ),
                  ],
                ),
              )),

        // View all link
        if (harvests.length > 3)
          TextButton(
            onPressed: () {
              // TODO: Navigate to full harvest history
            },
            child: Text('View all ${harvests.length} harvests'),
          ),
      ],
    );
  }

  Widget _buildPhotoGallerySection(BuildContext context, WidgetRef ref) {
    return CropPhotoGallery(cropId: crop.id);
  }

  void _showAddHarvestDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _AddHarvestDialog(cropId: crop.id, plantName: plant?.commonName),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';

    return '${date.month}/${date.day}/${date.year}';
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

/// Dialog for adding a new harvest
class _AddHarvestDialog extends ConsumerStatefulWidget {
  const _AddHarvestDialog({
    required this.cropId,
    this.plantName,
  });

  final String cropId;
  final String? plantName;

  @override
  ConsumerState<_AddHarvestDialog> createState() => _AddHarvestDialogState();
}

class _AddHarvestDialogState extends ConsumerState<_AddHarvestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _wetWeightController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  HarvestUnit _selectedUnit = HarvestUnit.pounds;
  HarvestUnit _wetWeightUnit = HarvestUnit.grams;
  HarvestType? _selectedType;
  HarvestQuality? _selectedQuality = HarvestQuality.good;
  final Set<PreservationMethod> _selectedMethods = {};
  bool _showWetWeight = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _wetWeightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('Record Harvest - ${widget.plantName ?? 'Crop'}'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: const Text('Harvest Date'),
                subtitle: Text(_formatDate(_selectedDate)),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
              ),

              const SizedBox(height: 16),

              // Quantity and unit
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<HarvestUnit>(
                      value: _selectedUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                      ),
                      items: HarvestUnit.values.map((unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(unit.displayName),
                        );
                      }).toList(),
                      onChanged: (unit) {
                        if (unit != null) {
                          setState(() => _selectedUnit = unit);
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Wet weight toggle (for cannabis, etc.)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Track wet weight (for drying plants)'),
                value: _showWetWeight,
                onChanged: (value) => setState(() => _showWetWeight = value ?? false),
              ),

              // Wet weight input
              if (_showWetWeight) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _wetWeightController,
                        decoration: const InputDecoration(
                          labelText: 'Wet Weight',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<HarvestUnit>(
                        value: _wetWeightUnit,
                        decoration: const InputDecoration(
                          labelText: 'Unit',
                          border: OutlineInputBorder(),
                        ),
                        items: HarvestUnit.values.map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Text(unit.displayName),
                          );
                        }).toList(),
                        onChanged: (unit) {
                          if (unit != null) {
                            setState(() => _wetWeightUnit = unit);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Harvest Type
              Text(
                'Harvest Type',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Not specified'),
                    selected: _selectedType == null,
                    onSelected: (_) => setState(() => _selectedType = null),
                  ),
                  ...HarvestType.values.map((type) {
                    return FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(type.emoji),
                          const SizedBox(width: 4),
                          Text(type.displayName),
                        ],
                      ),
                      selected: _selectedType == type,
                      onSelected: (_) => setState(() => _selectedType = type),
                    );
                  }),
                ],
              ),

              const SizedBox(height: 16),

              // Quality
              Text(
                'Quality',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('None'),
                    selected: _selectedQuality == null,
                    onSelected: (_) => setState(() => _selectedQuality = null),
                  ),
                  ...HarvestQuality.values.map((quality) {
                    return FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(quality.emoji),
                          const SizedBox(width: 4),
                          Text(quality.displayName),
                        ],
                      ),
                      selected: _selectedQuality == quality,
                      onSelected: (_) => setState(() => _selectedQuality = quality),
                    );
                  }),
                ],
              ),

              const SizedBox(height: 16),

              // Preservation methods
              Text(
                'What did you do with it?',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PreservationMethod.values.map((method) {
                  final isSelected = _selectedMethods.contains(method);
                  return FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(method.emoji),
                        const SizedBox(width: 4),
                        Text(method.displayName),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedMethods.add(method);
                        } else {
                          _selectedMethods.remove(method);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Add any notes about this harvest...',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saveHarvest,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _saveHarvest() async {
    if (!_formKey.currentState!.validate()) return;

    final quantity = double.parse(_quantityController.text);
    final notes = _notesController.text.trim();
    final wetWeight = _showWetWeight && _wetWeightController.text.isNotEmpty
        ? double.tryParse(_wetWeightController.text)
        : null;

    final harvest = Harvest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cropId: widget.cropId,
      harvestDate: _selectedDate,
      quantity: quantity,
      unit: _selectedUnit,
      harvestType: _selectedType,
      wetWeight: wetWeight,
      wetWeightUnit: wetWeight != null ? _wetWeightUnit : null,
      quality: _selectedQuality,
      preservationMethods: _selectedMethods.toList(),
      notes: notes.isEmpty ? null : notes,
    );

    await ref.read(harvestsProvider.notifier).addHarvest(harvest);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harvest recorded: ${harvest.quantityDisplay}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
