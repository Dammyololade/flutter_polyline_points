/// A pair of latitude and longitude coordinates, stored as degrees.
class PointLatLng {
  /// Creates a geographical location specified in degrees [latitude] and
  /// [longitude].
  ///
  const PointLatLng(this.latitude, this.longitude);

  /// The latitude in degrees.
  final double latitude;

  /// The longitude in degrees
  final double longitude;

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    return (other is PointLatLng) &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  @override
  String toString() {
    return "lat: $latitude / longitude: $longitude";
  }
}
