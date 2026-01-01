/// Plant database browser widget for the Cultivation tab
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/plant.dart';
import '../providers/plant_provider.dart';
import 'plant_card.dart';
import 'plant_detail_sheet.dart';

/// Full plant database browser with category tabs and search
class PlantBrowser extends ConsumerStatefulWidget {
  const PlantBrowser({
    super.key,
    this.onAddToGarden,
    this.gardenPlantIds = const {},
  });

  final void Function(Plant)? onAddToGarden;
  final Set<String> gardenPlantIds;

  @override
  ConsumerState<PlantBrowser> createState() => _PlantBrowserState();
}

/// Special filter types for the plant browser
enum _SpecialFilter {
  medicinal('Medicinal', '💊'),
  native('Native', '🌲'),
  indoor('Indoor', '🏠');

  const _SpecialFilter(this.label, this.emoji);
  final String label;
  final String emoji;
}

class _PlantBrowserState extends ConsumerState<PlantBrowser> {
  final TextEditingController _searchController = TextEditingController();
  PlantCategory? _selectedCategory;
  _SpecialFilter? _specialFilter;
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allPlants = ref.watch(allPlantsProvider);
    final stats = ref.watch(plantDatabaseStatsProvider);

    // Filter plants
    List<Plant> displayPlants;
    if (_selectedCategory != null) {
      displayPlants = ref.watch(plantsByCategoryProvider(_selectedCategory!));
    } else {
      displayPlants = allPlants;
    }

    // Apply special filter
    if (_specialFilter != null) {
      displayPlants = displayPlants.where((plant) {
        return switch (_specialFilter!) {
          _SpecialFilter.medicinal => plant.medicinalUses.isNotEmpty,
          _SpecialFilter.native => plant.isNative,
          _SpecialFilter.indoor => plant.canGrowIndoors,
        };
      }).toList();
    }

    // Apply search filter
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      displayPlants = displayPlants.where((plant) {
        return plant.commonName.toLowerCase().contains(searchQuery) ||
            (plant.scientificName?.toLowerCase().contains(searchQuery) ?? false) ||
            plant.varieties.any((v) => v.toLowerCase().contains(searchQuery)) ||
            plant.medicinalUses.any((u) => u.toLowerCase().contains(searchQuery));
      }).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plant Database',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${stats['total']} plants · ${stats['medicinal']} medicinal · ${stats['native']} native',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  _showSearch ? Icons.close : Icons.search,
                  color: theme.colorScheme.primary,
                ),
                onPressed: () {
                  setState(() {
                    _showSearch = !_showSearch;
                    if (!_showSearch) {
                      _searchController.clear();
                    }
                  });
                },
              ),
            ],
          ),
        ),

        // Search bar (when visible)
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

        // Category chips
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // "All" chip
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text('All (${stats['total']})'),
                  selected: _selectedCategory == null && _specialFilter == null,
                  onSelected: (_) => setState(() {
                    _selectedCategory = null;
                    _specialFilter = null;
                  }),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  selectedColor: theme.colorScheme.primaryContainer,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              // Category chips
              ...PlantCategory.values.map((category) {
                final count = _getCategoryCount(category, stats);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: PlantCategoryChip(
                    category: category,
                    isSelected: _selectedCategory == category,
                    count: count,
                    onTap: () => setState(() {
                      _selectedCategory = _selectedCategory == category ? null : category;
                    }),
                  ),
                );
              }),
            ],
          ),
        ),

        // Special filter chips (Medicinal, Native, Indoor)
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              ..._SpecialFilter.values.map((filter) {
                final count = switch (filter) {
                  _SpecialFilter.medicinal => stats['medicinal'] ?? 0,
                  _SpecialFilter.native => stats['native'] ?? 0,
                  _SpecialFilter.indoor => stats['indoor'] ?? 0,
                };
                final color = switch (filter) {
                  _SpecialFilter.medicinal => Colors.red.shade400,
                  _SpecialFilter.native => Colors.green.shade600,
                  _SpecialFilter.indoor => Colors.blue.shade400,
                };
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(filter.emoji),
                        const SizedBox(width: 4),
                        Text(filter.label),
                        const SizedBox(width: 4),
                        Text(
                          '($count)',
                          style: TextStyle(
                            fontSize: 11,
                            color: _specialFilter == filter
                                ? color
                                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    selected: _specialFilter == filter,
                    onSelected: (_) => setState(() {
                      _specialFilter = _specialFilter == filter ? null : filter;
                    }),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    selectedColor: color.withValues(alpha: 0.2),
                    checkmarkColor: color,
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

        const SizedBox(height: 8),

        // Results count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _getResultsText(displayPlants.length),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Plant list - wrapped in Expanded to take remaining space
        Expanded(
          child: PlantGrid(
            plants: displayPlants,
            gardenPlantIds: widget.gardenPlantIds,
            onPlantTap: (plant) {
              showPlantDetailSheet(
                context,
                plant,
                onAddToGarden: widget.onAddToGarden != null
                    ? () => widget.onAddToGarden!(plant)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }

  int _getCategoryCount(PlantCategory category, Map<String, int> stats) {
    return switch (category) {
      PlantCategory.vegetable => stats['vegetables'] ?? 0,
      PlantCategory.fruit => stats['fruits'] ?? 0,
      PlantCategory.berry => stats['berries'] ?? 0,
      PlantCategory.herb => stats['herbs'] ?? 0,
      PlantCategory.rose => stats['roses'] ?? 0,
      PlantCategory.bees => stats['bees'] ?? 0,
    };
  }

  String _getResultsText(int count) {
    if (_searchController.text.isNotEmpty) {
      return '$count result${count == 1 ? '' : 's'} for "${_searchController.text}"';
    }
    if (_selectedCategory != null) {
      return '$count ${_selectedCategory!.displayName.toLowerCase()}';
    }
    return 'Showing all $count plants';
  }
}

/// Compact plant browser for inline use
class CompactPlantBrowser extends ConsumerWidget {
  const CompactPlantBrowser({
    super.key,
    this.category,
    this.maxItems = 5,
    this.onSeeAll,
    this.onPlantTap,
  });

  final PlantCategory? category;
  final int maxItems;
  final VoidCallback? onSeeAll;
  final void Function(Plant)? onPlantTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final plants = category != null
        ? ref.watch(plantsByCategoryProvider(category!))
        : ref.watch(allPlantsProvider);

    final displayPlants = plants.take(maxItems).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
          child: Row(
            children: [
              if (category != null)
                Text(
                  category!.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category?.displayName ?? 'Quick Plant Picks',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (onSeeAll != null && plants.length > maxItems)
                TextButton(
                  onPressed: onSeeAll,
                  child: Text('See all ${plants.length}'),
                ),
            ],
          ),
        ),

        // Plants
        ...displayPlants.map((plant) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: PlantCard(
                plant: plant,
                onTap: () {
                  if (onPlantTap != null) {
                    onPlantTap!(plant);
                  } else {
                    showPlantDetailSheet(context, plant);
                  }
                },
              ),
            )),
      ],
    );
  }
}
