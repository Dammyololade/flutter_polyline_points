import 'package:flutter/material.dart';

/// description:
/// project: flutter_polyline_points
/// @package: 
/// @author: dammyololade
/// created on: 12/05/2020
class PolylineWayPoint {

  /// specifies the location of the waypoint,
  /// as a LatLng, as a google.maps.Place object
  /// or as a String which will be geocoded.
  dynamic location;

  /// is a boolean which indicates that the waypoint is a stop on the route,
  /// which has the effect of splitting the route into two routes
  bool stopOver;


  PolylineWayPoint({@required this.location, this.stopOver = true});

  Map<String, dynamic> toMap() => {
    "location": location.toString(),
    "stopover": stopOver
  };

  @override
  String toString() {
    return "location=${location.toString()},stopover=$stopOver";
  }
}