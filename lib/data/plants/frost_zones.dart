/// USDA Hardiness Zone data and frost date lookup
/// Based on USDA Plant Hardiness Zone Map and average frost dates
library;

import '../../models/frost_dates.dart';

/// Hardiness zone definitions with temperature ranges and average frost dates
const Map<String, HardinessZone> hardinessZones = {
  '2a': HardinessZone(
    zone: '2a',
    minTempF: -50,
    maxTempF: -45,
    avgLastFrostMonth: 6,
    avgLastFrostDay: 1,
    avgFirstFrostMonth: 8,
    avgFirstFrostDay: 31,
    growingSeasonDays: 90,
  ),
  '2b': HardinessZone(
    zone: '2b',
    minTempF: -45,
    maxTempF: -40,
    avgLastFrostMonth: 5,
    avgLastFrostDay: 25,
    avgFirstFrostMonth: 9,
    avgFirstFrostDay: 5,
    growingSeasonDays: 100,
  ),
  '3a': HardinessZone(
    zone: '3a',
    minTempF: -40,
    maxTempF: -35,
    avgLastFrostMonth: 5,
    avgLastFrostDay: 15,
    avgFirstFrostMonth: 9,
    avgFirstFrostDay: 15,
    growingSeasonDays: 120,
  ),
  '3b': HardinessZone(
    zone: '3b',
    minTempF: -35,
    maxTempF: -30,
    avgLastFrostMonth: 5,
    avgLastFrostDay: 10,
    avgFirstFrostMonth: 9,
    avgFirstFrostDay: 20,
    growingSeasonDays: 130,
  ),
  '4a': HardinessZone(
    zone: '4a',
    minTempF: -30,
    maxTempF: -25,
    avgLastFrostMonth: 5,
    avgLastFrostDay: 5,
    avgFirstFrostMonth: 9,
    avgFirstFrostDay: 25,
    growingSeasonDays: 140,
  ),
  '4b': HardinessZone(
    zone: '4b',
    minTempF: -25,
    maxTempF: -20,
    avgLastFrostMonth: 5,
    avgLastFrostDay: 1,
    avgFirstFrostMonth: 10,
    avgFirstFrostDay: 1,
    growingSeasonDays: 150,
  ),
  '5a': HardinessZone(
    zone: '5a',
    minTempF: -20,
    maxTempF: -15,
    avgLastFrostMonth: 4,
    avgLastFrostDay: 25,
    avgFirstFrostMonth: 10,
    avgFirstFrostDay: 5,
    growingSeasonDays: 160,
  ),
  '5b': HardinessZone(
    zone: '5b',
    minTempF: -15,
    maxTempF: -10,
    avgLastFrostMonth: 4,
    avgLastFrostDay: 20,
    avgFirstFrostMonth: 10,
    avgFirstFrostDay: 10,
    growingSeasonDays: 170,
  ),
  '6a': HardinessZone(
    zone: '6a',
    minTempF: -10,
    maxTempF: -5,
    avgLastFrostMonth: 4,
    avgLastFrostDay: 15,
    avgFirstFrostMonth: 10,
    avgFirstFrostDay: 15,
    growingSeasonDays: 180,
  ),
  '6b': HardinessZone(
    zone: '6b',
    minTempF: -5,
    maxTempF: 0,
    avgLastFrostMonth: 4,
    avgLastFrostDay: 10,
    avgFirstFrostMonth: 10,
    avgFirstFrostDay: 20,
    growingSeasonDays: 190,
  ),
  '7a': HardinessZone(
    zone: '7a',
    minTempF: 0,
    maxTempF: 5,
    avgLastFrostMonth: 4,
    avgLastFrostDay: 5,
    avgFirstFrostMonth: 10,
    avgFirstFrostDay: 25,
    growingSeasonDays: 200,
  ),
  '7b': HardinessZone(
    zone: '7b',
    minTempF: 5,
    maxTempF: 10,
    avgLastFrostMonth: 3,
    avgLastFrostDay: 25,
    avgFirstFrostMonth: 11,
    avgFirstFrostDay: 1,
    growingSeasonDays: 220,
  ),
  '8a': HardinessZone(
    zone: '8a',
    minTempF: 10,
    maxTempF: 15,
    avgLastFrostMonth: 3,
    avgLastFrostDay: 15,
    avgFirstFrostMonth: 11,
    avgFirstFrostDay: 10,
    growingSeasonDays: 240,
  ),
  '8b': HardinessZone(
    zone: '8b',
    minTempF: 15,
    maxTempF: 20,
    avgLastFrostMonth: 3,
    avgLastFrostDay: 1,
    avgFirstFrostMonth: 11,
    avgFirstFrostDay: 20,
    growingSeasonDays: 260,
  ),
  '9a': HardinessZone(
    zone: '9a',
    minTempF: 20,
    maxTempF: 25,
    avgLastFrostMonth: 2,
    avgLastFrostDay: 15,
    avgFirstFrostMonth: 12,
    avgFirstFrostDay: 1,
    growingSeasonDays: 290,
  ),
  '9b': HardinessZone(
    zone: '9b',
    minTempF: 25,
    maxTempF: 30,
    avgLastFrostMonth: 2,
    avgLastFrostDay: 1,
    avgFirstFrostMonth: 12,
    avgFirstFrostDay: 15,
    growingSeasonDays: 320,
  ),
  '10a': HardinessZone(
    zone: '10a',
    minTempF: 30,
    maxTempF: 35,
    avgLastFrostMonth: 1,
    avgLastFrostDay: 15,
    avgFirstFrostMonth: 12,
    avgFirstFrostDay: 31,
    growingSeasonDays: 350,
  ),
  '10b': HardinessZone(
    zone: '10b',
    minTempF: 35,
    maxTempF: 40,
    avgLastFrostMonth: 1,
    avgLastFrostDay: 1,
    avgFirstFrostMonth: 12,
    avgFirstFrostDay: 31,
    growingSeasonDays: 365,
  ),
  '11a': HardinessZone(
    zone: '11a',
    minTempF: 40,
    maxTempF: 45,
    avgLastFrostMonth: 1,
    avgLastFrostDay: 1,
    avgFirstFrostMonth: 12,
    avgFirstFrostDay: 31,
    growingSeasonDays: 365,
  ),
  '11b': HardinessZone(
    zone: '11b',
    minTempF: 45,
    maxTempF: 50,
    avgLastFrostMonth: 1,
    avgLastFrostDay: 1,
    avgFirstFrostMonth: 12,
    avgFirstFrostDay: 31,
    growingSeasonDays: 365,
  ),
};

