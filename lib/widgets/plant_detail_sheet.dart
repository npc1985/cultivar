/// Plant detail bottom sheet for viewing full plant information
library;

import 'package:flutter/material.dart';
import '../models/plant.dart';

/// Shows a detailed bottom sheet for a plant
void showPlantDetailSheet(BuildContext context, Plant plant, {VoidCallback? onAddToGarden}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => PlantDetailSheet(
      plant: plant,
      onAddToGarden: onAddToGarden,
    ),
  );
}

/// Draggable bottom sheet showing full plant details
class PlantDetailSheet extends StatelessWidget {
  const PlantDetailSheet({
    super.key,
    required this.plant,
    this.onAddToGarden,
  });

  final Plant plant;
  final VoidCallback? onAddToGarden;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
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

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Header
                    _buildHeader(context),
                    const SizedBox(height: 20),

                    // Badges
                    _buildBadges(context),
                    const SizedBox(height: 20),

                    // Timing
                    if (plant.timingDescription.isNotEmpty) ...[
                      _buildSection(context, 'Planting Timing', Icons.schedule),
                      _buildInfoCard(context, plant.timingDescription),
                      const SizedBox(height: 16),
                    ],

                    // Cold Hardiness
                    _buildSection(context, 'Cold Hardiness', Icons.ac_unit),
                    _buildInfoCard(context, plant.hardinessDescription),
                    const SizedBox(height: 16),

                    // Growing Conditions
                    _buildSection(context, 'Growing Conditions', Icons.wb_sunny_outlined),
                    _buildConditionsCard(context),
                    const SizedBox(height: 16),

                    // Care Notes
                    if (plant.careNotes.isNotEmpty) ...[
                      _buildSection(context, 'Care Notes', Icons.tips_and_updates_outlined),
                      _buildInfoCard(context, plant.careNotes),
                      const SizedBox(height: 16),
                    ],

                    // Medicinal Uses
                    if (plant.medicinalUses.isNotEmpty) ...[
                      _buildSection(context, 'Medicinal & Health Uses', Icons.local_hospital),
                      _buildListCard(context, plant.medicinalUses),
                      const SizedBox(height: 16),
                    ],

                    // Edible Parts
                    if (plant.edibleParts.isNotEmpty) ...[
                      _buildSection(context, 'Edible Parts', Icons.restaurant),
                      _buildListCard(context, plant.edibleParts),
                      const SizedBox(height: 16),
                    ],

                    // Companion Planting
                    if (plant.companionPlants.isNotEmpty) ...[
                      _buildSection(context, 'Good Companions', Icons.favorite_outline),
                      _buildChipsCard(context, plant.companionPlants, Colors.green),
                      const SizedBox(height: 16),
                    ],

                    // Avoid Planting With
                    if (plant.avoidPlanting.isNotEmpty) ...[
                      _buildSection(context, 'Avoid Planting Near', Icons.block),
                      _buildChipsCard(context, plant.avoidPlanting, Colors.red),
                      const SizedBox(height: 16),
                    ],

                    // Biodynamic
                    if (plant.bestMoonSigns.isNotEmpty) ...[
                      _buildSection(context, 'Biodynamic Planting', Icons.nightlight_round),
                      _buildInfoCard(context, plant.biodynamicAdvice),
                      const SizedBox(height: 16),
                    ],

                    // Pests & Diseases
                    if (plant.pestNotes.isNotEmpty) ...[
                      _buildSection(context, 'Pests & Diseases', Icons.bug_report_outlined),
                      _buildListCard(context, plant.pestNotes),
                      const SizedBox(height: 16),
                    ],

                    // Propagation
                    if (plant.propagationNotes.isNotEmpty) ...[
                      _buildSection(context, 'Propagation & Seed Saving', Icons.autorenew),
                      _buildInfoCard(context, plant.propagationNotes),
                      const SizedBox(height: 16),
                    ],

                    // Preparation & Usage (Herbalism)
                    if (plant.preparationNotes.isNotEmpty) ...[
                      _buildSection(context, 'Preparation & Usage', Icons.science_outlined),
                      _buildInfoCard(context, plant.preparationNotes),
                      const SizedBox(height: 16),
                    ],

