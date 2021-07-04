import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class Leg {
  /// Distance in meters.
  final int distance;

  /// Readable text for the distance.
  final String distanceString;

  /// Duration in seconds.
  final Duration duration;

  /// Readable text for the duration.
  final String durationString;

  /// Geocoded text of the [endLocation].
  final String endAddress;

  /// Latitude/Longitude of where the leg ends.
  final PointLatLng endLocation;

  /// Geocoded text of the [startLocation].
  final String startAddress;

  /// Latitude/Longitude of where the leg begins.
  final PointLatLng startLocation;

  Leg(
    this.distance,
    this.distanceString,
    this.duration,
    this.durationString,
    this.endAddress,
    this.endLocation,
    this.startAddress,
    this.startLocation,
  );

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    return (other is Leg) &&
        other.distance == distance &&
        other.distanceString == distanceString &&
        other.duration == duration &&
        other.durationString == durationString &&
        other.endAddress == endAddress &&
        other.endLocation == endLocation &&
        other.startAddress == startAddress &&
        other.startLocation == startLocation;
  }

  @override
  int get hashCode =>
      distance.hashCode ^
      distanceString.hashCode ^
      duration.hashCode ^
      durationString.hashCode ^
      endAddress.hashCode ^
      endLocation.hashCode ^
      startAddress.hashCode ^
      startLocation.hashCode;
}
