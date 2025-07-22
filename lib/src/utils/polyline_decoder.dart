import 'package:flutter_polyline_points/src/commons/point_lat_lng.dart';

/// Decode the google encoded string using Encoded Polyline Algorithm Format
/// for more info about the algorithm check https://developers.google.com/maps/documentation/utilities/polylinealgorithm
///
class PolylineDecoder {
  static List<PointLatLng> run(String encoded) {
    try {
      final points = <PointLatLng>[];
      int index = 0;
      int lat = 0;
      int lng = 0;

      while (index < encoded.length) {
        int shift = 0;
        int result = 0;
        int byte;

        do {
          byte = encoded.codeUnitAt(index++) - 63;
          result |= (byte & 0x1f) << shift;
          shift += 5;
        } while (byte >= 0x20);

        int deltaLat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lat += deltaLat;

        shift = 0;
        result = 0;

        do {
          byte = encoded.codeUnitAt(index++) - 63;
          result |= (byte & 0x1f) << shift;
          shift += 5;
        } while (byte >= 0x20);

        int deltaLng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lng += deltaLng;

        points.add(PointLatLng(
          lat / 1E5,
          lng / 1E5,
        ));
      }

      return points;
    }  catch (e) {
      return [];
    }
  }
}
