/// Frost date service for zone lookup and frost warnings
library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/frost_dates.dart';
import '../models/plant.dart';
import '../models/garden.dart';
import '../data/plants/frost_zones.dart';

/// Minimal hourly forecast data for frost checking
class HourlyForecast {
  final DateTime time;
  final double temp;

  const HourlyForecast({required this.time, required this.temp});
}

/// Service for managing frost dates and generating frost warnings
class FrostService {
  FrostService();

  static const _frostDatesKey = 'frost_dates';

  /// Get hardiness zone from GPS coordinates
  HardinessZone? getZoneFromCoordinates(double latitude, double longitude) {
    return getZoneFromCoordinates(latitude, longitude);
  }

  /// Get zone string (e.g., "6a") from coordinates
  String getZoneStringFromCoordinates(double latitude, double longitude) {
    return getZoneFromLatitude(latitude, longitude);
  }

  /// Get default frost dates for a zone
  FrostDates getDefaultFrostDates(HardinessZone zone, {int? year}) {
    return getFrostDatesFromZone(zone, year: year ?? DateTime.now().year);
  }

  /// Get frost dates from a zone string
  FrostDates? getFrostDatesFromZoneString(String zoneStr, {int? year}) {
    final zone = hardinessZones[zoneStr];
    if (zone == null) return null;
    return getFrostDatesFromZone(zone, year: year ?? DateTime.now().year);
  }

  /// Auto-detect frost dates from location
  FrostDates? autoDetectFrostDates(double latitude, double longitude) {
    final zone = getZoneFromCoordinates(latitude, longitude);
    if (zone == null) return null;
    return getDefaultFrostDates(zone);
  }

  /// Save frost dates to SharedPreferences
  Future<void> saveFrostDates(FrostDates dates) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_frostDatesKey, jsonEncode(dates.toJson()));
  }

  /// Load frost dates from SharedPreferences
  Future<FrostDates?> loadFrostDates() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_frostDatesKey);
    if (jsonStr == null) return null;

    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return FrostDates.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Clear saved frost dates
  Future<void> clearFrostDates() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_frostDatesKey);
  }

  /// Check hourly forecast for frost risk and generate warnings
  List<FrostWarning> checkFrostRisk(
    List<HourlyForecast> forecasts, {
    List<PlantedCrop>? activeCrops,
    List<Plant>? plantDatabase,
  }) {
    final warnings = <FrostWarning>[];
    final now = DateTime.now();

    // Group forecasts by date and find minimum temperature per night
    final Map<String, double> nightLows = {};
    final Map<String, DateTime> nightDates = {};

    for (final forecast in forecasts) {
      // Only check next 14 days
      if (forecast.time.difference(now).inDays > 14) continue;

      // Only check nighttime hours (8 PM to 8 AM)
      final hour = forecast.time.hour;
      if (hour >= 8 && hour < 20) continue;

      // Use the date of the night (overnight hours belong to previous day's "night")
      final nightKey = hour >= 20
          ? '${forecast.time.year}-${forecast.time.month}-${forecast.time.day}'
          : '${forecast.time.year}-${forecast.time.month}-${forecast.time.day - 1}';

      if (!nightLows.containsKey(nightKey) || forecast.temp < nightLows[nightKey]!) {
        nightLows[nightKey] = forecast.temp;
        nightDates[nightKey] = forecast.time;
      }
    }

    // Generate warnings for nights with freezing temps
    for (final entry in nightLows.entries) {
      final temp = entry.value;
      if (temp <= 36) {
        // Warn when approaching freezing
        final severity = getFrostSeverity(temp);
        final date = nightDates[entry.key]!;

        // Find affected plants if we have garden data
        final affectedPlants = <String>[];
        if (activeCrops != null && plantDatabase != null) {
          for (final crop in activeCrops) {
            if (!crop.status.needsFrostCheck) continue;

            final plant = plantDatabase.where((p) => p.id == crop.plantId).firstOrNull;
            if (plant == null) continue;

            if (plant.needsFrostProtection(temp)) {
              affectedPlants.add(plant.commonName);
            }
          }
        }

        warnings.add(FrostWarning(
          date: date,
          lowTemp: temp,
          severity: severity,
          affectedPlants: affectedPlants,
        ));
      }
    }

    // Sort by date
    warnings.sort((a, b) => a.date.compareTo(b.date));

    return warnings;
  }

  /// Get the most urgent frost warning (if any)
  FrostWarning? getMostUrgentWarning(List<FrostWarning> warnings) {
    if (warnings.isEmpty) return null;

    // Return the soonest warning
    return warnings.first;
  }

  /// Check if we're currently in growing season
  bool isInGrowingSeason(FrostDates frostDates) {
    return frostDates.isInGrowingSeason(DateTime.now());
  }

  /// Get days until/since last spring frost
  int daysFromLastFrost(FrostDates frostDates) {
    return -frostDates.daysUntilLastFrost(DateTime.now());
  }

  /// Get days until first fall frost
  int daysUntilFirstFrost(FrostDates frostDates) {
    return frostDates.daysUntilFirstFrost(DateTime.now());
  }

  /// Get all available zones
  List<String> getAllZones() {
    return hardinessZones.keys.toList()..sort();
  }

  /// Get zone info by zone string
  HardinessZone? getZoneInfo(String zone) {
    return hardinessZones[zone];
  }
}
