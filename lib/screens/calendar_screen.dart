/// Full-screen planting calendar view
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/planting_calendar.dart';

/// Full-screen planting calendar with additional controls
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planting Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const _CalendarHelpDialog(),
              );
            },
            tooltip: 'About this calendar',
          ),
        ],
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            PlantingCalendar(),
            SizedBox(height: 24),
            _CalendarLegend(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Extended legend explaining the calendar
class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How to Use This Calendar',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _LegendItem(
                color: Colors.purple.shade400,
                label: 'Start Indoors',
                description: 'Start seeds indoors under lights',
              ),
              const SizedBox(height: 8),
              _LegendItem(
                color: Colors.green.shade500,
                label: 'Transplant',
                description: 'Move seedlings to the garden',
              ),
              const SizedBox(height: 8),
              _LegendItem(
                color: Colors.blue.shade500,
                label: 'Direct Sow',
                description: 'Plant seeds directly in garden',
              ),
              const SizedBox(height: 8),
              _LegendItem(
                color: Colors.orange.shade500,
                label: 'Harvest',
                description: 'Expected harvest window',
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 20,
                    color: Colors.cyan.shade300,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Frost dates - Last spring frost / First fall frost',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 20,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Today - Current date marker',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.description,
  });

  final Color color;
  final String label;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color, width: 1.5),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Help dialog explaining calendar features
class _CalendarHelpDialog extends StatelessWidget {
  const _CalendarHelpDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.calendar_month),
          SizedBox(width: 8),
          Text('About the Calendar'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your planting calendar is personalized based on:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            const _HelpItem(
              icon: Icons.location_on,
              text: 'Your location and USDA hardiness zone',
            ),
            const _HelpItem(
              icon: Icons.ac_unit,
              text: 'Local frost dates (last spring / first fall)',
            ),
            const _HelpItem(
              icon: Icons.yard,
              text: 'Plants you\'ve added to your garden',
            ),
            const _HelpItem(
              icon: Icons.schedule,
              text: 'Each plant\'s optimal planting windows',
            ),
            const SizedBox(height: 16),
            Text(
              'The calendar shows when to:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• Start seeds indoors\n'
              '• Transplant seedlings outside\n'
              '• Direct sow seeds in the garden\n'
              '• Expect to harvest',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '💡 Add more plants to your garden to see their planting schedules on the calendar!',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Got it'),
        ),
      ],
    );
  }
}

class _HelpItem extends StatelessWidget {
  const _HelpItem({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
