class Location {
  final String name;
  final double latitude;
  final double longitude;
  final String timezone;

  const Location({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  Location copyWith({
    String? name,
    double? latitude,
    double? longitude,
    String? timezone,
  }) {
    return Location(
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timezone: timezone ?? this.timezone,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'timezone': timezone,
      };

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        name: json['name'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        timezone: json['timezone'] as String,
      );

  // Default location: Wooster, OH
  static const defaultLocation = Location(
    name: 'Wooster, OH',
    latitude: 40.8051,
    longitude: -81.9351,
    timezone: 'America/New_York',
  );
}
