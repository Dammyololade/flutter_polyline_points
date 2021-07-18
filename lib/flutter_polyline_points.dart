library flutter_polyline_points;

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
export 'src/utils/bounds.dart';
export 'src/utils/geocoded_waypoint.dart';
export 'src/utils/leg.dart';
export 'src/utils/route.dart';
export 'src/utils/status_code.dart';

class PolylinePoints {
  NetworkUtil util = NetworkUtil();

  /// Get the list of coordinates between two geographical positions
  /// which can be used to draw polyline between this two positions
  ///
  Future<PolylineResult> getRouteBetweenCoordinates(
    String googleApiKey, {
    PointLatLng? origin,
    PointLatLng? destination,
    String? originPlaceId,
    String? destinationPlaceId,
    TravelMode travelMode = TravelMode.driving,
    List<PolylineWayPoint> wayPoints = const [],
    bool avoidHighways = false,
    bool avoidTolls = false,
    bool avoidFerries = true,
    bool optimizeWaypoints = false,
    bool alternatives = false,
  }) {
    assert(
      (origin != null || originPlaceId != null),
      "origin or originPlaceId must be specified",
    );
    assert(
      (destination != null || destinationPlaceId != null),
      "destination or destinationPlaceId must be specified",
    );
    return util.getRouteBetweenCoordinates(
      googleApiKey,
      origin,
      destination,
      originPlaceId,
      destinationPlaceId,
      travelMode,
      wayPoints,
      avoidHighways,
      avoidTolls,
      avoidFerries,
      optimizeWaypoints,
      alternatives,
    );
  }

  /// Decode the json body returned by the Directions API.
  ///
  /// This is useful if you want to call the API on your own server
  /// instead of on the client.
  PolylineResult parseJson(dynamic json) {
    return util.parseJson(json);
  }

  /// Decode and encoded google polyline
  /// e.g "_p~iF~ps|U_ulLnnqC_mqNvxq`@"
  ///
  List<PointLatLng> decodePolyline(String encodedString) {
    return util.decodeEncodedPolyline(encodedString);
  }
}
