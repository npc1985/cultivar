/// Riverpod providers for frost dates and warnings
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/frost_dates.dart';
import '../services/frost_service.dart';
import '../data/plants/frost_zones.dart';
import 'location_provider.dart';
import 'plant_provider.dart';

/// Frost service instance
final frostServiceProvider = Provider<FrostService>((ref) {
  return FrostService();
});

/// Auto-detected zone from GPS location
final autoDetectedZoneProvider = Provider<String>((ref) {
  final location = ref.watch(locationProvider);
  final service = ref.watch(frostServiceProvider);
  return service.getZoneStringFromCoordinates(location.latitude, location.longitude);
});

/// Auto-detected zone info
final autoDetectedZoneInfoProvider = Provider<HardinessZone?>((ref) {
  final zoneStr = ref.watch(autoDetectedZoneProvider);
  return hardinessZones[zoneStr];
});

/// Frost dates state notifier for persistence
class FrostDatesNotifier extends AsyncNotifier<FrostDates?> {
  @override
  Future<FrostDates?> build() async {
    final service = ref.watch(frostServiceProvider);

    // Try to load saved frost dates first
    final saved = await service.loadFrostDates();
    if (saved != null) return saved;

    // Fall back to auto-detection from GPS
    final location = ref.watch(locationProvider);
    return service.autoDetectFrostDates(location.latitude, location.longitude);
  }

  /// Set frost dates from a zone string (e.g., "6a")
  Future<void> setFromZone(String zoneStr, {int? year}) async {
    final service = ref.read(frostServiceProvider);
    final dates = service.getFrostDatesFromZoneString(zoneStr, year: year);
    if (dates != null) {
      await service.saveFrostDates(dates);
      state = AsyncData(dates);
    }
  }

  /// Set custom frost dates
  Future<void> setCustomDates({
    required DateTime lastSpringFrost,
    required DateTime firstFallFrost,
  }) async {
    final service = ref.read(frostServiceProvider);
    final dates = FrostDates(
      lastSpringFrost: lastSpringFrost,
      firstFallFrost: firstFallFrost,
      isManuallySet: true,
      lastUpdated: DateTime.now(),
    );
    await service.saveFrostDates(dates);
    state = AsyncData(dates);
  }

  /// Auto-detect from current GPS location
  Future<void> autoDetect() async {
    final service = ref.read(frostServiceProvider);
    final location = ref.read(locationProvider);

    final dates = service.autoDetectFrostDates(location.latitude, location.longitude);
    if (dates != null) {
      await service.saveFrostDates(dates);
      state = AsyncData(dates);
    }
  }

  /// Clear saved frost dates
  Future<void> clear() async {
    final service = ref.read(frostServiceProvider);
    await service.clearFrostDates();
    // Re-run auto-detection
    await autoDetect();
  }
}

/// Main frost dates provider
final frostDatesProvider = AsyncNotifierProvider<FrostDatesNotifier, FrostDates?>(() {
  return FrostDatesNotifier();
});

/// Frost warnings - requires weather data to be passed in manually
/// In Cultivar, this is empty by default since we don't have weather integration
/// Users can check weather separately for frost warnings
final frostWarningsProvider = Provider<List<FrostWarning>>((ref) {
  // Cultivar doesn't have built-in weather data
  // Frost warnings require integration with a weather service
  return [];
});

/// Most urgent frost warning (if any)
final urgentFrostWarningProvider = Provider<FrostWarning?>((ref) {
  final warnings = ref.watch(frostWarningsProvider);
  final service = ref.watch(frostServiceProvider);
  return service.getMostUrgentWarning(warnings);
});

/// Whether we're in growing season
final isGrowingSeasonProvider = Provider<bool?>((ref) {
  final datesAsync = ref.watch(frostDatesProvider);
  final service = ref.watch(frostServiceProvider);

  return datesAsync.when(
    data: (dates) => dates != null ? service.isInGrowingSeason(dates) : null,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Days since last spring frost (positive) or until it (negative)
final daysFromLastFrostProvider = Provider<int?>((ref) {
  final datesAsync = ref.watch(frostDatesProvider);
  final service = ref.watch(frostServiceProvider);

  return datesAsync.when(
    data: (dates) => dates != null ? service.daysFromLastFrost(dates) : null,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Days until first fall frost
final daysUntilFirstFrostProvider = Provider<int?>((ref) {
  final datesAsync = ref.watch(frostDatesProvider);
  final service = ref.watch(frostServiceProvider);

  return datesAsync.when(
    data: (dates) => dates != null ? service.daysUntilFirstFrost(dates) : null,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// All available hardiness zones for selection
final allZonesProvider = Provider<List<String>>((ref) {
  final service = ref.watch(frostServiceProvider);
  return service.getAllZones();
});

/// Growing season summary text
final growingSeasonSummaryProvider = Provider<String>((ref) {
  final datesAsync = ref.watch(frostDatesProvider);
  final isGrowing = ref.watch(isGrowingSeasonProvider);
  final daysFromLast = ref.watch(daysFromLastFrostProvider);
  final daysUntilFirst = ref.watch(daysUntilFirstFrostProvider);

  return datesAsync.when(
    data: (dates) {
      if (dates == null) return 'Set your frost dates in settings';

      if (isGrowing == true) {
        if (daysUntilFirst != null && daysUntilFirst <= 30) {
          return '$daysUntilFirst days until first frost';
        } else if (daysFromLast != null && daysFromLast <= 30) {
          return '$daysFromLast days since last frost';
        } else {
          return 'Growing season · ${dates.growingSeasonDays} days remaining';
        }
      } else {
        // Off-season
        final daysUntilSpring = dates.daysUntilLastFrost(DateTime.now()).abs();
        if (daysUntilSpring > 0) {
          return '$daysUntilSpring days until last spring frost';
        } else {
          return 'Off-season · Plan next year';
        }
      }
    },
    loading: () => 'Loading...',
    error: (_, __) => 'Error loading frost dates',
  );
});
