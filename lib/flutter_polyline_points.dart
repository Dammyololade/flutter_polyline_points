library flutter_polyline_points;

import 'dart:convert';

import 'package:http/http.dart' as http;

part 'src/PointLatLng.dart';
part 'src/network_util.dart';

class PolylinePoints {
  NetworkUtil util = NetworkUtil();

  /// Get the list of coordinates between two geographical positions
  /// which can be used to draw polyline between this two positions
  ///
  Future<List<PointLatLng>> getRouteBetweenCoordinates(
      String googleApiKey,
      double originLat,
      double originLong,
      double destLat,
      double destLong,
      {TravelMode travelMode = TravelMode.driving}) async {
    return await util.getRouteBetweenCoordinates(
        googleApiKey, originLat, originLong, destLat, destLong, travelMode);
  }

  /// Decode and encoded google polyline
  /// e.g "_p~iF~ps|U_ulLnnqC_mqNvxq`@"
  ///
  List<PointLatLng> decodePolyline(String encodedString) {
    return util.decodeEncodedPolyline(encodedString);
  }
}
