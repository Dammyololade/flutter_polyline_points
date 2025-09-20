import 'package:flutter_polyline_points/src/constants.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';

//ignore_for_file: deprecated_member_use_from_same_package
void main() {
  final key = Constants.API_KEY;

  test('get list of coordinates from two geographical positions', () async {
    final result = await PolylinePoints(apiKey: key).getRouteBetweenCoordinates(
      request: PolylineRequest(
          origin: PointLatLng(6.5212402, 3.3679965),
          destination: PointLatLng(6.595680, 3.337030),
          mode: TravelMode.driving),
    );
    expect(result.points.isNotEmpty, isTrue);
  });

  test('get routes with RoutesApi', () async {
    final response = await PolylinePoints(apiKey: key).getRouteBetweenCoordinatesV2(
      request: RoutesApiRequest(
        origin: PointLatLng(6.5212402, 3.3679965),
        destination: PointLatLng(6.595680, 3.337030),
        travelMode: TravelMode.driving,
        routingPreference: RoutingPreference.trafficAwareOptimal,
        units: Units.imperial,
        extraComputations: [ExtraComputation.tolls],
        optimizeWaypointOrder: true,
      ),
    );

    expect(response.routes.isNotEmpty, isTrue);
    expect(response.status, equals("OK"));

    expect(response.routes.first.polylinePoints!.isNotEmpty, isTrue);

  });

  test('get list of coordinates from an encoded String', () {
    List<PointLatLng> points = PolylinePoints.decodePolyline("_p~iF~ps|U_ulLnnqC_mqNvxq`@");
    expect(points.isNotEmpty, isTrue);
  });
}
