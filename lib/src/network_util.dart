import 'dart:convert';

import 'package:flutter_polyline_points/src/PointLatLng.dart';
import 'package:flutter_polyline_points/src/utils/polyline_request.dart';
import 'package:http/http.dart' as http;
import 'utils/polyline_result.dart';

class NetworkUtil {
  static const String STATUS_OK = "ok";

  ///Get the encoded string from google directions api
  ///
  Future<List<PolylineResult>> getRouteBetweenCoordinates(
      {required PolylineRequest request}) async {
    List<PolylineResult> results = [];

    var response = await http.get(request.toUri());
    if (response.statusCode == 200) {
      var parsedJson = json.decode(response.body);
      if (parsedJson["status"]?.toLowerCase() == STATUS_OK &&
          parsedJson["routes"] != null &&
          parsedJson["routes"].isNotEmpty) {
        List<dynamic> routeList = parsedJson["routes"];
        for (var route in routeList) {
          results.add(PolylineResult(
              points:
                  decodeEncodedPolyline(route["overview_polyline"]["points"]),
              errorMessage: "",
              status: parsedJson["status"],
              distance: route["legs"][0]["distance"]["text"],
              duration: route["legs"][0]["duration"]["text"]));
        }
      } else {
        throw Exception("Unable to get route: Response ---> ${parsedJson["status"]} ");
      }
    }
    return results;
  }

  ///decode the google encoded string using Encoded Polyline Algorithm Format
  /// for more info about the algorithm check https://developers.google.com/maps/documentation/utilities/polylinealgorithm
  ///
  ///return [List]
  List<PointLatLng> decodeEncodedPolyline(String encoded) {
    List<PointLatLng> poly = [];
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

      poly.add(PointLatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble()));
    }
    return poly;
  }
}
