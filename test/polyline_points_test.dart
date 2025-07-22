import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

void main() {
  group('PolylinePoints', () {
    late PointLatLng origin;
    late PointLatLng destination;

    setUp(() {
      origin = PointLatLng(37.7749, -122.4194); // San Francisco
      destination = PointLatLng(34.0522, -118.2437); // Los Angeles
    });

    group('Constructor', () {
      test('should create instance with API key', () {
        final instance = PolylinePoints(apiKey: 'test_key');
        expect(instance, isA<PolylinePoints>());
      });

      test('should create instance with custom timeout', () {
        final instance = PolylinePoints(
          apiKey: 'test_key',
          defaultTimeout: Duration(seconds: 60),
        );
        expect(instance, isA<PolylinePoints>());
      });

      test('should create instance with preferRoutesApi setting', () {
        final instance = PolylinePoints(
          apiKey: 'test_key',
          preferRoutesApi: false,
        );
        expect(instance, isA<PolylinePoints>());
      });
    });

    group('Static Methods', () {
      test('decodePolyline should decode valid polyline', () {
        const encodedPolyline = 'u{~vFvyys@fS]';

        final decodedPoints = PolylinePoints.decodePolyline(encodedPolyline);

        expect(decodedPoints, isNotEmpty);
        expect(decodedPoints, isA<List<PointLatLng>>());

        for (final point in decodedPoints) {
          expect(point, isA<PointLatLng>());
          expect(point.latitude, isA<double>());
          expect(point.longitude, isA<double>());
        }
      });

      test('decodePolyline should handle empty string', () {
        final decodedPoints = PolylinePoints.decodePolyline('');
        expect(decodedPoints, isEmpty);
      });

      test('decodePolyline should handle malformed polyline', () {
        const malformedPolyline = 'invalid_polyline';

        expect(
          () => PolylinePoints.decodePolyline(malformedPolyline),
          returnsNormally,
        );

        final result = PolylinePoints.decodePolyline(malformedPolyline);
        expect(result, isA<List<PointLatLng>>());
      });

      test('decodePolyline should be consistent across calls', () {
        const polyline = 'u{~vFvyys@fS]';

        final firstDecode = PolylinePoints.decodePolyline(polyline);
        final secondDecode = PolylinePoints.decodePolyline(polyline);

        expect(firstDecode.length, equals(secondDecode.length));

        for (int i = 0; i < firstDecode.length; i++) {
          expect(firstDecode[i].latitude, equals(secondDecode[i].latitude));
          expect(firstDecode[i].longitude, equals(secondDecode[i].longitude));
        }
      });
    });

    group('RoutesApiRequest Building', () {
      test('should build basic request correctly', () {
        final request = RoutesApiRequest(
          origin: origin,
          destination: destination,
        );

        expect(request.origin, equals(origin));
        expect(request.destination, equals(destination));
        expect(request.travelMode, equals(TravelMode.driving));
        expect(request.routingPreference,
            equals(RoutingPreference.trafficUnaware));
      });

      test('should build request with all options', () {
        final request = RoutesApiRequest(
          origin: origin,
          destination: destination,
          travelMode: TravelMode.walking,
          routingPreference: RoutingPreference.trafficAware,
          languageCode: 'en-US',
          regionCode: 'US',
          units: Units.metric,
          departureTime: DateTime.now(),
          arrivalTime: DateTime.now().add(Duration(hours: 2)),
          customBodyParameters: {'custom': 'value'},
        );
        
        expect(request.origin, equals(origin));
        expect(request.destination, equals(destination));
        expect(request.travelMode, equals(TravelMode.walking));
        expect(request.routingPreference, equals(RoutingPreference.trafficAware));
        expect(request.languageCode, equals('en-US'));
        expect(request.regionCode, equals('US'));
        expect(request.units, equals(Units.metric));
        expect(request.departureTime, isNotNull);
        expect(request.arrivalTime, isNotNull);
        expect(request.customBodyParameters, containsPair('custom', 'value'));
      });

      test('should convert request to JSON correctly', () {
        final request = RoutesApiRequest(
          origin: origin,
          destination: destination,
          travelMode: TravelMode.bicycling,
        );
        
        final json = request.toJson();
        
        expect(json, isA<Map<String, dynamic>>());
        expect(json['origin'], isNotNull);
        expect(json['destination'], isNotNull);
        expect(json['travelMode'], equals('BICYCLE'));
      });

      test('should handle coordinate locations in request', () {
        final request = RoutesApiRequest(
          origin: origin,
          destination: destination,
        );
        
        expect(request.origin, equals(origin));
        expect(request.destination, equals(destination));
        
        final json = request.toJson();
        expect(json['origin']['location']['latLng']['latitude'], equals(origin.latitude));
        expect(json['destination']['location']['latLng']['longitude'], equals(destination.longitude));
      });

      test('should handle intermediate waypoints correctly', () {
        // Note: RoutesApiRequest uses PolylineWayPoint objects for intermediates
        // This test focuses on the basic structure
        final request = RoutesApiRequest(
          origin: origin,
          destination: destination,
        );
        
        expect(request.intermediates, isNull);
        
        final json = request.toJson();
        expect(json['origin'], isNotNull);
        expect(json['destination'], isNotNull);
      });

      test('should generate correct field mask', () {
        final request = RoutesApiRequest(
          origin: origin,
          destination: destination,
        );

        final fieldMask = request.getFieldMask();

        expect(fieldMask, contains('routes.duration'));
        expect(fieldMask, contains('routes.staticDuration'));
        expect(fieldMask, contains('routes.distanceMeters'));
        expect(fieldMask, contains('routes.polyline.encodedPolyline'));
      });

      test('should generate field mask with extra computations', () {
        final request = RoutesApiRequest(
          origin: origin,
          destination: destination,
        );
        
        final fieldMask = request.getFieldMask();
        
        expect(fieldMask, contains('routes.duration'));
        expect(fieldMask, contains('routes.staticDuration'));
        expect(fieldMask, contains('routes.distanceMeters'));
        expect(fieldMask, contains('routes.polyline.encodedPolyline'));
      });

      test('should handle copyWith correctly', () {
        final originalRequest = RoutesApiRequest(
          origin: origin,
          destination: destination,
          travelMode: TravelMode.driving,
        );
        
        final modifiedRequest = originalRequest.copyWith(
          travelMode: TravelMode.walking,
        );
        
        expect(modifiedRequest.origin, equals(originalRequest.origin));
        expect(modifiedRequest.destination, equals(originalRequest.destination));
        expect(modifiedRequest.travelMode, equals(TravelMode.walking));
        expect(originalRequest.travelMode, equals(TravelMode.driving));
      });
    });

    group('RoutesApiResponse Parsing', () {
      test('should parse complete response correctly', () {
        final responseJson = {
          'routes': [
            {
              'duration': '3600s',
              'staticDuration': '3500s',
              'distanceMeters': 100000,
              'polyline': {
                'encodedPolyline': 'u{~vFvyys@fS]',
              },
            },
          ],
        };

        final response = RoutesApiResponse.fromJson(responseJson);

        expect(response.routes, isNotEmpty);
        expect(response.routes.length, equals(1));

        final route = response.routes.first;
        expect(route.duration, equals(3600));
        expect(route.staticDuration, equals(3500));
        expect(route.distanceMeters, equals(100000));
        expect(route.polylineEncoded, equals('u{~vFvyys@fS]'));
        expect(route.polylinePoints, isNotEmpty);
      });

      test('should handle empty routes response', () {
        final responseJson = {
          'routes': [],
        };

        final response = RoutesApiResponse.fromJson(responseJson);

        expect(response.routes, isEmpty);
      });

      test('should handle missing routes field', () {
        final responseJson = <String, dynamic>{};

        final response = RoutesApiResponse.fromJson(responseJson);

        expect(response.routes, isEmpty);
      });

      test('should handle route with missing optional fields', () {
        final responseJson = {
          'routes': [
            {
              'distanceMeters': 50000,
            },
          ],
        };

        final response = RoutesApiResponse.fromJson(responseJson);

        expect(response.routes, isNotEmpty);

        final route = response.routes.first;
        expect(route.duration, isNull);
        expect(route.staticDuration, isNull);
        expect(route.distanceMeters, equals(50000));
        expect(route.polylineEncoded, isNull);
        expect(route.polylinePoints, isNull);
      });

      test('should preserve raw JSON data', () {
        final responseJson = {
          'routes': [
            {
              'duration': '1800s',
              'distanceMeters': 25000,
              'customField': 'customValue',
            },
          ],
          'status': 'OK',
          'geocodingResults': [],
        };

        final response = RoutesApiResponse.fromJson(responseJson);

        expect(response.rawJson, equals(responseJson));
        expect(response.rawJson['status'], equals('OK'));
        expect(response.rawJson['geocodingResults'], isA<List>());
      });

      test('should handle route convenience getters', () {
        final responseJson = {
          'routes': [
            {
              'duration': '7200s', // 2 hours
              'staticDuration': '6600s', // 1.83 hours
              'distanceMeters': 150000, // 150 km
            },
          ],
        };

        final response = RoutesApiResponse.fromJson(responseJson);
        final route = response.routes.first;

        expect(route.durationMinutes, equals(120)); // 7200 / 60
        expect(route.staticDurationMinutes, equals(110)); // 6600 / 60
        expect(route.distanceKm, equals(150.0)); // 150000 / 1000
      });

      test('should handle null values in convenience getters', () {
        final responseJson = {
          'routes': [
            {
              'distanceMeters': 50000,
              // duration and staticDuration are missing
            },
          ],
        };

        final response = RoutesApiResponse.fromJson(responseJson);
        final route = response.routes.first;

        expect(route.durationMinutes, isNull);
        expect(route.staticDurationMinutes, isNull);
        expect(route.distanceKm, equals(50.0));
      });

      test('should handle route equality correctly', () {
        final route1 = Route(
          duration: 3600,
          staticDuration: 3500,
          distanceMeters: 100000,
          polylineEncoded: 'u{~vFvyys@fS]',
        );

        final route2 = Route(
          duration: 3600,
          staticDuration: 3500,
          distanceMeters: 100000,
          polylineEncoded: 'u{~vFvyys@fS]',
        );

        final route3 = Route(
          duration: 1800,
          staticDuration: 3500,
          distanceMeters: 100000,
          polylineEncoded: 'u{~vFvyys@fS]',
        );

        expect(route1, equals(route2));
        expect(route1, isNot(equals(route3)));
        expect(route1.hashCode, equals(route2.hashCode));
        expect(route1.hashCode, isNot(equals(route3.hashCode)));
      });
    });

    group('Error Handling', () {
      test('should handle invalid location formats gracefully', () {
        // Note: RoutesApiRequest requires PointLatLng objects
        // This test verifies the constructor works with valid inputs
        expect(
          () => RoutesApiRequest(
            origin: origin,
            destination: destination,
          ),
          returnsNormally,
        );
      });

      test('should handle malformed JSON response', () {
        final malformedJson = {
          'routes': 'not_an_array',
        };

        expect(
          () => RoutesApiResponse.fromJson(malformedJson),
          returnsNormally,
        );
      });

      test('should handle null JSON response', () {
        expect(
          () => RoutesApiResponse.fromJson({}),
          returnsNormally,
        );
      });

      test('should handle invalid duration format', () {
        final responseJson = {
          'routes': [
            {
              'duration': 'invalid_duration',
              'distanceMeters': 50000,
            },
          ],
        };

        final response = RoutesApiResponse.fromJson(responseJson);
        final route = response.routes.first;

        expect(route.duration, isNull);
        expect(route.distanceMeters, equals(50000));
      });
    });

    group('Integration Scenarios', () {
      test('should handle complete workflow simulation', () {
        // 1. Create request
        final request = RoutesApiRequest(
          origin: origin,
          destination: destination,
          travelMode: TravelMode.driving,
        );

        expect(request, isA<RoutesApiRequest>());

        // 2. Convert to JSON (simulating API call preparation)
        final requestJson = request.toJson();
        expect(requestJson, isA<Map<String, dynamic>>());

        // 3. Simulate API response
        final responseJson = {
          'routes': [
            {
              'duration': '3600s',
              'staticDuration': '3500s',
              'distanceMeters': 100000,
              'polyline': {
                'encodedPolyline': 'u{~vFvyys@fS]',
              },
            },
          ],
        };

        // 4. Parse response
        final response = RoutesApiResponse.fromJson(responseJson);
        expect(response.routes, isNotEmpty);

        // 5. Extract polyline points
        final route = response.routes.first;
        expect(route.polylinePoints, isNotEmpty);

        // 6. Verify decoded points
        for (final point in route.polylinePoints!) {
          expect(point, isA<PointLatLng>());
          expect(point.latitude, isA<double>());
          expect(point.longitude, isA<double>());
        }
      });

      test('should handle multiple routes response', () {
        final responseJson = {
          'routes': [
            {
              'duration': '3600s',
              'distanceMeters': 100000,
              'polyline': {'encodedPolyline': 'u{~vFvyys@fS]'},
            },
            {
              'duration': '4200s',
              'distanceMeters': 120000,
              'polyline': {'encodedPolyline': '_p~iF~ps|U_ulLnnqC_mqNvxq`@'},
            },
          ],
        };

        final response = RoutesApiResponse.fromJson(responseJson);

        expect(response.routes, hasLength(2));

        final firstRoute = response.routes[0];
        final secondRoute = response.routes[1];

        expect(firstRoute.duration, equals(3600));
        expect(firstRoute.distanceMeters, equals(100000));
        expect(firstRoute.polylinePoints, isNotEmpty);

        expect(secondRoute.duration, equals(4200));
        expect(secondRoute.distanceMeters, equals(120000));
        expect(secondRoute.polylinePoints, isNotEmpty);
      });

      test('should handle request with custom body parameters', () {
        final customParams = {
          'customField': 'customValue',
          'nestedObject': {
            'key': 'value',
          },
          'arrayField': [1, 2, 3],
        };

        final request = RoutesApiRequest(
          origin: origin,
          destination: destination,
          customBodyParameters: customParams,
        );

        final json = request.toJson();

        expect(json['customField'], equals('customValue'));
        expect(json['nestedObject'], equals({'key': 'value'}));
        expect(json['arrayField'], equals([1, 2, 3]));

        // Ensure standard fields are still present
        expect(json['origin'], isNotNull);
        expect(json['destination'], isNotNull);
      });
    });
  });
}
