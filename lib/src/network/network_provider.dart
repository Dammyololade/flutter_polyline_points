import 'dart:convert';
import 'dart:io';
import 'package:flutter_polyline_points/src/commons/travel_mode.dart';
import 'package:flutter_polyline_points/src/utils/polyline_decoder.dart';
import 'package:http/http.dart' as http;

import '../commons/point_lat_lng.dart';
import '../utils/polyline_request.dart';
import '../utils/polyline_result.dart';
import '../routes_api/routes_request.dart';
import '../routes_api/routes_response.dart';
import '../utils/request_converter.dart';

/// Enhanced network utility class supporting both legacy Directions API and new Routes API
/// Provides backward compatibility while enabling access to new Routes API features
// ignore_for_file: deprecated_member_use_from_same_package
class NetworkProvider {
  static const String _directionsBaseUrl = 'https://maps.googleapis.com/maps/api/directions/json';
  static const String _routesBaseUrl = 'https://routes.googleapis.com/directions/v2:computeRoutes';

  /// Default timeout for HTTP requests
  static const Duration _defaultTimeout = Duration(seconds: 30);

  /// Get route using legacy Directions API (for backward compatibility)
  /// Supports only basic features
  ///
  /// @param [apiKey] - Google Maps API key
  /// @param [PolylineRequest] - PolylineRequest object
  /// @param [timeout] - Optional timeout for the request
  /// @return [PolylineResult] object with decoded points
  static Future<PolylineResult> getRouteBetweenCoordinates(
    String googleApiKey,
    PolylineRequest request, {
    Duration? timeout,
  }) async {
    final uri = _buildDirectionsUri(googleApiKey, request);

    try {
      final response = await http
          .get(
            uri,
            headers: _getDirectionsHeaders(),
          )
          .timeout(timeout ?? _defaultTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseDirectionsResponse(data);
      } else {
        return PolylineResult.error(
          'Failed to fetch route: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      if (e is HttpException) rethrow;
      throw HttpException('Network error: ${e.toString()}');
    }
  }

  /// Get route using new Routes API with enhanced features
  /// Supports all Routes API features
  ///
  /// @param [apiKey] - Google Maps API key
  /// @param [RoutesApiRequest] - RoutesApiRequest object
  /// @param [timeout] - Optional timeout for the request
  /// @return [RoutesApiResponse] object with decoded points
  static Future<RoutesApiResponse> getRouteBetweenCoordinatesV2(
    String googleApiKey,
    RoutesApiRequest request, {
    Duration? timeout,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(_routesBaseUrl),
            headers: _getRoutesHeaders(googleApiKey, request),
            body: json.encode(request.toJson()),
          )
          .timeout(timeout ?? _defaultTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RoutesApiResponse.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        return RoutesApiResponse.error(
            'Routes API error: ${response.statusCode} - ${errorData['error']?['message'] ?? response.reasonPhrase}');
      }
    } catch (e) {
      if (e is HttpException) rethrow;
      throw HttpException('Network error: ${e.toString()}');
    }
  }

  /// Build URI for legacy Directions API
  static Uri _buildDirectionsUri(String apiKey, PolylineRequest request) {
    final queryParams = <String, String>{
      'key': apiKey,
      'origin': _formatLocation(request.origin),
      'destination': _formatLocation(request.destination),
      'mode': request.mode.name,
    };

    // Add waypoints if present
    if (request.wayPoints.isNotEmpty) {
      final waypoints =
          request.wayPoints.map((wp) => '${wp.stopOver ? '' : 'via:'}${wp.location}').join('|');
      queryParams['waypoints'] = waypoints;
    }

    // Add optional parameters
    if (request.alternatives == true) {
      queryParams['alternatives'] = 'true';
    }
    // Language and region are not properties of PolylineRequest
    // These would be handled at the API client level
    if (request.avoidFeatures.isNotEmpty) {
      queryParams['avoid'] = _buildAvoidString(request);
    }
    if (request.departureTime != null) {
      queryParams['departure_time'] = (request.departureTime! ~/ 1000).toString();
    }
    if (request.arrivalTime != null) {
      queryParams['arrival_time'] = (request.arrivalTime! ~/ 1000).toString();
    }
    if (request.optimizeWaypoints == true) {
      queryParams['optimize'] = 'true';
    }

    return Uri.parse(_directionsBaseUrl).replace(queryParameters: queryParams);
  }

  /// Format location for API request
  static String _formatLocation(PointLatLng location) {
    return '${location.latitude},${location.longitude}';
  }

  /// Build avoid string for Directions API
  static String _buildAvoidString(PolylineRequest request) {
    final avoidList = <String>[];
    if (request.avoidFeatures.contains(AvoidFeature.tolls)) avoidList.add('tolls');
    if (request.avoidFeatures.contains(AvoidFeature.highways)) avoidList.add('highways');
    if (request.avoidFeatures.contains(AvoidFeature.ferries)) avoidList.add('ferries');
    return avoidList.join('|');
  }

  /// Get headers for legacy Directions API
  static Map<String, String> _getDirectionsHeaders() {
    return {
      'Content-Type': 'application/json',
      'User-Agent': 'flutter_polyline_points/3.0.0',
    };
  }

  /// Get headers for Routes API
  static Map<String, String> _getRoutesHeaders(
    String apiKey,
    RoutesApiRequest request,
  ) {
    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask': request.getFieldMask(),
      'User-Agent': 'flutter_polyline_points/3.0.0',
    };

    // Add optional headers
    if (request.languageCode != null) {
      headers['Accept-Language'] = request.languageCode!;
    }

    // Add custom headers from request
    if (request.headers != null) {
      headers.addAll(request.headers!);
    }

    return headers;
  }

