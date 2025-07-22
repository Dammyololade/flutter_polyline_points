/// Unit systems for distance and duration measurements
enum Units {
  /// Metric system (kilometers, meters)
  metric('METRIC'),
  
  /// Imperial system (miles, feet)
  imperial('IMPERIAL');

  const Units(this.value);
  
  /// The string value used in API requests
  final String value;
  
  /// Convert from string value to enum
  static Units? fromString(String value) {
    for (Units unit in Units.values) {
      if (unit.value == value) {
        return unit;
      }
    }
    return null;
  }
  
  /// Get the distance unit for this system
  String get distanceUnit {
    switch (this) {
      case Units.metric:
        return 'km';
      case Units.imperial:
        return 'mi';
    }
  }
  
  /// Get the short distance unit for this system
  String get shortDistanceUnit {
    switch (this) {
      case Units.metric:
        return 'm';
      case Units.imperial:
        return 'ft';
    }
  }
}