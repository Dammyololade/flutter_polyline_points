import 'dart:convert';

import 'package:flutter_polyline_points/src/utils/bounds.dart';
import 'package:flutter_polyline_points/src/utils/leg.dart';
import 'package:flutter_polyline_points/src/utils/route.dart';
import 'package:flutter_polyline_points/src/utils/status_code.dart';
import 'package:http/http.dart' as http;

import '../src/PointLatLng.dart';
import '../src/utils/polyline_waypoint.dart';
import '../src/utils/request_enums.dart';
import 'utils/polyline_result.dart';

class NetworkUtil {
  ///Get the encoded string from google directions api
  ///
  Future<PolylineResult> getRouteBetweenCoordinates(
    String googleApiKey,
    PointLatLng? origin,
    PointLatLng? destination,
    String? originPlaceId,
    String? destinationPlaceId,
    TravelMode travelMode,
    List<PolylineWayPoint> wayPoints,
    bool avoidHighways,
    bool avoidTolls,
    bool avoidFerries,
    bool optimizeWaypoints,
    bool alternatives,
  ) async {
   
    final mode = travelMode.toString().replaceAll('TravelMode.', '');
    final result = PolylineResult();

    final params = {
      "mode": mode,
      "alternatives": "$alternatives",
      "key": googleApiKey
    };

    if (origin != null) {
      params["origin"] = "${origin.latitude},${origin.longitude}";
    } else {
      params["origin"] = 'place_id:${originPlaceId!}';
    }

    if (destination != null) {
      params["destination"] =
          "${destination.latitude},${destination.longitude}";
    } else {
      params["destination"] = 'place_id:${destinationPlaceId!}';
    }

    if (wayPoints.isNotEmpty) {
      final wayPointsArray = wayPoints.map((point) => point.location);
      String wayPointsString = wayPointsArray.join('|');
      if (optimizeWaypoints) {
        wayPointsString = 'optimize:true|$wayPointsString';
      }
      params["waypoints"] = wayPointsString;
    }
    final avoidences = <String>[];
    if (avoidHighways) avoidences.add("highways");
    if (avoidTolls) avoidences.add("tolls");
    if (avoidFerries) avoidences.add("ferries");
    if (avoidences.isNotEmpty) params["avoid"] = avoidences.join('|');

    Uri uri =
        Uri.https("maps.googleapis.com", "maps/api/directions/json", params);

    var response = await http.get(uri);
    if (response.statusCode == 200) {
      var parsedJson = json.decode(response.body);
      return parseJson(parsedJson);
    }
    return result;
  }

  PolylineResult parseJson(dynamic parsedJson) {
    final result = PolylineResult();
    result.status = StatusCode(parsedJson["status"]);
    if (result.status == StatusCode.OK &&
        parsedJson["routes"] != null &&
        parsedJson["routes"].isNotEmpty) {
      final routes = <Route>[];

      for (final route in parsedJson["routes"]) {
        final bounds = Bounds(
          PointLatLng(
            route["bounds"]["northeast"]["lat"],
            route["bounds"]["northeast"]["lng"],
          ),
          PointLatLng(
            route["bounds"]["southwest"]["lat"],
            route["bounds"]["southwest"]["lng"],
          ),
        );

        final legs = <Leg>[];

        for (final leg in route["legs"]) {
          legs.add(Leg(
            leg["distance"]["value"],
            leg["distance"]["text"],
            Duration(seconds: leg["duration"]["value"]),
            leg["duration"]["text"],
            leg["end_address"],
            PointLatLng(
              leg["end_location"]["lat"],
              leg["end_location"]["lng"],
            ),
            leg["start_address"],
            PointLatLng(
              leg["start_location"]["lat"],
              leg["start_location"]["lng"],
            ),
          ));
        }

        final points = decodeEncodedPolyline(
          route["overview_polyline"]["points"],
        );

        routes.add(Route(bounds, legs, points));
      }
      result.routes = routes;
    } else {
      result.errorMessage = parsedJson["error_message"];
    }
    return result;
  }

  ///decode the google encoded string using Encoded Polyline Algorithm Format
  /// for more info about the algorithm check https://developers.google.com/maps/documentation/utilities/polylinealgorithm
  ///
  ///return [List]
  List<PointLatLng> decodeEncodedPolyline(String encoded) {
    List<PointLatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      PointLatLng p =
          new PointLatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  }
}