  /// Parse legacy Directions API response
  static PolylineResult _parseDirectionsResponse(Map<String, dynamic> data) {
    final status = data['status'] as String;

    if (status != 'OK') {
      return PolylineResult(
        points: [],
        errorMessage: data['error_message'] ?? 'Unknown error occurred',
        status: status,
      );
    }

    final routes = data['routes'] as List<dynamic>;
    if (routes.isEmpty) {
      return PolylineResult(
        points: [],
        errorMessage: 'No routes found',
        status: 'ZERO_RESULTS',
      );
    }

    final route = routes.first as Map<String, dynamic>;
    final encodedPoints = route['overview_polyline']['points'];

    return PolylineResult(
      points: PolylineDecoder.run(encodedPoints),
      status: status,
      overviewPolyline: route['overview_polyline']['points'],
      totalDistanceValue:
          route['legs'].map((leg) => leg['distance']['value']).reduce((v1, v2) => v1 + v2),
      distanceTexts: <String>[...route['legs'].map((leg) => leg['distance']['text'])],
      distanceValues: <int>[...route['legs'].map((leg) => leg['distance']['value'])],
      totalDurationValue:
          route['legs'].map((leg) => leg['duration']['value']).reduce((v1, v2) => v1 + v2),
      durationTexts: <String>[...route['legs'].map((leg) => leg['duration']['text'])],
      durationValues: <int>[...route['legs'].map((leg) => leg['duration']['value'])],
      endAddress: route["legs"].last['end_address'],
      startAddress: route["legs"].first['start_address'],
    );
  }

  /// Check API availability and capabilities
  static Future<Map<String, bool>> checkApiAvailability(String apiKey) async {
    final results = <String, bool>{};

    // Test Directions API
    try {
      final testRequest = PolylineRequest(
        origin: PointLatLng(37.7749, -122.4194), // San Francisco
        destination: PointLatLng(37.7849, -122.4094),
        mode: TravelMode.driving,
      );

      await getRouteBetweenCoordinates(apiKey, testRequest, timeout: Duration(seconds: 10));
      results['directions_api'] = true;
    } catch (e) {
      results['directions_api'] = false;
    }

    // Test Routes API
    try {
      final testRequest = RequestConverter.createSimpleRequest(
        origin: PointLatLng(37.7749, -122.4194),
        destination: PointLatLng(37.7849, -122.4094),
      );

      await getRouteBetweenCoordinatesV2(apiKey, testRequest, timeout: Duration(seconds: 10));
      results['routes_api'] = true;
    } catch (e) {
      results['routes_api'] = false;
    }

    return results;
  }

  /// Get API usage recommendations based on request features
  static String getApiRecommendation(PolylineRequest request) {
    final routesRequest = RequestConverter.convertToRoutesApi(request);

    if (!RequestConverter.canConvertToLegacy(routesRequest)) {
      return 'Routes API required: ${RequestConverter.getConversionBlockerReason(routesRequest)}';
    }

    if (request.alternatives == true) {
      return 'Routes API recommended: Better alternative route handling';
    }

    return 'Both APIs supported: Routes API recommended for enhanced features';
  }
}
