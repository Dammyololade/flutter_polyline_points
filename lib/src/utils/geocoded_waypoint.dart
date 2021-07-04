import 'package:flutter_polyline_points/src/utils/status_code.dart';

class GeocodedWaypoint {
  /// Status of operation.
  final StatusCode geocoderStatus;

  /// Google Maps Identifier for a location.
  final String placeId;

  GeocodedWaypoint(this.geocoderStatus, this.placeId);

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    return (other is GeocodedWaypoint) &&
        other.geocoderStatus == geocoderStatus &&
        other.placeId == placeId;
  }

  @override
  int get hashCode => geocoderStatus.hashCode ^ placeId.hashCode;
}
