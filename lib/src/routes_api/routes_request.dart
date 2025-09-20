import '../commons/point_lat_lng.dart';
import '../utils/polyline_waypoint.dart';
import '../commons/travel_mode.dart';
import 'enums/routing_preference.dart';
import 'enums/units.dart';
import 'enums/polyline_quality.dart';
import 'route_modifiers.dart';

/// Request model for the Google Routes API
/// Supports the new JSON-based request format with enhanced features
class RoutesApiRequest {
  /// Starting point of the route
  final PointLatLng origin;
  
  /// Ending point of the route
  final PointLatLng destination;
  
  /// Travel mode for the route
  final TravelMode travelMode;
  
  /// Intermediate waypoints along the route
  final List<PolylineWayPoint>? intermediates;
  
  /// Whether to compute alternative routes
  final bool computeAlternativeRoutes;
  
  /// Route calculation preferences
  final RoutingPreference routingPreference;
  
  /// Unit system for distances and durations
  final Units units;
  
  /// Quality level for the returned polyline
  final PolylineQuality polylineQuality;
  
  /// Route modifiers (avoidances, vehicle info, etc.)
  final RouteModifiers? routeModifiers;
  
  /// Language code for localized text (e.g., 'en', 'es', 'fr')
  final String? languageCode;
  
  /// Region code for localization (e.g., 'US', 'GB')
  final String? regionCode;
  
  /// Departure time for transit or traffic-aware routing
  final DateTime? departureTime;
  
  /// Arrival time for transit routing
  final DateTime? arrivalTime;
  
  /// Whether to optimize waypoint order
  final bool optimizeWaypointOrder;
  
  /// Extra computations to include in the response
  final List<ExtraComputation>? extraComputations;

  /// Field mask for the response, this would indicate which fields to include in the response
  /// according to the [documentation](https://developers.google.com/maps/documentation/routes/choose_fields#define-response)
  final String? responseFieldMask;

  /// Custom body parameters to include in the request
  /// This allows users to add additional parameters not covered by the current implementation
  final Map<String, dynamic>? customBodyParameters;

  /// Custom headers to include in the HTTP request
  /// This allows users to add additional headers such as Android-specific headers
  /// for restricted API keys (X-Android-Package, X-Android-Cert)
  /// Use the google_api_headers package to automatically generate these headers
  final Map<String, String>? headers;

