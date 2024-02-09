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

  /// list of decoded points
  List<PointLatLng> alternatives;

  List<String>? distanceTexts;
  List<int>? distanceValues;
  int? totalDistanceValue;
  List<String>? durationTexts;
  List<int>? durationValues;
  int? totalDurationValue;
  String? endAddress;
  String? startAddress;
  String? overviewPolyline;

  PolylineResult(
      {this.status,
      this.points = const [],
      this.errorMessage = "",
      this.alternatives = const [],
      this.distanceTexts,
      this.distanceValues,
      this.totalDistanceValue,
      this.durationTexts,
      this.durationValues,
      this.totalDurationValue,
      this.endAddress,
      this.startAddress,
      this.overviewPolyline});
}
