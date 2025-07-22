import '../commons/point_lat_lng.dart';
import '../utils/polyline_request.dart';
import '../utils/polyline_waypoint.dart';
import '../routes_api/routes_request.dart';
import '../commons/travel_mode.dart' as routes_api;
import '../routes_api/enums/routing_preference.dart';
import '../routes_api/enums/units.dart';
import '../routes_api/enums/polyline_quality.dart';
import '../routes_api/route_modifiers.dart';

/// Utility class to convert between legacy and Routes API request formats
/// Enables backward compatibility while leveraging new Routes API features
// ignore_for_file: deprecated_member_use_from_same_package
class RequestConverter {
  /// Convert legacy PolylineRequest to Routes API format
  static RoutesApiRequest convertToRoutesApi(PolylineRequest legacyRequest) {
    return RoutesApiRequest(
      origin: legacyRequest.origin,
      destination: legacyRequest.destination,
      travelMode: legacyRequest.mode,
      intermediates: legacyRequest.wayPoints,
      computeAlternativeRoutes: legacyRequest.alternatives,
      routingPreference: _determineRoutingPreference(legacyRequest),
      units: _determineUnits(legacyRequest),
      polylineQuality: PolylineQuality.overview, // Default for legacy compatibility
      routeModifiers: _createRouteModifiers(legacyRequest),
      departureTime: legacyRequest.departureTime != null 
          ? DateTime.fromMillisecondsSinceEpoch(legacyRequest.departureTime! * 1000) 
          : null,
      arrivalTime: legacyRequest.arrivalTime != null 
          ? DateTime.fromMillisecondsSinceEpoch(legacyRequest.arrivalTime! * 1000) 
          : null,
      optimizeWaypointOrder: legacyRequest.optimizeWaypoints,
    );
  }

  /// Convert Routes API request to legacy format (for fallback scenarios)
  static PolylineRequest convertToLegacy(RoutesApiRequest routesRequest) {
    return PolylineRequest(
      origin: routesRequest.origin,
      destination: routesRequest.destination,
      mode: routesRequest.travelMode,
      wayPoints: routesRequest.intermediates ?? [],
      alternatives: routesRequest.computeAlternativeRoutes,
      departureTime: routesRequest.departureTime?.millisecondsSinceEpoch != null 
          ? (routesRequest.departureTime!.millisecondsSinceEpoch ~/ 1000) 
          : null,
      arrivalTime: routesRequest.arrivalTime?.millisecondsSinceEpoch != null 
          ? (routesRequest.arrivalTime!.millisecondsSinceEpoch ~/ 1000) 
          : null,
      optimizeWaypoints: routesRequest.optimizeWaypointOrder,
      avoidFeatures: _createAvoidFeatures(routesRequest.routeModifiers),
      transitMode: _extractTransitMode(routesRequest),
    );
  }

  /// Determine routing preference based on legacy request parameters
  static RoutingPreference _determineRoutingPreference(PolylineRequest legacyRequest) {
    // Legacy API doesn't have explicit routing preferences
    // Use traffic-unaware as default for compatibility
    return RoutingPreference.trafficUnaware;
  }

  /// Determine units based on legacy request (if available) or default to metric
  static Units _determineUnits(PolylineRequest legacyRequest) {
    // Legacy API doesn't specify units explicitly
    // Default to metric for international compatibility
    return Units.metric;
  }

  /// Create route modifiers from legacy request avoidance options
  static RouteModifiers? _createRouteModifiers(PolylineRequest legacyRequest) {
    if (legacyRequest.avoidFeatures.isEmpty) return null;

    return RouteModifiers(
      avoidTolls: legacyRequest.avoidFeatures.contains(AvoidFeature.tolls),
      avoidHighways: legacyRequest.avoidFeatures.contains(AvoidFeature.highways),
      avoidFerries: legacyRequest.avoidFeatures.contains(AvoidFeature.ferries),
      avoidIndoor: legacyRequest.avoidFeatures.contains(AvoidFeature.indoor),
    );
  }

  /// Create avoid features list from route modifiers
  static List<AvoidFeature> _createAvoidFeatures(RouteModifiers? routeModifiers) {
    if (routeModifiers == null) return [];
    
    final features = <AvoidFeature>[];
    if (routeModifiers.avoidTolls == true) features.add(AvoidFeature.tolls);
    if (routeModifiers.avoidHighways == true) features.add(AvoidFeature.highways);
    if (routeModifiers.avoidFerries == true) features.add(AvoidFeature.ferries);
    if (routeModifiers.avoidIndoor == true) features.add(AvoidFeature.indoor);
    
    return features;
  }

