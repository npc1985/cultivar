import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location.dart';

final locationProvider =
    StateNotifierProvider<LocationNotifier, Location>((ref) {
  return LocationNotifier();
});

class LocationNotifier extends StateNotifier<Location> {
  static const String _storageKey = 'saved_location';

  LocationNotifier() : super(Location.defaultLocation) {
    _loadSavedLocation();
  }

  Future<void> _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_storageKey);
    if (saved != null) {
      try {
        state = Location.fromJson(jsonDecode(saved) as Map<String, dynamic>);
      } catch (_) {
        // Use default if parsing fails
      }
    }
  }

  Future<void> setLocation(Location location) async {
    state = location;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(location.toJson()));
  }

  /// Update location from GPS
  Future<bool> updateFromGPS() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied ||
            requested == LocationPermission.deniedForever) {
          return false;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      // Update with GPS coordinates (keep existing name or use generic)
      await setLocation(state.copyWith(
        latitude: position.latitude,
        longitude: position.longitude,
      ));

      return true;
    } catch (_) {
      return false;
    }
  }
}