/// Approximate zone lookup by latitude for continental US
/// Returns zone string like "6a" or "7b"
/// This is a rough approximation - actual zones vary by elevation, proximity to water, etc.
String getZoneFromLatitude(double latitude, double longitude) {
  // Adjust for Pacific coast (warmer)
  final isPacificCoast = longitude < -120 && latitude < 49;
  // Adjust for Atlantic coast (milder)
  final isAtlanticCoast = longitude > -77 && latitude < 45;
  // Adjust for Gulf coast (warmest mainland)
  final isGulfCoast = latitude < 32 && longitude > -100 && longitude < -80;
  // Adjust for Florida
  final isFlorida = latitude < 30 && longitude > -88 && longitude < -80;

  int baseZone;

  if (isFlorida) {
    if (latitude < 26) {
      baseZone = 11;
    } else if (latitude < 28) {
      baseZone = 10;
    } else {
      baseZone = 9;
    }
  } else if (isGulfCoast) {
    baseZone = 9;
  } else if (isPacificCoast) {
    if (latitude > 46) {
      baseZone = 8;
    } else if (latitude > 40) {
      baseZone = 9;
    } else {
      baseZone = 10;
    }
  } else if (isAtlanticCoast) {
    // Atlantic coast - adjust by latitude
    if (latitude > 44) {
      baseZone = 5;
    } else if (latitude > 40) {
      baseZone = 6;
    } else if (latitude > 36) {
      baseZone = 7;
    } else if (latitude > 32) {
      baseZone = 8;
    } else {
      baseZone = 9;
    }
  } else {
    // Interior continental - primarily latitude based
    if (latitude > 48) {
      baseZone = 3;
    } else if (latitude > 46) {
      baseZone = 4;
    } else if (latitude > 43) {
      baseZone = 5;
    } else if (latitude > 40) {
      baseZone = 6;
    } else if (latitude > 37) {
      baseZone = 7;
    } else if (latitude > 34) {
      baseZone = 8;
    } else if (latitude > 31) {
      baseZone = 9;
    } else {
      baseZone = 10;
    }
  }

  // Subzone: 'a' for colder half, 'b' for warmer half
  // Use longitude as a rough east/west indicator
  // Eastern locations tend to be slightly colder due to continental climate
  final isEastern = longitude > -95;
  final subzone = isEastern ? 'a' : 'b';

  return '$baseZone$subzone';
}

