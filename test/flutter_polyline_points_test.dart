import 'package:flutter_polyline_points/src/constants.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';

void main() {
  test('get list of coordinates from two geographical positions', () async {
    final key = Constants.API_KEY;
    PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
      request: PolylineRequest(
          origin: PointLatLng(6.5212402, 3.3679965),
          destination: PointLatLng(6.595680, 3.337030),
          mode: TravelMode.driving),
      googleApiKey: key,
    );
    assert(result.points.isNotEmpty == true);
  });

  test('get list of coordinates from an encoded String', () {
    print("Writing a test is very easy");
    final polylinePoints = PolylinePoints();
    List<PointLatLng> points =
        polylinePoints.decodePolyline("_p~iF~ps|U_ulLnnqC_mqNvxq`@");
    print("Answer ---- ");
    print(points);
    assert(points.length > 0);
  });
}