                    // Permaculture Info
                    if (plant.permacultureFunctions.isNotEmpty || plant.guilds.isNotEmpty) ...[
                      _buildSection(context, 'Permaculture', Icons.eco),
                      _buildPermacultureCard(context),
                      const SizedBox(height: 16),
                    ],

                    // Varieties
                    if (plant.varieties.isNotEmpty) ...[
                      _buildSection(context, 'Recommended Varieties', Icons.category_outlined),
                      _buildChipsCard(context, plant.varieties, theme.colorScheme.primary),
                      const SizedBox(height: 16),
                    ],

                    // Add to Garden button
                    if (onAddToGarden != null) ...[
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: () {
                          onAddToGarden!();
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add to My Garden'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Large emoji
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              plant.emoji,
              style: const TextStyle(fontSize: 40),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Name and scientific name
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plant.commonName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (plant.scientificName != null)
                Text(
                  plant.scientificName!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                '${plant.category.emoji} ${plant.category.displayName}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadges(BuildContext context) {
    final theme = Theme.of(context);
    final badges = <Widget>[];

    if (plant.isHeirloom) {
      badges.add(_buildBadge(
        context,
        Icons.auto_awesome,
        'Heirloom',
        theme.colorScheme.tertiary,
      ));
    }

    if (plant.isNative) {
      badges.add(_buildBadge(
        context,
        Icons.forest,
        'Native',
        Colors.green.shade700,
      ));
    }

    if (plant.medicinalUses.isNotEmpty) {
      badges.add(_buildBadge(
        context,
        Icons.local_hospital,
        'Medicinal',
        Colors.red.shade400,
      ));
    }

    if (plant.isFrostTolerant) {
      badges.add(_buildBadge(
        context,
        Icons.ac_unit,
        'Frost Tolerant',
        Colors.blue.shade400,
      ));
    }

    if (plant.canGrowIndoors) {
      badges.add(_buildBadge(
        context,
        Icons.home,
        'Indoor Friendly',
        Colors.purple.shade400,
      ));
    }

    if (badges.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: badges,
    );
  }

  Widget _buildBadge(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String content) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        content,
        style: theme.textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildConditionsCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildConditionRow(context, Icons.straighten, 'Spacing', plant.spacing),
          const SizedBox(height: 8),
          _buildConditionRow(context, Icons.wb_sunny_outlined, 'Sun', plant.sunRequirement),
          if (plant.wateringNotes.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildConditionRow(context, Icons.water_drop_outlined, 'Water', plant.wateringNotes),
          ],
          if (plant.feedingNotes.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildConditionRow(context, Icons.eco_outlined, 'Feed', plant.feedingNotes),
          ],
          const SizedBox(height: 8),
          _buildConditionRow(
            context,
            Icons.calendar_today,
            'Days to Harvest',
            plant.daysToMaturity >= 365
                ? '${(plant.daysToMaturity / 365).round()} year(s)'
                : '${plant.daysToMaturity} days',
          ),
        ],
      ),
    );
  }

  Widget _buildConditionRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _buildListCard(BuildContext context, List<String> items) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                      Expanded(
                        child: Text(
                          item,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildChipsCard(BuildContext context, List<String> items, Color color) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: items
            .map((item) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildPermacultureCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Zone info
          if (plant.permacultureZone != null) ...[
            Row(
              children: [
                Icon(
                  Icons.layers,
                  size: 16,
                  color: Colors.green.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Zone ${plant.permacultureZone}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // Functions
          if (plant.permacultureFunctions.isNotEmpty) ...[
            Text(
              'Functions',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: plant.permacultureFunctions
                  .map((func) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          func,
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 11,
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
          ],

          // Guilds
          if (plant.guilds.isNotEmpty) ...[
            Text(
              'Guild Suggestions',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: plant.guilds
                  .map((guild) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.teal.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          guild,
                          style: TextStyle(
                            color: Colors.teal.shade700,
                            fontSize: 11,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
