library flutter_polyline_points;

import 'package:flutter_polyline_points/src/utils/polyline_decoder.dart';
import 'package:flutter_polyline_points/src/utils/polyline_request.dart';
import 'package:flutter_polyline_points/src/utils/polyline_result.dart';
import 'package:flutter_polyline_points/src/utils/polyline_waypoint.dart';
import 'package:flutter_polyline_points/src/utils/request_enums.dart';
import 'src/PointLatLng.dart';
import 'src/network_util.dart';

export 'src/utils/request_enums.dart';
export 'src/utils/polyline_waypoint.dart';
export 'src/network_util.dart';
export 'src/PointLatLng.dart';
export 'src/utils/polyline_result.dart';
export 'src/utils/polyline_request.dart';

class PolylinePoints {
  /// Get the list of coordinates between two geographical positions
  /// which can be used to draw polyline between this two positions
  ///
  Future<PolylineResult> getRouteBetweenCoordinates(
      String googleApiKey, PointLatLng origin, PointLatLng destination,
      {TravelMode travelMode = TravelMode.driving,
      List<PolylineWayPoint> wayPoints = const [],
      bool avoidHighways = false,
      bool avoidTolls = false,
      bool avoidFerries = true,
      bool optimizeWaypoints = false}) async {
    assert(googleApiKey.isNotEmpty, "Google API Key cannot be empty");
    try {
      var result = await NetworkUtil().getRouteBetweenCoordinates(
          request: PolylineRequest(
              apiKey: googleApiKey,
              origin: origin,
              destination: destination,
              mode: travelMode,
              wayPoints: wayPoints,
              avoidHighways: avoidHighways,
              avoidTolls: avoidTolls,
              avoidFerries: avoidFerries,
              alternatives: false,
              optimizeWaypoints: optimizeWaypoints));
      return result.isNotEmpty
          ? result[0]
          : PolylineResult(errorMessage: "No result found");
    } catch (e) {
      rethrow;
    }
  }

  /// Get the list of coordinates between two geographical positions with
  /// alternative routes which can be used to draw polyline between this two positions
  Future<List<PolylineResult>> getRouteWithAlternatives(
      {required PolylineRequest request}) async {
    assert(request.apiKey.isNotEmpty, "Google API Key cannot be empty");
    assert(request.arrivalTime == null || request.departureTime == null,
        "You can only specify either arrival time or departure time");
    try {
      return await NetworkUtil().getRouteBetweenCoordinates(request: request);
    } catch (e) {
      rethrow;
    }
  }

  /// Decode and encoded google polyline
  /// e.g "_p~iF~ps|U_ulLnnqC_mqNvxq`@"
  ///
  List<PointLatLng> decodePolyline(String encodedString) {
    return PolylineDecoder.run(encodedString);
  }
}
