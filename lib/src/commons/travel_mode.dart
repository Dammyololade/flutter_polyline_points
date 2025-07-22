/// Enhanced travel modes for the Google Routes API
/// Includes the new two-wheeler mode for motorcycles and scooters
enum TravelMode {
  /// Travel by car, truck, motorcycle, or other motor vehicle
  driving('DRIVE'),

  /// Travel by bicycle
  bicycling('BICYCLE'),

  /// Travel by public transportation (bus, train, subway, etc.)
  transit('TRANSIT'),

  /// Travel on foot
  walking('WALK'),

  /// Travel by motorcycle or scooter (Routes API only)
  /// This mode provides optimized routing for two-wheeled vehicles
  twoWheeler('TWO_WHEELER');

  const TravelMode(this.value);

  /// The string value used in API requests
  final String value;

  /// Convert from string value to enum
  static TravelMode? fromString(String value) {
    for (TravelMode mode in TravelMode.values) {
      if (mode.value == value) {
        return mode;
      }
    }
    return null;
  }

  /// Check if this travel mode is supported by the legacy Directions API
  bool get isLegacySupported {
    switch (this) {
      case TravelMode.driving:
      case TravelMode.bicycling:
      case TravelMode.transit:
      case TravelMode.walking:
        return true;
      case TravelMode.twoWheeler:
        return false;
    }
  }

  /// Get the legacy API equivalent value
  String? get legacyValue {
    if (!isLegacySupported) return null;

    return switch (this) {
      TravelMode.driving => 'driving',
      TravelMode.bicycling => 'bicycling',
      TravelMode.transit => 'transit',
      TravelMode.walking => 'walking',
      _ => null,
    };
  }
}