/// Get hardiness zone from coordinates
HardinessZone? getZoneFromCoordinates(double latitude, double longitude) {
  final zoneStr = getZoneFromLatitude(latitude, longitude);
  return hardinessZones[zoneStr];
}

/// Get frost dates from a hardiness zone
FrostDates getFrostDatesFromZone(HardinessZone zone, {int year = 2025}) {
  return FrostDates(
    lastSpringFrost: DateTime(year, zone.avgLastFrostMonth, zone.avgLastFrostDay),
    firstFallFrost: DateTime(year, zone.avgFirstFrostMonth, zone.avgFirstFrostDay),
    zone: zone,
    isManuallySet: false,
    lastUpdated: DateTime.now(),
  );
}

/// Common US city frost dates for reference/testing
const Map<String, Map<String, dynamic>> cityFrostDates = {
  'Wooster, OH': {
    'zone': '6a',
    'lastFrost': '05-10',
    'firstFrost': '10-10',
  },
  'Columbus, OH': {
    'zone': '6a',
    'lastFrost': '05-05',
    'firstFrost': '10-15',
  },
  'Cleveland, OH': {
    'zone': '6b',
    'lastFrost': '05-01',
    'firstFrost': '10-20',
  },
  'Chicago, IL': {
    'zone': '6a',
    'lastFrost': '05-01',
    'firstFrost': '10-15',
  },
  'Denver, CO': {
    'zone': '5b',
    'lastFrost': '05-05',
    'firstFrost': '10-05',
  },
  'Portland, OR': {
    'zone': '8b',
    'lastFrost': '04-01',
    'firstFrost': '11-15',
  },
  'Seattle, WA': {
    'zone': '8b',
    'lastFrost': '03-20',
    'firstFrost': '11-15',
  },
  'Boston, MA': {
    'zone': '6b',
    'lastFrost': '04-20',
    'firstFrost': '10-20',
  },
  'New York, NY': {
    'zone': '7b',
    'lastFrost': '04-10',
    'firstFrost': '11-01',
  },
  'Philadelphia, PA': {
    'zone': '7a',
    'lastFrost': '04-10',
    'firstFrost': '10-25',
  },
  'Atlanta, GA': {
    'zone': '7b',
    'lastFrost': '03-25',
    'firstFrost': '11-10',
  },
  'Austin, TX': {
    'zone': '8b',
    'lastFrost': '03-01',
    'firstFrost': '11-25',
  },
  'Phoenix, AZ': {
    'zone': '9b',
    'lastFrost': '02-01',
    'firstFrost': '12-15',
  },
  'Los Angeles, CA': {
    'zone': '10a',
    'lastFrost': '01-15',
    'firstFrost': '12-31',
  },
  'San Diego, CA': {
    'zone': '10b',
    'lastFrost': '01-01',
    'firstFrost': '12-31',
  },
  'Miami, FL': {
    'zone': '10b',
    'lastFrost': '01-01',
    'firstFrost': '12-31',
  },
  'Minneapolis, MN': {
    'zone': '4b',
    'lastFrost': '05-10',
    'firstFrost': '10-01',
  },
  'Detroit, MI': {
    'zone': '6a',
    'lastFrost': '05-05',
    'firstFrost': '10-10',
  },
  'Pittsburgh, PA': {
    'zone': '6b',
    'lastFrost': '05-01',
    'firstFrost': '10-15',
  },
  'Asheville, NC': {
    'zone': '7a',
    'lastFrost': '04-15',
    'firstFrost': '10-20',
  },
};
