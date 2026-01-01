/// Planting calendar timeline widget for the Cultivation tab
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/frost_dates.dart';
import '../models/plant.dart';
import '../models/garden.dart';
import '../providers/frost_provider.dart';
import '../providers/garden_provider.dart';
import '../providers/plant_provider.dart';

/// Horizontal timeline showing planting windows relative to frost dates
class PlantingCalendar extends ConsumerWidget {
  const PlantingCalendar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final frostDatesAsync = ref.watch(frostDatesProvider);
    final crops = ref.watch(gardenProvider);
    final plants = ref.watch(allPlantsProvider);

    return frostDatesAsync.when(
      data: (frostDates) {
        if (frostDates == null) {
          return _buildSetupPrompt(context);
        }

        return crops.when(
          data: (cropList) => _buildCalendar(
            context,
            frostDates,
            cropList,
            plants,
          ),
          loading: () => const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSetupPrompt(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
            Icons.calendar_month,
            size: 48,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Set Up Frost Dates',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure your frost dates in Settings to see your personalized planting calendar.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(
    BuildContext context,
    FrostDates frostDates,
    List<PlantedCrop> crops,
    List<Plant> plants,
  ) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    // Build timeline entries for each crop
    final entries = <_TimelineEntry>[];

    for (final crop in crops) {
      final plant = plants.where((p) => p.id == crop.plantId).firstOrNull;
      if (plant == null) continue;

      // Indoor start window
      if (plant.indoorStartWeeks != null) {
        final startDate = frostDates.indoorStartDate(plant.indoorStartWeeks!);
        if (startDate != null) {
          entries.add(_TimelineEntry(
            plantName: plant.commonName,
            emoji: plant.emoji,
            type: _EntryType.indoorStart,
            startDate: startDate,
            endDate: startDate.add(const Duration(days: 14)),
          ));
        }
      }

      // Transplant window
      if (plant.transplantWeeksAfterFrost != null) {
        final transplantDate = frostDates.transplantDate(plant.transplantWeeksAfterFrost!);
        if (transplantDate != null) {
          entries.add(_TimelineEntry(
            plantName: plant.commonName,
            emoji: plant.emoji,
            type: _EntryType.transplant,
            startDate: transplantDate,
            endDate: transplantDate.add(const Duration(days: 14)),
          ));
        }
      }

      // Direct sow window
      if (plant.directSowWeeksAfterFrost != null) {
        final sowDate = frostDates.directSowDate(weeksAfterFrost: plant.directSowWeeksAfterFrost);
        if (sowDate != null) {
          entries.add(_TimelineEntry(
            plantName: plant.commonName,
            emoji: plant.emoji,
            type: _EntryType.directSow,
            startDate: sowDate,
            endDate: sowDate.add(const Duration(days: 21)),
          ));
        }
      } else if (plant.directSowWeeksBeforeFrost != null) {
        final sowDate = frostDates.directSowDate(weeksBeforeFrost: plant.directSowWeeksBeforeFrost);
        if (sowDate != null) {
          entries.add(_TimelineEntry(
            plantName: plant.commonName,
            emoji: plant.emoji,
            type: _EntryType.directSow,
            startDate: sowDate,
            endDate: sowDate.add(const Duration(days: 21)),
          ));
        }
      }

      // Harvest window (if we have expected harvest date)
      if (crop.expectedHarvestDate != null) {
        entries.add(_TimelineEntry(
          plantName: plant.commonName,
          emoji: plant.emoji,
          type: _EntryType.harvest,
          startDate: crop.expectedHarvestDate!,
          endDate: crop.expectedHarvestDate!.add(Duration(days: plant.harvestWindowDays)),
        ));
      }
    }

    // Sort by start date
    entries.sort((a, b) => a.startDate.compareTo(b.startDate));

    // Calculate timeline range (3 months before to 6 months after now)
    final timelineStart = DateTime(now.year, now.month - 2, 1);
    final timelineEnd = DateTime(now.year, now.month + 7, 1);
    final totalDays = timelineEnd.difference(timelineStart).inDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(
                Icons.calendar_month,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Planting Calendar',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Legend
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 12,
            children: [
              _LegendItem(color: Colors.purple.shade400, label: 'Start Indoors'),
              _LegendItem(color: Colors.green.shade500, label: 'Transplant'),
              _LegendItem(color: Colors.blue.shade500, label: 'Direct Sow'),
              _LegendItem(color: Colors.orange.shade500, label: 'Harvest'),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Timeline
        SizedBox(
          height: crops.isEmpty ? 120 : (entries.length.clamp(1, 6) * 44.0 + 60),
          child: crops.isEmpty
              ? _buildEmptyState(context)
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: totalDays * 3.0, // 3 pixels per day
                    child: CustomPaint(
                      painter: _TimelinePainter(
                        entries: entries,
                        frostDates: frostDates,
                        timelineStart: timelineStart,
                        timelineEnd: timelineEnd,
                        now: now,
                        theme: theme,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.yard_outlined,
            size: 32,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 8),
          Text(
            'Add plants to your garden to see your planting schedule',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

enum _EntryType { indoorStart, transplant, directSow, harvest }

class _TimelineEntry {
  final String plantName;
  final String emoji;
  final _EntryType type;
  final DateTime startDate;
  final DateTime endDate;

  const _TimelineEntry({
    required this.plantName,
    required this.emoji,
    required this.type,
    required this.startDate,
    required this.endDate,
  });

  Color get color => switch (type) {
        _EntryType.indoorStart => Colors.purple.shade400,
        _EntryType.transplant => Colors.green.shade500,
        _EntryType.directSow => Colors.blue.shade500,
        _EntryType.harvest => Colors.orange.shade500,
      };
}

class _TimelinePainter extends CustomPainter {
  final List<_TimelineEntry> entries;
  final FrostDates frostDates;
  final DateTime timelineStart;
  final DateTime timelineEnd;
  final DateTime now;
  final ThemeData theme;

  _TimelinePainter({
    required this.entries,
    required this.frostDates,
    required this.timelineStart,
    required this.timelineEnd,
    required this.now,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final totalDays = timelineEnd.difference(timelineStart).inDays;
    final pixelsPerDay = size.width / totalDays;

    // Draw month labels and grid
    _drawMonthGrid(canvas, size, pixelsPerDay);

    // Draw frost date markers
    _drawFrostMarkers(canvas, size, pixelsPerDay);

    // Draw "now" line
    _drawNowLine(canvas, size, pixelsPerDay);

    // Draw entries
    _drawEntries(canvas, size, pixelsPerDay);
  }

  void _drawMonthGrid(Canvas canvas, Size size, double pixelsPerDay) {
    final paint = Paint()
      ..color = theme.colorScheme.outline.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    var current = DateTime(timelineStart.year, timelineStart.month, 1);
    while (current.isBefore(timelineEnd)) {
      final dayOffset = current.difference(timelineStart).inDays;
      final x = dayOffset * pixelsPerDay;

      // Draw vertical line
      canvas.drawLine(Offset(x, 20), Offset(x, size.height), paint);

      // Draw month label
      textPainter.text = TextSpan(
        text: '${months[current.month - 1]} ${current.year.toString().substring(2)}',
        style: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          fontSize: 11,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + 4, 4));

      // Move to next month
      current = DateTime(current.year, current.month + 1, 1);
    }
  }

  void _drawFrostMarkers(Canvas canvas, Size size, double pixelsPerDay) {
    final lastFrost = frostDates.lastSpringFrost;
    final firstFrost = frostDates.firstFallFrost;

    final dashPaint = Paint()
      ..color = Colors.cyan.shade300
      ..strokeWidth = 2;

    // Last spring frost
    final lastFrostDays = lastFrost.difference(timelineStart).inDays;
    if (lastFrostDays >= 0 && lastFrostDays <= timelineEnd.difference(timelineStart).inDays) {
      final x = lastFrostDays * pixelsPerDay;
      _drawDashedLine(canvas, Offset(x, 20), Offset(x, size.height), dashPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: 'Last Frost',
          style: TextStyle(
            color: Colors.cyan.shade300,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      // Rotate and draw text
      canvas.save();
      canvas.translate(x - 6, size.height - 10);
      canvas.rotate(-1.5708); // -90 degrees
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }

    // First fall frost
    final firstFrostDays = firstFrost.difference(timelineStart).inDays;
    if (firstFrostDays >= 0 && firstFrostDays <= timelineEnd.difference(timelineStart).inDays) {
      final x = firstFrostDays * pixelsPerDay;
      _drawDashedLine(canvas, Offset(x, 20), Offset(x, size.height), dashPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: 'First Frost',
          style: TextStyle(
            color: Colors.cyan.shade300,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      canvas.save();
      canvas.translate(x - 6, size.height - 10);
      canvas.rotate(-1.5708);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 3.0;
    var y = start.dy;
    while (y < end.dy) {
      canvas.drawLine(
        Offset(start.dx, y),
        Offset(start.dx, (y + dashWidth).clamp(start.dy, end.dy)),
        paint,
      );
      y += dashWidth + dashSpace;
    }
  }

  void _drawNowLine(Canvas canvas, Size size, double pixelsPerDay) {
    final nowDays = now.difference(timelineStart).inDays;
    final x = nowDays * pixelsPerDay;

    final paint = Paint()
      ..color = Colors.red.shade400
      ..strokeWidth = 2;

    canvas.drawLine(Offset(x, 20), Offset(x, size.height), paint);

    // Draw "Today" label
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Today',
        style: TextStyle(
          color: Colors.red.shade400,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    canvas.save();
    canvas.translate(x - 6, size.height - 10);
    canvas.rotate(-1.5708);
    textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  void _drawEntries(Canvas canvas, Size size, double pixelsPerDay) {
    const rowHeight = 40.0;
    const topOffset = 24.0;

    for (var i = 0; i < entries.length && i < 6; i++) {
      final entry = entries[i];
      final y = topOffset + i * rowHeight;

      final startDays = entry.startDate.difference(timelineStart).inDays;
      final endDays = entry.endDate.difference(timelineStart).inDays;

      final startX = (startDays * pixelsPerDay).clamp(0.0, size.width);
      final endX = (endDays * pixelsPerDay).clamp(0.0, size.width);
      final width = (endX - startX).clamp(40.0, size.width);

      // Draw bar
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(startX, y, width, 28),
        const Radius.circular(6),
      );

      final paint = Paint()..color = entry.color.withValues(alpha: 0.7);
      canvas.drawRRect(rect, paint);

      // Draw border
      final borderPaint = Paint()
        ..color = entry.color
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(rect, borderPaint);

      // Draw emoji and name
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${entry.emoji} ${entry.plantName}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            shadows: [Shadow(blurRadius: 2, color: Colors.black54)],
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '...',
      );
      textPainter.layout(maxWidth: width - 8);
      textPainter.paint(canvas, Offset(startX + 4, y + 6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
