import 'dart:async';

import 'package:flutter_polyline_points/src/utils/polyline_decoder.dart';

import 'commons/point_lat_lng.dart';
import 'utils/polyline_request.dart';
import 'utils/polyline_result.dart';
import 'network/network_provider.dart';
import 'utils/request_converter.dart';
import 'routes_api/routes_request.dart';
import 'routes_api/routes_response.dart';

/// Enhanced PolylinePoints class supporting both legacy Directions API and new Routes API
/// Provides backward compatibility while enabling access to advanced routing features
// ignore_for_file: deprecated_member_use_from_same_package
class PolylinePoints {
  /// Google API key for accessing routing services
  final String apiKey;

  /// Default timeout for API requests
  final Duration defaultTimeout;

  /// Whether to prefer Routes API over Directions API when both are available
  final bool preferRoutesApi;

  /// Create a new PolylinePointsV2 instance
  PolylinePoints({
    required this.apiKey,
    this.defaultTimeout = const Duration(seconds: 30),
    this.preferRoutesApi = true,
  });

  /// Create instance optimized for legacy API usage
  factory PolylinePoints.legacy(String apiKey) {
    return PolylinePoints(
      apiKey: apiKey,
      preferRoutesApi: false,
    );
  }

  /// Create instance optimized for Routes API usage
  factory PolylinePoints.enhanced(String apiKey) {
    return PolylinePoints(
      apiKey: apiKey,
      preferRoutesApi: true,
    );
  }

  /// Create instance with custom configuration
  factory PolylinePoints.custom({
    required String apiKey,
    Duration? timeout,
    bool? preferRoutesApi,
  }) {
    return PolylinePoints(
      apiKey: apiKey,
      defaultTimeout: timeout ?? const Duration(seconds: 30),
      preferRoutesApi: preferRoutesApi ?? true,
    );
  }

  // ============================================================================
  // LEGACY API METHODS (Backward Compatibility)
  // ============================================================================

  /// Get route between coordinates using legacy Directions API
  ///
  /// This method maintains full backward compatibility with the original API
  Future<PolylineResult> getRouteBetweenCoordinates({
    required PolylineRequest request,
    Duration? timeout,
  }) async {
    return NetworkProvider.getRouteBetweenCoordinates(
      apiKey,
      request,
      timeout: timeout ?? defaultTimeout,
    );
  }

  // ============================================================================
  // ROUTES API METHODS (Enhanced Features)
  // ============================================================================

  /// Get route using the new Routes API with enhanced features
  ///
  /// This method provides access to all new Routes API capabilities including:
  /// - Two-wheeler travel mode
  /// - Real-time traffic information
  /// - Toll information and passes
  /// - Enhanced route modifiers
  /// - High-quality polylines
  Future<RoutesApiResponse> getRouteBetweenCoordinatesV2({
    required RoutesApiRequest request,
    Duration? timeout,
  }) async {

    return NetworkProvider.getRouteBetweenCoordinatesV2(
      apiKey,
      request,
      timeout: timeout ?? defaultTimeout,
    );
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Convert Routes API response to legacy PolylineResult format
  PolylineResult convertToLegacyResult(RoutesApiResponse response) {
    if (response.routes.isEmpty) {
      return PolylineResult(
        points: [],
        errorMessage: response.errorMessage ?? 'No routes found',
        status: 'ZERO_RESULTS',
      );
    }

    final route = response.routes.first;
    final points =
        route.polylineEncoded != null ? PolylineDecoder.run(route.polylineEncoded!) : <PointLatLng>[];

    return PolylineResult(
      points: points,
      status: 'OK',
    );
  }

  /// Check which APIs are available with the current API key
  Future<Map<String, bool>> checkApiAvailability() async {
    return NetworkProvider.checkApiAvailability(apiKey);
  }

  /// Get API usage recommendation for a given request
  String getApiRecommendation(PolylineRequest request) {
    return NetworkProvider.getApiRecommendation(request);
  }

  /// Check if a Routes API request can be converted to legacy format
  bool canConvertToLegacy(RoutesApiRequest request) {
    return RequestConverter.canConvertToLegacy(request);
  }

  /// Get reason why a Routes API request cannot be converted to legacy format
  String? getConversionBlockerReason(RoutesApiRequest request) {
    return RequestConverter.getConversionBlockerReason(request);
  }

  /// Decode and encoded google polyline
  /// e.g "_p~iF~ps|U_ulLnnqC_mqNvxq`@"
  ///
  static List<PointLatLng> decodePolyline(String encodedString) {
    return PolylineDecoder.run(encodedString);
  }

}
