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
  String status;

  /// list of decoded points
  List<PointLatLng> points;

  /// the error message returned from google, if none, the result will be empty
  String errorMessage;

  /// The distance between the points
  TextValue distance;

  /// The time duration
  TextValue duration;

  PolylineResult({this.status, this.points = const [], this.errorMessage = ""});


}
/// description:
/// project: flutter_polyline_points
/// @package: 
/// @author: jtpdev
/// created on: 15/05/2020
class TextValue {
  /// Text to show
  String text;
  /// Value to save
  var value;

  TextValue({this.text, this.value});

  /// To create a new TextValue from Map<String, dynamic>
  /// 
  /// return [TextValue]
  static TextValue create(Map<String, dynamic> data) {
    return TextValue(text: data['text'], value: data['value']);
  }

}