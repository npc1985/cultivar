import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/garden_overview.dart';
import '../widgets/plant_browser.dart';
import '../widgets/task_reminder_card.dart' show UpcomingTasksSection;
import '../widgets/frost_warning_card.dart';
import '../widgets/harvest_history_screen.dart';
import '../providers/frost_provider.dart';
import '../providers/cultivation_provider.dart';
import '../providers/garden_provider.dart';
import '../models/garden.dart';
import 'settings_screen.dart';
import 'calendar_screen.dart';
import 'analytics_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _GardenTab(),
          _PlantDatabaseTab(),
          _TasksTab(),
          AnalyticsScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.yard_outlined),
            selectedIcon: Icon(Icons.yard),
            label: 'Garden',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_florist_outlined),
            selectedIcon: Icon(Icons.local_florist),
            label: 'Plants',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

/// Garden tab - shows user's planted crops
class _GardenTab extends ConsumerWidget {
  const _GardenTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final frostDates = ref.watch(frostDatesProvider);
    final seasonSummary = ref.watch(growingSeasonSummaryProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: const Text('My Garden'),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_month),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CalendarScreen(),
                  ),
                );
              },
              tooltip: 'Planting Calendar',
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Season summary card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          frostDates.maybeWhen(
                            data: (d) => d != null && d.isInGrowingSeason(DateTime.now())
                                ? Icons.wb_sunny
                                : Icons.ac_unit,
                            orElse: () => Icons.schedule,
                          ),
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Growing Season',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              Text(
                                seasonSummary,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Frost warning if any
                const FrostWarningCard(),
                const SizedBox(height: 16),
                // Harvest summary
                const _HarvestSummaryCard(),
                const SizedBox(height: 16),
                // Garden overview
                const GardenOverview(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Plant database tab
class _PlantDatabaseTab extends ConsumerWidget {
  const _PlantDatabaseTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gardenPlantIds = ref.watch(gardenPlantIdsProvider);

    return PlantBrowser(
      gardenPlantIds: gardenPlantIds,
      onAddToGarden: (plant) async {
        // Create a new planted crop with 'planned' status
        final crop = PlantedCrop(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          plantId: plant.id,
          status: CropStatus.planned,
          quantity: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await ref.read(gardenProvider.notifier).addCrop(crop);

        // Show confirmation
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${plant.emoji} ${plant.commonName} added to your garden!'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }
}

/// Tasks tab - shows upcoming planting tasks
class _TasksTab extends ConsumerWidget {
  const _TasksTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(upcomingTasksProvider);
    final taskSummary = ref.watch(taskSummaryProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: const Text('Tasks'),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task summary
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          taskSummary,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Task list
                if (tasks.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No upcoming tasks',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add plants to your garden to see planting tasks',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  const UpcomingTasksSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Harvest summary card showing recent harvests and quick link to history
class _HarvestSummaryCard extends ConsumerWidget {
  const _HarvestSummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recentHarvests = ref.watch(recentHarvestsProvider);
    final stats = ref.watch(harvestStatsProvider);

    // Don't show if no harvests
    if ((stats['totalHarvests'] ?? 0) == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      child: InkWell(
        onTap: () => openHarvestHistory(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Text('🧺', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Harvests',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${stats['thisMonth']} this month • ${stats['totalHarvests']} total',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),

              if (recentHarvests.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Recent harvest items (max 3)
                ...recentHarvests.take(3).map((harvest) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        if (harvest.quality != null)
                          Text(
                            harvest.quality!.emoji,
                            style: const TextStyle(fontSize: 20),
                          )
                        else
                          const Icon(Icons.check_circle, size: 20, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            harvest.quantityDisplay,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          _formatDate(harvest.harvestDate),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';

    return '${date.month}/${date.day}';
  }
}
