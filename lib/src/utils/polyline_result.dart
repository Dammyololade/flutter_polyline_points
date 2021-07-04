import 'package:flutter_polyline_points/src/utils/geocoded_waypoint.dart';
import 'package:flutter_polyline_points/src/utils/route.dart';
import 'package:flutter_polyline_points/src/utils/status_code.dart';

/// description:
/// project: flutter_polyline_points
/// @package:
/// @author: dammyololade
/// created on: 13/05/2020
class PolylineResult {
  /// the api status retuned from google api
  ///
  /// returns OK if the api call is successful
  StatusCode status;

  /// list of decoded points
  List<Route> routes;

  /// the error message returned from google, if none, the result will be empty
  String errorMessage;

  /// Correspond to the origin, the waypoints in the order they are specified, 
  /// and the destination.
  List<GeocodedWaypoint> geocodedWaypoints;

  PolylineResult({
    this.status = StatusCode.OK,
    this.routes = const [],
    this.errorMessage = "",
    this.geocodedWaypoints = const [],
  });
}
