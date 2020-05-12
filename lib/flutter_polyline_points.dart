library flutter_polyline_points;

import 'dart:convert';

import 'package:flutter_polyline_points/src/utils/polyline_result.dart';
import 'package:flutter_polyline_points/src/utils/polyline_waypoint.dart';
import 'package:flutter_polyline_points/src/utils/travel_modes.dart';
import 'src/PointLatLng.dart';
import 'src/network_util.dart';

export 'src/utils/travel_modes.dart';
export 'src/utils/polyline_waypoint.dart';
export 'src/network_util.dart';
export 'src/PointLatLng.dart';
export 'src/utils/polyline_result.dart';

class PolylinePoints {
  NetworkUtil util = NetworkUtil();

  /// Get the list of coordinates between two geographical positions
  /// which can be used to draw polyline between this two positions
  ///
  Future<PolylineResult> getRouteBetweenCoordinates(
    String googleApiKey,
    PointLatLng origin,
    PointLatLng destination, {
    TravelMode travelMode = TravelMode.driving,
    List<PolylineWayPoint> wayPoints = const [],
    bool avoidHighways = false,
    bool avoidTolls = false,
    bool avoidFerries = true,
  }) async {
    return await util.getRouteBetweenCoordinates(
        googleApiKey,
        origin,
        destination,
        travelMode,
        wayPoints,
        avoidHighways,
        avoidTolls,
        avoidFerries);
  }

  /// Decode and encoded google polyline
  /// e.g "_p~iF~ps|U_ulLnnqC_mqNvxq`@"
  ///
  List<PointLatLng> decodePolyline(String encodedString) {
    return util.decodeEncodedPolyline(encodedString);
  }
}