  const RoutesApiRequest({
    required this.origin,
    required this.destination,
    this.travelMode = TravelMode.driving,
    this.intermediates,
    this.computeAlternativeRoutes = false,
    this.routingPreference = RoutingPreference.trafficUnaware,
    this.units = Units.metric,
    this.polylineQuality = PolylineQuality.overview,
    this.routeModifiers,
    this.languageCode,
    this.regionCode,
    this.departureTime,
    this.arrivalTime,
    this.optimizeWaypointOrder = false,
    this.extraComputations,
    this.responseFieldMask,
    this.customBodyParameters,
    this.headers,
  }) : assert(
          (travelMode != TravelMode.bicycling &&
                  travelMode != TravelMode.walking) ||
              (routingPreference == RoutingPreference.unspecified),
          'Invalid request: Bicycling and walking travel modes must use RoutingPreference.unspecified.',
        );

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'origin': _locationToJson(origin),
      'destination': _locationToJson(destination),
      'travelMode': travelMode.value,
      'routingPreference': routingPreference.value,
      'polylineQuality': polylineQuality.value,
      'computeAlternativeRoutes': computeAlternativeRoutes,
      'units': units.value,
    };

    // Add intermediates if provided
    if (intermediates != null && intermediates!.isNotEmpty) {
      json['intermediates'] = intermediates!
          .map((waypoint) => {
                ..._parseLocationString(waypoint.location),
                'via': !waypoint.stopOver,
              })
          .toList();
      
      if (optimizeWaypointOrder) {
        json['optimizeWaypointOrder'] = true;
      }
    }

    // Add route modifiers if provided
    if (routeModifiers != null) {
      json.addAll(routeModifiers!.toJson());
    }

    // Add localization
    if (languageCode != null) {
      json['languageCode'] = languageCode;
    }
    if (regionCode != null) {
      json['regionCode'] = regionCode;
    }

    // Add timing preferences
    if (departureTime != null) {
      json['departureTime'] = departureTime!.toIso8601String();
    }
    if (arrivalTime != null) {
      json['arrivalTime'] = arrivalTime!.toIso8601String();
    }

    // Add extra computations
    if (extraComputations != null && extraComputations!.isNotEmpty) {
      json['extraComputations'] = extraComputations!
          .map((computation) => computation.value)
          .toList();
    }

    // Add custom body parameters
    if (customBodyParameters != null) {
      json.addAll(customBodyParameters!);
    }

    return json;
  }

  /// Convert location to JSON format
  Map<String, dynamic> _locationToJson(PointLatLng location) {
    return {
      'location': {
        'latLng': {
          'latitude': location.latitude,
          'longitude': location.longitude,
        }
      }
    };
  }

  /// Parse location string (lat,lng format) to JSON format
  Map<String, dynamic> _parseLocationString(String location) {
    final parts = location.split(',');
    if (parts.length != 2) {
      throw ArgumentError('Invalid location format. Expected "lat,lng"');
    }
    final lat = double.parse(parts[0].trim());
    final lng = double.parse(parts[1].trim());
    return _locationToJson(PointLatLng(lat, lng));
  }

  /// Generate field mask for the API request (v3.0 simplified)
  String getFieldMask() {
    if (responseFieldMask != null) {
      return responseFieldMask!;
    }

    final fields = <String>[
      // Essential route information only
      'routes.duration',
      'routes.staticDuration', 
      'routes.distanceMeters',
      'routes.polyline.encodedPolyline',
    ];

    return fields.join(',');
  }

  /// Create a copy with modified values
  RoutesApiRequest copyWith({
    PointLatLng? origin,
    PointLatLng? destination,
    TravelMode? travelMode,
    List<PolylineWayPoint>? intermediates,
    bool? computeAlternativeRoutes,
    RoutingPreference? routingPreference,
    Units? units,
    PolylineQuality? polylineQuality,
    RouteModifiers? routeModifiers,
    String? languageCode,
    String? regionCode,
    DateTime? departureTime,
    DateTime? arrivalTime,
    bool? optimizeWaypointOrder,
    List<ExtraComputation>? extraComputations,
    String? responseFieldMask,
    Map<String, dynamic>? customBodyParameters,
    Map<String, String>? headers,
  }) {
    return RoutesApiRequest(
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      travelMode: travelMode ?? this.travelMode,
      intermediates: intermediates ?? this.intermediates,
      computeAlternativeRoutes: computeAlternativeRoutes ?? this.computeAlternativeRoutes,
      routingPreference: routingPreference ?? this.routingPreference,
      units: units ?? this.units,
      polylineQuality: polylineQuality ?? this.polylineQuality,
      routeModifiers: routeModifiers ?? this.routeModifiers,
      languageCode: languageCode ?? this.languageCode,
      regionCode: regionCode ?? this.regionCode,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      optimizeWaypointOrder: optimizeWaypointOrder ?? this.optimizeWaypointOrder,
      extraComputations: extraComputations ?? this.extraComputations,
      responseFieldMask: responseFieldMask ?? this.responseFieldMask,
      customBodyParameters: customBodyParameters ?? this.customBodyParameters,
      headers: headers ?? this.headers,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoutesApiRequest &&
        other.origin == origin &&
        other.destination == destination &&
        other.travelMode == travelMode &&
        _listEquals(other.intermediates, intermediates) &&
        other.computeAlternativeRoutes == computeAlternativeRoutes &&
        other.routingPreference == routingPreference &&
        other.units == units &&
        other.polylineQuality == polylineQuality &&
        other.routeModifiers == routeModifiers &&
        other.languageCode == languageCode &&
        other.regionCode == regionCode &&
        other.departureTime == departureTime &&
        other.arrivalTime == arrivalTime &&
        other.optimizeWaypointOrder == optimizeWaypointOrder &&
        _listEquals(other.extraComputations, extraComputations);
  }

  @override
  int get hashCode {
    return Object.hash(
      origin,
      destination,
      travelMode,
      intermediates,
      computeAlternativeRoutes,
      routingPreference,
      units,
      polylineQuality,
      routeModifiers,
      languageCode,
      regionCode,
      departureTime,
      arrivalTime,
      optimizeWaypointOrder,
      extraComputations,
    );
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}

/// Extra computations that can be requested from the Routes API
enum ExtraComputation {
  /// Include toll information in the response
  tolls('TOLLS'),
  
  /// Include fuel consumption estimates
  fuelConsumption('FUEL_CONSUMPTION'),
  
  /// Include traffic information along the polyline
  trafficOnPolyline('TRAFFIC_ON_POLYLINE'),
  
  /// Include HTML-formatted navigation instructions
  htmlFormattedNavigationInstructions('HTML_FORMATTED_NAVIGATION_INSTRUCTIONS');

  const ExtraComputation(this.value);
  
  final String value;
  
  static ExtraComputation? fromString(String value) {
    for (ExtraComputation computation in ExtraComputation.values) {
      if (computation.value == value) {
        return computation;
      }
    }
    return null;
  }
}