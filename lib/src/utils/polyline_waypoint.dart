import 'package:flutter/material.dart';

/// description:
/// project: flutter_polyline_points
/// @package:
/// @author: dammyololade
/// created on: 12/05/2020
class PolylineWayPoint {
  /// the location of the waypoint,
  /// You can specify waypoints using the following values:
  /// --- Latitude/longitude coordinates (lat/lng): an explicit value pair. (-34.92788%2C138.60008 comma, no space),
  /// --- Place ID: The unique value specific to a location. This value is only available only if
  ///     the request includes an API key or Google Maps Platform Premium Plan client ID (ChIJGwVKWe5w44kRcr4b9E25-Go
  /// --- Address string (Charlestown, Boston,MA)
  /// ---
  String location;

  /// is a boolean which indicates that the waypoint is a stop on the route,
  /// which has the effect of splitting the route into two routes
  bool stopOver;

  PolylineWayPoint({@required this.location, this.stopOver = true});

  @override
  String toString() {
    if (stopOver) {
      return location;
    } else {
      return "via:$location";
    }
  }
}
