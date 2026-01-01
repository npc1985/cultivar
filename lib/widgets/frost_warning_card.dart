/// Frost warning card widget for the Cultivation tab
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/frost_dates.dart';
import '../providers/frost_provider.dart';

/// Displays frost warnings if any are detected in the forecast
class FrostWarningCard extends ConsumerWidget {
  const FrostWarningCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warning = ref.watch(urgentFrostWarningProvider);

    if (warning == null) return const SizedBox.shrink();

    return _FrostWarningBanner(warning: warning);
  }
}

class _FrostWarningBanner extends StatelessWidget {
  const _FrostWarningBanner({required this.warning});

  final FrostWarning warning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getSeverityColor(warning.severity);
    final icon = _getSeverityIcon(warning.severity);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showWarningDetails(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getTimeDescription(),
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        warning.message,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        warning.advice,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getSeverityColor(FrostSeverity severity) {
    return switch (severity) {
      FrostSeverity.light => Colors.blue.shade400,
      FrostSeverity.moderate => Colors.orange.shade400,
      FrostSeverity.hard => Colors.deepOrange.shade400,
      FrostSeverity.severe => Colors.red.shade600,
    };
  }

  IconData _getSeverityIcon(FrostSeverity severity) {
    return switch (severity) {
      FrostSeverity.light => Icons.ac_unit,
      FrostSeverity.moderate => Icons.ac_unit,
      FrostSeverity.hard => Icons.severe_cold,
      FrostSeverity.severe => Icons.severe_cold,
    };
  }

  String _getTimeDescription() {
    final now = DateTime.now();
    final diff = warning.date.difference(now);

    if (diff.inHours < 24) {
      if (diff.inHours < 12) {
        return 'Tonight';
      }
      return 'Tomorrow night';
    }

    final days = diff.inDays;
    if (days == 1) return 'Tomorrow night';
    if (days <= 7) return 'In $days days';
    return 'Next week';
  }

  void _showWarningDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _FrostWarningDetailSheet(warning: warning),
    );
  }
}

class _FrostWarningDetailSheet extends StatelessWidget {
  const _FrostWarningDetailSheet({required this.warning});

  final FrostWarning warning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getSeverityColor(warning.severity);

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
                        color: color.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.severe_cold,
                        color: color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            warning.message,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _formatDate(warning.date),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Advice section
                _buildSection(context, 'What to Do', Icons.tips_and_updates, [
                  warning.advice,
                ]),
                const SizedBox(height: 16),

                // Protection tips based on severity
                _buildSection(context, 'Protection Tips', Icons.shield_outlined, _getProtectionTips()),

                // Affected plants if any
                if (warning.affectedPlants.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSection(context, 'At-Risk Plants', Icons.eco, warning.affectedPlants),
                ],

                const SizedBox(height: 24),

                // Close button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Got It'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, IconData icon, List<String> items) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
                .map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\u2022 ',
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
        ),
      ],
    );
  }

  List<String> _getProtectionTips() {
    return switch (warning.severity) {
      FrostSeverity.light => [
          'Cover tender plants with frost cloth or sheets',
          'Move container plants under cover',
          'Water soil before evening - wet soil holds heat',
        ],
      FrostSeverity.moderate => [
          'Use frost cloth or blankets on all frost-sensitive plants',
          'Bring potted plants indoors or into garage',
          'Mulch heavily around base of plants',
          'Consider using incandescent lights for warmth',
        ],
      FrostSeverity.hard => [
          'Harvest any remaining tender produce',
          'Use multiple layers of protection on plants',
          'Create a cold frame or temporary greenhouse',
          'Move all container plants inside',
        ],
      FrostSeverity.severe => [
          'Harvest everything possible from frost-tender plants',
          'Bring all potted plants inside',
          'Protect perennial crowns with heavy mulch',
          'Consider covering beds with thick plastic',
          'Insulate outdoor faucets and pipes',
        ],
    };
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  Color _getSeverityColor(FrostSeverity severity) {
    return switch (severity) {
      FrostSeverity.light => Colors.blue.shade400,
      FrostSeverity.moderate => Colors.orange.shade400,
      FrostSeverity.hard => Colors.deepOrange.shade400,
      FrostSeverity.severe => Colors.red.shade600,
    };
  }
}

/// Compact frost status indicator showing current frost season info
class FrostSeasonIndicator extends ConsumerWidget {
  const FrostSeasonIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final summary = ref.watch(growingSeasonSummaryProvider);
    final isGrowing = ref.watch(isGrowingSeasonProvider);
    final datesAsync = ref.watch(frostDatesProvider);

    return datesAsync.when(
      data: (dates) {
        if (dates == null) {
          return _buildSetupPrompt(context);
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: (isGrowing == true ? Colors.green : Colors.blue)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isGrowing == true ? Icons.eco : Icons.ac_unit,
                size: 16,
                color: isGrowing == true ? Colors.green : Colors.blue,
              ),
              const SizedBox(width: 6),
              Text(
                summary,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isGrowing == true ? Colors.green : Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildSetupPrompt(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        // TODO: Navigate to frost settings
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              'Set frost dates',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
