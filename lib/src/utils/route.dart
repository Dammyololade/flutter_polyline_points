import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_polyline_points/src/utils/bounds.dart';
import 'package:flutter_polyline_points/src/utils/leg.dart';

class Route {
  /// Coordinates of Northeast and Southwest bounds
  final Bounds? bounds;

  /// Each leg represents the journey from one waypoint to another starting
  ///  from the origin to the final destination.
  final List<Leg> legs;

  /// Decoded list of waypoints from the overview polylines.
  final List<PointLatLng> points;

  const Route(this.bounds, this.legs, this.points);

  /// Total distance of all legs in meters.
  int get totalDistance {
    int distance = 0;
    for (final leg in legs) {
      distance += leg.distance;
    }
    return distance;
  }

  /// Total duration of all legs.
  Duration get totalDuration {
    Duration duration = Duration();
    for (final leg in legs) {
      duration += leg.duration;
    }
    return duration;
  }


  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    return (other is Route) &&
        other.bounds == bounds &&
        other.points == points &&
        other.legs == legs;
  }

  @override
  int get hashCode => bounds.hashCode ^ points.hashCode ^ legs.hashCode;

  @override
  String toString() => 'Route($bounds, $points, $legs)';
}
