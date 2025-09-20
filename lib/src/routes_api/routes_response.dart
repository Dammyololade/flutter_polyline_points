import 'package:flutter_polyline_points/src/utils/polyline_decoder.dart';
import '../commons/point_lat_lng.dart';

/// Simplified response model for Google Routes API v3.0
/// Focuses on polyline decoding with essential data and raw JSON access
class RoutesApiResponse {
  /// List of simplified routes with decoded polylines
  final List<Route> routes;

  /// Raw JSON response from the API for advanced usage
  final Map<String, dynamic> rawJson;

  /// API response status
  final String? status;

  /// Error message if the request failed
  final String? errorMessage;

  const RoutesApiResponse({
    required this.routes,
    required this.rawJson,
    this.status,
    this.errorMessage,
  });

  /// Create from JSON response
  factory RoutesApiResponse.fromJson(Map<String, dynamic> json) {
    try {
      return RoutesApiResponse(
        routes: json['routes'] != null
            ? (json['routes'] as List)
                .map((route) => Route.fromJson(route))
                .toList()
            : [],
        rawJson: json,
        status: json['status'],
        errorMessage: json['errorMessage'],
      );
    } catch (e) {
      return RoutesApiResponse.error('Error parsing JSON: $e');
    }
  }

  factory RoutesApiResponse.error(String errorMessage) => RoutesApiResponse(
        routes: [],
        rawJson: {},
        status: null,
        errorMessage: errorMessage,
      );

  /// Get the primary (first) route
  Route? get primaryRoute => routes.isNotEmpty ? routes.first : null;

  /// Get alternative routes (excluding the primary route)
  List<Route> get alternativeRoutes =>
      routes.length > 1 ? routes.skip(1).toList() : [];

  /// Check if the response contains any routes
  bool get hasRoutes => routes.isNotEmpty;

  /// Check if the response is successful
  bool get isSuccessful => status == 'OK';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoutesApiResponse &&
        _listEquals(other.routes, routes) &&
        other.rawJson == rawJson &&
        other.status == status &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return Object.hash(
      routes,
      rawJson,
      status,
      errorMessage,
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

/// Simplified route information with essential data and decoded polyline
class Route {
  /// Total route duration in seconds
  final int? duration;

  /// Static duration without traffic in seconds
  final int? staticDuration;

  /// Total route distance in meters
  final int? distanceMeters;

  /// Decoded polyline points for the entire route
  final List<PointLatLng>? polylinePoints;

  /// Encoded polyline string (for reference)
  final String? polylineEncoded;

  const Route({
    this.duration,
    this.staticDuration,
    this.distanceMeters,
    this.polylinePoints,
    this.polylineEncoded,
  });

  /// Create from JSON response
  factory Route.fromJson(Map<String, dynamic> json) {
    final polylineEncoded = json['polyline']?['encodedPolyline'];

    return Route(
      duration: json['duration'] != null
          ? int.tryParse(json['duration'].toString().replaceAll('s', ''))
          : null,
      staticDuration: json['staticDuration'] != null
          ? int.tryParse(json['staticDuration'].toString().replaceAll('s', ''))
          : null,
      distanceMeters: json['distanceMeters'],
      polylineEncoded: polylineEncoded,
      polylinePoints: polylineEncoded?.isNotEmpty == true
          ? PolylineDecoder.run(polylineEncoded)
          : null,
    );
  }

  /// Get total distance in kilometers
  double? get distanceKm {
    return distanceMeters != null ? distanceMeters! / 1000.0 : null;
  }

  /// Get total duration in minutes
  double? get durationMinutes {
    return duration != null ? duration! / 60.0 : null;
  }

  /// Get static duration in minutes
  double? get staticDurationMinutes {
    return staticDuration != null ? staticDuration! / 60.0 : null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Route &&
        other.duration == duration &&
        other.staticDuration == staticDuration &&
        other.distanceMeters == distanceMeters &&
        _listEquals(other.polylinePoints, polylinePoints) &&
        other.polylineEncoded == polylineEncoded;
  }

  @override
  int get hashCode {
    return Object.hash(
      duration,
      staticDuration,
      distanceMeters,
      polylinePoints,
      polylineEncoded,
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
