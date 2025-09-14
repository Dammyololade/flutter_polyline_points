/// Routing preferences for the Google Routes API
/// Determines how routes are optimized
enum RoutingPreference {
  /// Unspecified, defaults to [trafficUnaware].
  unspecified('ROUTING_PREFERENCE_UNSPECIFIED'),

  /// Prioritize routes with the shortest travel time
  trafficUnaware('TRAFFIC_UNAWARE'),
  
  /// Consider current traffic conditions for optimal time
  trafficAware('TRAFFIC_AWARE'),
  
  /// Prioritize routes that avoid traffic when possible
  trafficAwareOptimal('TRAFFIC_AWARE_OPTIMAL');

  const RoutingPreference(this.value);
  
  /// The string value used in API requests
  final String value;
  
  /// Convert from string value to enum
  static RoutingPreference? fromString(String value) {
    for (RoutingPreference preference in RoutingPreference.values) {
      if (preference.value == value) {
        return preference;
      }
    }
    return null;
  }
  
  /// Get a human-readable description of the routing preference
  String get description {
    switch (this) {
      case RoutingPreference.unspecified:
        return 'Unspecified preference. Defaults to traffic unaware';
      case RoutingPreference.trafficUnaware:
        return 'Fastest route without considering traffic';
      case RoutingPreference.trafficAware:
        return 'Optimal route considering current traffic';
      case RoutingPreference.trafficAwareOptimal:
        return 'Best route avoiding heavy traffic when possible';
    }
  }
}