  /// Extract transit mode from Routes API request (for legacy conversion)
  static String? _extractTransitMode(RoutesApiRequest routesRequest) {
    // Routes API doesn't have separate transit modes like legacy API
    // Return null as default
    return null;
  }

  /// Check if a Routes API request can be converted to legacy format
  static bool canConvertToLegacy(RoutesApiRequest routesRequest) {
    // Check if the request uses features not supported by legacy API
    if (routesRequest.travelMode == routes_api.TravelMode.twoWheeler) {
      return false; // Two-wheeler mode not supported in legacy API
    }

    if (routesRequest.routeModifiers?.avoidIndoor == true) {
      return false; // Indoor avoidance not supported in legacy API
    }

    if (routesRequest.routeModifiers?.vehicleInfo != null) {
      return false; // Vehicle info not supported in legacy API
    }

    if (routesRequest.routeModifiers?.tollPasses != null &&
        routesRequest.routeModifiers!.tollPasses!.isNotEmpty) {
      return false; // Toll passes not supported in legacy API
    }

    if (routesRequest.extraComputations != null &&
        routesRequest.extraComputations!.isNotEmpty) {
      return false; // Extra computations not supported in legacy API
    }

    return true;
  }

  /// Get a description of why a Routes API request cannot be converted to legacy
  static String? getConversionBlockerReason(RoutesApiRequest routesRequest) {
    if (routesRequest.travelMode == routes_api.TravelMode.twoWheeler) {
      return 'Two-wheeler travel mode is not supported by the legacy Directions API';
    }

    if (routesRequest.routeModifiers?.avoidIndoor == true) {
      return 'Indoor avoidance is not supported by the legacy Directions API';
    }

    if (routesRequest.routeModifiers?.vehicleInfo != null) {
      return 'Vehicle information is not supported by the legacy Directions API';
    }

    if (routesRequest.routeModifiers?.tollPasses != null &&
        routesRequest.routeModifiers!.tollPasses!.isNotEmpty) {
      return 'Toll passes are not supported by the legacy Directions API';
    }

    if (routesRequest.extraComputations != null &&
        routesRequest.extraComputations!.isNotEmpty) {
      return 'Extra computations are not supported by the legacy Directions API';
    }

    return null; // Can be converted
  }

  /// Create a Routes API request with enhanced features from a legacy request
  static RoutesApiRequest enhanceFromLegacy(
    PolylineRequest legacyRequest, {
    RoutingPreference? routingPreference,
    Units? units,
    PolylineQuality? polylineQuality,
    List<ExtraComputation>? extraComputations,
  }) {
    final baseRequest = convertToRoutesApi(legacyRequest);
    
    return baseRequest.copyWith(
      routingPreference: routingPreference ?? baseRequest.routingPreference,
      units: units ?? baseRequest.units,
      polylineQuality: polylineQuality ?? baseRequest.polylineQuality,
      extraComputations: extraComputations ?? baseRequest.extraComputations,
    );
  }

  /// Create a simplified Routes API request for basic routing
  static RoutesApiRequest createSimpleRequest({
    required PointLatLng origin,
    required PointLatLng destination,
    routes_api.TravelMode travelMode = routes_api.TravelMode.driving,
    List<PolylineWayPoint>? waypoints,
    bool alternatives = false,
  }) {
    return RoutesApiRequest(
      origin: origin,
      destination: destination,
      travelMode: travelMode,
      intermediates: waypoints,
      computeAlternativeRoutes: alternatives,
      routingPreference: RoutingPreference.trafficUnaware,
      units: Units.metric,
      polylineQuality: PolylineQuality.overview,
    );
  }

  /// Create an enhanced Routes API request with all modern features
  static RoutesApiRequest createEnhancedRequest({
    required PointLatLng origin,
    required PointLatLng destination,
    routes_api.TravelMode travelMode = routes_api.TravelMode.driving,
    List<PolylineWayPoint>? waypoints,
    bool alternatives = false,
    RoutingPreference routingPreference = RoutingPreference.trafficAware,
    Units units = Units.metric,
    PolylineQuality polylineQuality = PolylineQuality.highQuality,
    RouteModifiers? routeModifiers,
    List<ExtraComputation>? extraComputations,
    String? languageCode,
    String? regionCode,
  }) {
    return RoutesApiRequest(
      origin: origin,
      destination: destination,
      travelMode: travelMode,
      intermediates: waypoints,
      computeAlternativeRoutes: alternatives,
      routingPreference: routingPreference,
      units: units,
      polylineQuality: polylineQuality,
      routeModifiers: routeModifiers,
      extraComputations: extraComputations ?? [
        ExtraComputation.tolls,
        ExtraComputation.trafficOnPolyline,
      ],
      languageCode: languageCode,
      regionCode: regionCode,
    );
  }
}