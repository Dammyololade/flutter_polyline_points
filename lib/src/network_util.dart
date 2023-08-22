import 'dart:convert';

import 'package:flutter_polyline_points/src/PointLatLng.dart';
import 'package:flutter_polyline_points/src/utils/polyline_decoder.dart';
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
                  PolylineDecoder.run(route["overview_polyline"]["points"]),
              errorMessage: "",
              status: parsedJson["status"],
              distance: route["legs"][0]["distance"]["text"],
              distanceValue: route["legs"][0]["distance"]["value"],
              overviewPolyline: route["overview_polyline"]["points"],
              durationValue: route["legs"][0]["duration"]["value"],
              endAddress: route["legs"][0]['end_address'],
              startAddress: route["legs"][0]['start_address'],
              duration: route["legs"][0]["duration"]["text"]));
        }
      } else {
        throw Exception("Unable to get route: Response ---> ${parsedJson["status"]} ");
      }
    }
    return results;
  }
}
