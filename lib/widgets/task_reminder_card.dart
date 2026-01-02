/// Task reminder card widget for the Cultivation tab
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/planting_task.dart';
import '../providers/cultivation_provider.dart';
import '../providers/garden_provider.dart';
import '../services/cultivation_service.dart';

/// Section showing upcoming planting tasks
class UpcomingTasksSection extends ConsumerWidget {
  const UpcomingTasksSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tasks = ref.watch(topPriorityTasksProvider);
    final service = ref.watch(cultivationServiceProvider);

    if (tasks.isEmpty) {
      return const SizedBox.shrink();
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
                Icons.task_alt,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Upcoming Tasks',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _TaskBadges(tasks: tasks, service: service),
            ],
          ),
        ),

        // Task cards
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskCard(
                task: task,
                urgency: service.getUrgency(task),
                onTap: () => _showTaskDetails(context, task),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showTaskDetails(BuildContext context, PlantingTask task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _TaskDetailSheet(task: task),
    );
  }
}

class _TaskBadges extends StatelessWidget {
  const _TaskBadges({
    required this.tasks,
    required this.service,
  });

  final List<PlantingTask> tasks;
  final CultivationService service;

  @override
  Widget build(BuildContext context) {
    final overdue = tasks.where((t) => service.getUrgency(t) == TaskUrgency.overdue).length;
    final urgent = tasks.where((t) => service.getUrgency(t) == TaskUrgency.urgent).length;

    if (overdue == 0 && urgent == 0) return const SizedBox.shrink();

    return Row(
      children: [
        if (overdue > 0)
          _Badge(
            count: overdue,
            color: Colors.red,
            label: 'overdue',
          ),
        if (urgent > 0)
          _Badge(
            count: urgent,
            color: Colors.orange,
            label: 'urgent',
          ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.count,
    required this.color,
    required this.label,
  });

  final int count;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count $label',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Individual task card
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.urgency,
    required this.onTap,
  });

  final PlantingTask task;
  final TaskUrgency urgency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getUrgencyColor(urgency);

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 160,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Urgency badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        urgency.emoji,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task.urgencyDescription,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Task type icon and emoji
                Row(
                  children: [
                    Text(
                      task.type.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const Spacer(),
                    Icon(
                      _getTaskIcon(task.type),
                      size: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ],
                ),
                const Spacer(),

                // Task title
                Text(
                  task.title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Plant name if available
                if (task.plantName != null)
                  Text(
                    task.plantName!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getUrgencyColor(TaskUrgency urgency) {
    return switch (urgency) {
      TaskUrgency.overdue => Colors.red.shade600,
      TaskUrgency.urgent => Colors.orange.shade600,
      TaskUrgency.soon => Colors.amber.shade600,
      TaskUrgency.upcoming => Colors.blue.shade500,
      TaskUrgency.later => Colors.green.shade500,
    };
  }

  IconData _getTaskIcon(TaskType type) {
    return switch (type) {
      TaskType.startIndoors => Icons.home_outlined,
      TaskType.hardenOff => Icons.wb_sunny_outlined,
      TaskType.transplant => Icons.park_outlined,
      TaskType.directSow => Icons.grass,
      TaskType.frostProtection => Icons.ac_unit,
      TaskType.harvest => Icons.content_cut,
      TaskType.prune => Icons.content_cut,
      TaskType.feed => Icons.eco,
      TaskType.water => Icons.water_drop_outlined,
      TaskType.pestControl => Icons.bug_report_outlined,
      TaskType.weed => Icons.grass,
      TaskType.mulch => Icons.layers,
      TaskType.soilPrep => Icons.landscape,
      TaskType.cleanUp => Icons.cleaning_services,
      TaskType.winterize => Icons.severe_cold,
      TaskType.beeTask => Icons.hive,
      TaskType.roseCare => Icons.local_florist,
    };
  }
}

class _TaskDetailSheet extends ConsumerWidget {
  const _TaskDetailSheet({required this.task});

  final PlantingTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

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
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          task.type.emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            task.urgencyDescription,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: task.isOverdue
                                  ? Colors.red
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Description
                if (task.description.isNotEmpty) ...[
                  _buildSection(context, 'What to Do', Icons.info_outline, task.description),
                  const SizedBox(height: 16),
                ],

                // Type info
                _buildSection(
                  context,
                  task.type.displayName,
                  Icons.category_outlined,
                  task.type.description,
                ),

                const SizedBox(height: 24),

                // Action buttons
                FilledButton.icon(
                  onPressed: () async {
                    await ref.read(completedTaskIdsProvider.notifier).markComplete(task.id);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${task.type.emoji} ${task.title} marked as complete!'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Mark as Complete'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),

                const SizedBox(height: 12),

                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                  style: OutlinedButton.styleFrom(
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

  Widget _buildSection(BuildContext context, String title, IconData icon, String content) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
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
        ),
      ],
    );
  }
}

/// Compact task count indicator
class TaskCountIndicator extends ConsumerWidget {
  const TaskCountIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final summary = ref.watch(taskSummaryProvider);
    final hasUrgent = ref.watch(hasUrgentTasksProvider);

    final color = hasUrgent ? Colors.orange : Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasUrgent ? Icons.priority_high : Icons.check_circle_outline,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            summary,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
