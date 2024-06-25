library flutter_polyline_points;

import 'package:flutter_polyline_points/src/utils/polyline_decoder.dart';
import 'package:flutter_polyline_points/src/utils/polyline_request.dart';
import 'package:flutter_polyline_points/src/utils/polyline_result.dart';

import 'src/network_util.dart';
import 'src/point_lat_lng.dart';

export 'src/network_util.dart';
export 'src/point_lat_lng.dart';
export 'src/utils/polyline_request.dart';
export 'src/utils/polyline_result.dart';
export 'src/utils/polyline_waypoint.dart';
export 'src/utils/request_enums.dart';

class PolylinePoints {
  /// Get the list of coordinates between two geographical positions
  /// which can be used to draw polyline between this two positions
  ///
  Future<PolylineResult> getRouteBetweenCoordinates(
      {required PolylineRequest request, String? googleApiKey}) async {
    assert(
        (request.proxy == null &&
                googleApiKey != null &&
                googleApiKey.isNotEmpty) ||
            (request.proxy != null && googleApiKey == null),
        "Google API Key cannot be empty if proxy isn't provided");
    try {
      var result = await NetworkUtil().getRouteBetweenCoordinates(
          request: request, googleApiKey: googleApiKey);
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
      {required PolylineRequest request, String? googleApiKey}) async {
    assert(
        (request.proxy == null &&
                googleApiKey != null &&
                googleApiKey.isNotEmpty) ||
            (request.proxy != null && googleApiKey == null),
        "Google API Key cannot be empty if proxy isn't provided");
    assert(request.arrivalTime == null || request.departureTime == null,
        "You can only specify either arrival time or departure time");
    try {
      return await NetworkUtil().getRouteBetweenCoordinates(request: request, googleApiKey: googleApiKey);
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
