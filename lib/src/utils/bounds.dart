import 'package:flutter_polyline_points/flutter_polyline_points.dart';

/// Northeast and southwest bounds for a route.
class Bounds {
  final PointLatLng northeast;
  final PointLatLng southwest;

  const Bounds(this.northeast, this.southwest);

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    return (other is Bounds) &&
        other.northeast == northeast &&
        other.southwest == southwest;
  }

  @override
  int get hashCode => northeast.hashCode ^ southwest.hashCode;

  @override
  String toString() => 'Bounds($northeast, $southwest)';
}
