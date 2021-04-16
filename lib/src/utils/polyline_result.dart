import '../../flutter_polyline_points.dart';

/// description:
/// project: flutter_polyline_points
/// @package: 
/// @author: dammyololade
/// created on: 13/05/2020
class PolylineResult {

  /// the api status retuned from google api
  ///
  /// returns OK if the api call is successful
  String? status;

  /// list of decoded points
  List<PointLatLng> points;

  /// the error message returned from google, if none, the result will be empty
  String? errorMessage;

  PolylineResult({this.status, this.points = const [], this.errorMessage = ""});


}