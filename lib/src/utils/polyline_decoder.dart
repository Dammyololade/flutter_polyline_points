import 'package:flutter_polyline_points/src/commons/point_lat_lng.dart';

/// Decode the google encoded string using Encoded Polyline Algorithm Format
/// for more info about the algorithm check https://developers.google.com/maps/documentation/utilities/polylinealgorithm
///
class PolylineDecoder {
  static List<PointLatLng> run(String encoded) {
    try {
      final points = <PointLatLng>[];
      int index = 0, len = encoded.length;
      int lat = 0, lng = 0;
      BigInt Big0 = BigInt.from(0);
      BigInt Big0x1f = BigInt.from(0x1f);
      BigInt Big0x20 = BigInt.from(0x20);

      while (index < len) {
        int shift = 0;
        BigInt b, result;
        result = Big0;
        do {
          b = BigInt.from(encoded.codeUnitAt(index++) - 63);
          result |= (b & Big0x1f) << shift;
          shift += 5;
        } while (b >= Big0x20);
        BigInt rShifted = result >> 1;
        int dLat;
        if (result.isOdd)
          dLat = (~rShifted).toInt();
        else
          dLat = rShifted.toInt();
        lat += dLat;

        shift = 0;
        result = Big0;
        do {
          b = BigInt.from(encoded.codeUnitAt(index++) - 63);
          result |= (b & Big0x1f) << shift;
          shift += 5;
        } while (b >= Big0x20);
        rShifted = result >> 1;
        int dLng;
        if (result.isOdd)
          dLng = (~rShifted).toInt();
        else
          dLng = rShifted.toInt();
        lng += dLng;

        points.add(PointLatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble()));
      }
      return points;
    } catch (e) {
      return [];
    }
  }
}
