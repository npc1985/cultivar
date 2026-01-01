/// Plant card widget for the plant database browser
library;

import 'package:flutter/material.dart';
import '../models/plant.dart';

/// Compact card displaying a plant's basic info
class PlantCard extends StatelessWidget {
  const PlantCard({
    super.key,
    required this.plant,
    required this.onTap,
    this.showCategory = false,
    this.isInGarden = false,
  });

  final Plant plant;
  final VoidCallback onTap;
  final bool showCategory;
  final bool isInGarden;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isInGarden
            ? BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
                width: 2,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Emoji icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    plant.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Name and info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            plant.commonName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (plant.isHeirloom)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.auto_awesome,
                              size: 14,
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                        if (plant.isNative)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.forest,
                              size: 14,
                              color: Colors.green.shade700,
                            ),
                          ),
                        if (plant.medicinalUses.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.local_hospital,
                              size: 14,
                              color: Colors.red.shade400,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getSubtitle(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  String _getSubtitle() {
    final parts = <String>[];

    if (showCategory) {
      parts.add(plant.category.displayName);
    }

    // Add timing info
    if (plant.indoorStartWeeks != null) {
      parts.add('Start indoors ${plant.indoorStartWeeks}w early');
    } else if (plant.directSowWeeksBeforeFrost != null) {
      parts.add('Direct sow ${plant.directSowWeeksBeforeFrost}w before frost');
    } else if (plant.directSowWeeksAfterFrost != null) {
      parts.add('Direct sow ${plant.directSowWeeksAfterFrost}w after frost');
    }

    // Add days to maturity
    if (plant.daysToMaturity < 365) {
      parts.add('${plant.daysToMaturity}d to harvest');
    }

    return parts.join(' · ');
  }
}

/// Grid view of plant cards
class PlantGrid extends StatelessWidget {
  const PlantGrid({
    super.key,
    required this.plants,
    required this.onPlantTap,
    this.gardenPlantIds = const {},
  });

  final List<Plant> plants;
  final void Function(Plant) onPlantTap;
  final Set<String> gardenPlantIds;

  @override
  Widget build(BuildContext context) {
    if (plants.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: 48,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'No plants found',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: plants.length,
      itemBuilder: (context, index) {
        final plant = plants[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: PlantCard(
            plant: plant,
            onTap: () => onPlantTap(plant),
            isInGarden: gardenPlantIds.contains(plant.id),
          ),
        );
      },
    );
  }
}

/// Category chip for filtering plants
class PlantCategoryChip extends StatelessWidget {
  const PlantCategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
    this.count,
  });

  final PlantCategory category;
  final bool isSelected;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(category.emoji),
          const SizedBox(width: 4),
          Text(category.displayName),
          if (count != null) ...[
            const SizedBox(width: 4),
            Text(
              '($count)',
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.onPrimaryContainer,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
