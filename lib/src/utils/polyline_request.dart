import 'package:flutter_polyline_points/src/commons/travel_mode.dart';
import 'package:flutter_polyline_points/src/commons/point_lat_lng.dart';
import 'package:flutter_polyline_points/src/utils/polyline_waypoint.dart';

@Deprecated('Use RoutesApiRequest instead')
class PolylineRequest {
  final PointLatLng origin;
  final PointLatLng destination;
  final TravelMode mode;
  final List<PolylineWayPoint> wayPoints;
  final bool optimizeWaypoints;

  /// Specifies one or more preferred modes of transit. This parameter may only
  /// be specified for transit directions.
  /// The parameter supports the following arguments:
  /// bus
  /// rail
  /// subway
  /// train
  /// tram
  final String? transitMode;

  /// If set to true, specifies that the Directions service may provide more
  /// than one route alternative in the response. Note that providing route
  /// alternatives may increase the response time from the server.
  /// This is only available for requests without intermediate waypoints.
  /// For more information, see the guide to waypoints.
  /// https://developers.google.com/maps/documentation/directions/get-directions#Waypoints
  final bool alternatives;

  /// Specifies the desired time of arrival for transit directions, in seconds
  /// since midnight, January 1, 1970 UTC. You can specify either this
  /// or [departureTime], but not both. Note that it must be specified as an integer.
  final int? arrivalTime;

  /// Specifies the desired time of departure. You can specify the time as
  /// an integer in seconds since midnight,
  final int? departureTime;

  final Uri? proxy;

  final Map<String, String>? headers;

  /// Indicates that the calculated route(s) should avoid the indicated features.
  final List<AvoidFeature> avoidFeatures;

  /// The timeout duration defined for this request.
  /// If no response is received within the specified time, the request will be automatically canceled.
  /// This helps prevent the app from becoming unresponsive in cases of connection issues or long-running requests.
  /// The default value is Duration(seconds: 10).
  final Duration timeoutDuration;

  /// If specified, the request will be made through the proxy server.
  final String? proxyUrl;

  PolylineRequest({
    this.proxy,
    this.headers,
    required this.origin,
    required this.destination,
    required this.mode,
    this.wayPoints = const [],
    this.optimizeWaypoints = false,
    this.alternatives = false,
    this.arrivalTime,
    this.departureTime,
    this.transitMode,
    this.proxyUrl,
    this.avoidFeatures = const [],
    this.timeoutDuration = const Duration(seconds: 10),
  });

  void validateKey(String? key) {
    if (key != null && key.isEmpty) {
      throw ArgumentError("API Key cannot empty or null");
    }
  }

  Map<String, dynamic> _getParams() {
    var params = removeNulls({
      "origin": "${origin.latitude},${origin.longitude}",
      "destination": "${destination.latitude},${destination.longitude}",
      "mode": mode.name,
      "alternatives": "$alternatives",
      "arrival_time": arrivalTime,
      "departure_time": departureTime,
      "transit_mode": transitMode
    });

    if (wayPoints.isNotEmpty) {
      List wayPointsArray = [];
      wayPoints.forEach((point) => wayPointsArray.add(point.location));
      String wayPointsString = wayPointsArray.join('|');
      if (optimizeWaypoints) {
        wayPointsString = 'optimize:true|$wayPointsString';
      }
      params.addAll({"waypoints": wayPointsString});
    }

    if (avoidFeatures.isNotEmpty) {
      params.addAll({
        "avoid": avoidFeatures.map((feature) => feature.name).join('|'),
      });
    }

    return params;
  }

  Uri toUri({String? apiKey}) {
    validateKey(apiKey);

    if (proxy != null) {
      return proxy!.replace(
        queryParameters: _getParams(),
      );
    }

    return Uri.https(
      "maps.googleapis.com",
      "maps/api/directions/json",
      _getParams()
        ..addAll(
          {
            'key': apiKey,
          },
        ),
    );
  }

  Map<String, dynamic> removeNulls(Map<String, dynamic> map) {
    map.removeWhere((key, value) => value == null);
    return map;
  }
}

/// Specifies one or more preferred modes of transit.
/// This parameter may only be specified for transit directions.
enum AvoidFeature {
  tolls,
  highways,
  ferries,
  indoor,
}
