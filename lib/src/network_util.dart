part of flutter_polyline_points;

enum TravelMode { driving, bicycling, transit, walking }

class NetworkUtil {
  static const String STATUS_OK = "ok";

  ///Get the encoded string from google directions api
  ///
  Future<List<PointLatLng>> getRouteBetweenCoordinates(
      String googleApiKey,
      double originLat,
      double originLong,
      double destLat,
      double destLong,
      TravelMode travelMode) async {
    String mode = travelMode.toString().replaceAll('TravelMode.', '');
    List<PointLatLng> polylinePoints = [];
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=" +
            originLat.toString() +
            "," +
            originLong.toString() +
            "&destination=" +
            destLat.toString() +
            "," +
            destLong.toString() +
            "&mode=$mode" +
            "&key=$googleApiKey";
    print('GOOGLE MAPS URL: ' + url);
    var response = await http.get(url);
    if (response?.statusCode == 200) {
      var parsedJson = json.decode(response.body);
      if (parsedJson["status"]?.toLowerCase() == STATUS_OK &&
          parsedJson["routes"] != null &&
          parsedJson["routes"].isNotEmpty) {
        polylinePoints = decodeEncodedPolyline(
            parsedJson["routes"][0]["overview_polyline"]["points"]);
      } else {
        throw Exception(parsedJson["error_message"]);
      }
    }
    return polylinePoints;
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
