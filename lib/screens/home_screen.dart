import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/garden_overview.dart';
import '../widgets/plant_browser.dart';
import '../widgets/task_reminder_card.dart' show UpcomingTasksSection;
import '../widgets/frost_warning_card.dart';
import '../providers/frost_provider.dart';
import '../providers/cultivation_provider.dart';
import 'settings_screen.dart';

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
                // TODO: Show planting calendar
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
class _PlantDatabaseTab extends StatelessWidget {
  const _PlantDatabaseTab();

  @override
  Widget build(BuildContext context) {
    return const PlantBrowser();
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
