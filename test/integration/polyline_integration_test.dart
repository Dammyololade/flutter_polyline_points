import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

void main() {
  group('Polyline Points Integration Tests', () {
    late PointLatLng origin;
    late PointLatLng destination;

    setUp(() {
      origin = PointLatLng(37.7749, -122.4194); // San Francisco
      destination = PointLatLng(34.0522, -118.2437); // Los Angeles
    });

    group('Routes API Request Building', () {
      test('should build basic routes API request correctly', () {
        final request = RoutesApiRequest(
          origin: origin,
          destination: destination,
        );

        expect(request.origin, equals(origin));
        expect(request.destination, equals(destination));
        expect(request.travelMode, equals(TravelMode.driving));
        expect(request.getFieldMask(),
            contains('routes.polyline.encodedPolyline'));
      });

      test('should build complex routes API request with all options', () {
        final intermediates = [
          PolylineWayPoint(location: '36.1699,-115.1398'), // Las Vegas
          PolylineWayPoint(location: '35.2271,-80.8431'), // Charlotte
        ];

        final request = RoutesApiRequest(
          origin: origin,
          destination: destination,
          travelMode: TravelMode.walking,
          intermediates: intermediates,
          computeAlternativeRoutes: true,
          routingPreference: RoutingPreference.trafficAwareOptimal,
          units: Units.imperial,
          polylineQuality: PolylineQuality.highQuality,
          languageCode: 'en',
          regionCode: 'US',
          optimizeWaypointOrder: true,
          customBodyParameters: {
            'customField': 'customValue',
            'extraComputations': ['TRAFFIC_ON_POLYLINE'],
          },
        );

        final json = request.toJson();

        expect(json['travelMode'], equals('WALK'));
        expect(json['intermediates'], hasLength(2));
        expect(json['computeAlternativeRoutes'], isTrue);
        expect(json['routingPreference'], equals('TRAFFIC_AWARE_OPTIMAL'));
        expect(json['units'], equals('IMPERIAL'));
        expect(json['polylineQuality'], equals('HIGH_QUALITY'));
        expect(json['languageCode'], equals('en'));
        expect(json['regionCode'], equals('US'));
        expect(json['optimizeWaypointOrder'], isTrue);
        expect(json['customField'], equals('customValue'));
        expect(json['extraComputations'], contains('TRAFFIC_ON_POLYLINE'));
      });

      test('should handle timing preferences correctly', () {
        final departureTime = DateTime(2024, 6, 15, 9, 30);
        final arrivalTime = DateTime(2024, 6, 15, 17, 0);

        final request = RoutesApiRequest(
          origin: origin,
          destination: destination,
          departureTime: departureTime,
          arrivalTime: arrivalTime,
        );

        final json = request.toJson();

        expect(json['departureTime'], equals(departureTime.toIso8601String()));
        expect(json['arrivalTime'], equals(arrivalTime.toIso8601String()));
      });
    });

    group('Routes API Response Parsing', () {
      test('should parse complete API response correctly', () {
        final mockApiResponse = {
          'status': 'OK',
          'routes': [
            {
              'duration': '14400s', // 4 hours
              'staticDuration': '13500s', // 3.75 hours
              'distanceMeters': 615000, // 615 km
              'polyline': {'encodedPolyline': 'u{~vFvyys@fS]'}
            },
            {
              'duration': '15600s', // 4.33 hours
              'staticDuration': '14700s', // 4.08 hours
              'distanceMeters': 680000, // 680 km
              'polyline': {'encodedPolyline': 'a{~vFxyys@gT^'}
            }
          ],
          'geocodingResults': {
            'origin': {
              'geocoderStatus': {},
              'type': ['geocoded_waypoint'],
              'placeId': 'ChIJIQBpAG2ahYAR_6128GcTUEo'
            },
            'destination': {
              'geocoderStatus': {},
              'type': ['geocoded_waypoint'],
              'placeId': 'ChIJE9on3F3HwoAR9AhGJW_fL-I'
            }
          },
          'fallbackInfo': {'routingMode': 'FALLBACK_TRAFFIC_UNAWARE'}
        };

        final response = RoutesApiResponse.fromJson(mockApiResponse);

        expect(response.hasRoutes, isTrue);
        expect(response.isSuccessful, isTrue);
        expect(response.routes, hasLength(2));
        expect(response.rawJson, equals(mockApiResponse));

        // Test primary route
        final primaryRoute = response.primaryRoute!;
        expect(primaryRoute.duration, equals(14400));
        expect(primaryRoute.staticDuration, equals(13500));
        expect(primaryRoute.distanceMeters, equals(615000));
        expect(primaryRoute.polylineEncoded, equals('u{~vFvyys@fS]'));
        expect(primaryRoute.polylinePoints, isNotNull);
        expect(primaryRoute.durationMinutes, equals(240.0)); // 4 hours
        expect(primaryRoute.distanceKm, equals(615.0));

        // Test alternative routes
        final alternativeRoutes = response.alternativeRoutes;
        expect(alternativeRoutes, hasLength(1));
        expect(alternativeRoutes[0].duration, equals(15600));
        expect(alternativeRoutes[0].distanceKm, equals(680.0));

        // Test raw JSON access
        expect(response.rawJson['geocodingResults'], isNotNull);
        expect(response.rawJson['fallbackInfo'], isNotNull);
      });

      test('should handle error responses correctly', () {
        final errorResponse = RoutesApiResponse.error('API_KEY_INVALID');

        expect(errorResponse.hasRoutes, isFalse);
        expect(errorResponse.isSuccessful, isFalse);
        expect(errorResponse.errorMessage, equals('API_KEY_INVALID'));
        expect(errorResponse.primaryRoute, isNull);
        expect(errorResponse.alternativeRoutes, isEmpty);
      });

      test('should handle empty routes response', () {
        final emptyResponse = {
          'routes': <Map<String, dynamic>>[],
          'status': 'ZERO_RESULTS'
        };

        final response = RoutesApiResponse.fromJson(emptyResponse);

        expect(response.hasRoutes, isFalse);
        expect(response.status, equals('ZERO_RESULTS'));
        expect(response.primaryRoute, isNull);
        expect(response.alternativeRoutes, isEmpty);
      });
    });

    group('Polyline Decoding Integration', () {
      test('should decode polyline points correctly', () {
        // Real encoded polyline from Google Maps
        const encodedPolyline = 'u{~vFvyys@fS]';

        final decodedPoints = PolylinePoints.decodePolyline(encodedPolyline);

        expect(decodedPoints, isNotEmpty);
        expect(decodedPoints.first, isA<PointLatLng>());
        expect(decodedPoints.first.latitude, isA<double>());
        expect(decodedPoints.first.longitude, isA<double>());
      });

      test('should handle empty polyline gracefully', () {
        final decodedPoints = PolylinePoints.decodePolyline('');
        expect(decodedPoints, isEmpty);
      });

      test('should integrate polyline decoding with route response', () {
        final mockResponse = {
          'routes': [
            {
              'duration': '3600s',
              'distanceMeters': 150000,
              'polyline': {'encodedPolyline': 'u{~vFvyys@fS]'}
            }
          ]
        };

        final response = RoutesApiResponse.fromJson(mockResponse);
        final route = response.primaryRoute!;

        expect(route.polylineEncoded, equals('u{~vFvyys@fS]'));
        expect(route.polylinePoints, isNotNull);
        expect(route.polylinePoints, isNotEmpty);

        // Verify that polyline points are properly decoded PointLatLng objects
        for (final point in route.polylinePoints!) {
          expect(point, isA<PointLatLng>());
          expect(point.latitude, isA<double>());
          expect(point.longitude, isA<double>());
        }
      });
    });

    group('End-to-End Workflow Simulation', () {
      test('should simulate complete request-response workflow', () {
        // Step 1: Create request
        final request = RoutesApiRequest(
          origin: origin,
          destination: destination,
          travelMode: TravelMode.driving,
          computeAlternativeRoutes: true,
          routingPreference: RoutingPreference.trafficAware,
        );

        // Step 2: Verify request JSON structure
        final requestJson = request.toJson();
        expect(requestJson['origin']['location']['latLng']['latitude'],
            equals(37.7749));
        expect(requestJson['destination']['location']['latLng']['latitude'],
            equals(34.0522));
        expect(requestJson['travelMode'], equals('DRIVE'));
        expect(requestJson['computeAlternativeRoutes'], isTrue);

        // Step 3: Simulate API response
        final mockApiResponse = {
          'routes': [
            {
              'duration': '14400s',
              'staticDuration': '13500s',
              'distanceMeters': 615000,
              'polyline': {'encodedPolyline': 'u{~vFvyys@fS]'}
            }
          ]
        };

        // Step 4: Parse response
        final response = RoutesApiResponse.fromJson(mockApiResponse);

        // Step 5: Verify complete workflow
        expect(response.hasRoutes, isTrue);
        expect(response.primaryRoute, isNotNull);
        expect(response.primaryRoute!.polylinePoints, isNotNull);
        expect(response.primaryRoute!.polylinePoints, isNotEmpty);
        expect(response.primaryRoute!.durationMinutes, equals(240.0));
        expect(response.primaryRoute!.distanceKm, equals(615.0));
      });

      test('should handle request with intermediates and custom parameters',
          () {
        final intermediates = [
          PolylineWayPoint(location: '36.1699,-115.1398', stopOver: true),
          PolylineWayPoint(location: '35.2271,-80.8431', stopOver: false),
        ];

        final customParams = {
          'extraComputations': ['TRAFFIC_ON_POLYLINE', 'FUEL_CONSUMPTION'],
          'requestedReferenceTime': DateTime.now().toIso8601String(),
        };

        final request = RoutesApiRequest(
          origin: origin,
          destination: destination,
          intermediates: intermediates,
          optimizeWaypointOrder: true,
          customBodyParameters: customParams,
        );

        final requestJson = request.toJson();

        // Verify intermediates
        expect(requestJson['intermediates'], hasLength(2));
        expect(
            requestJson['intermediates'][0]['via'], isFalse); // stopOver: true
        expect(
            requestJson['intermediates'][1]['via'], isTrue); // stopOver: false
        expect(requestJson['optimizeWaypointOrder'], isTrue);

        // Verify custom parameters
        expect(
            requestJson['extraComputations'], contains('TRAFFIC_ON_POLYLINE'));
        expect(requestJson['extraComputations'], contains('FUEL_CONSUMPTION'));
        expect(requestJson['requestedReferenceTime'], isNotNull);
      });

      test('should validate field mask generation', () {
        final request = RoutesApiRequest(
          origin: origin,
          destination: destination,
        );

        final fieldMask = request.getFieldMask();
        final expectedFields = [
          'routes.duration',
          'routes.staticDuration',
          'routes.distanceMeters',
          'routes.polyline.encodedPolyline',
        ];

        for (final field in expectedFields) {
          expect(fieldMask, contains(field));
        }
      });

      test('should handle custom field mask override', () {
        const customFieldMask =
            'routes.duration,routes.legs.duration,routes.viewport';

        final request = RoutesApiRequest(
          origin: origin,
          destination: destination,
          responseFieldMask: customFieldMask,
        );

        expect(request.getFieldMask(), equals(customFieldMask));
      });

      test('should handle complete workflow with custom headers', () {
        // Step 1: Create request with custom headers for Android restricted API key
        final customHeaders = {
          'X-Android-Package': 'com.example.flutter_polyline_points',
          'X-Android-Cert': 'AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD',
        };

        final request = RoutesApiRequest(
          origin: origin,
          destination: destination,
          travelMode: TravelMode.driving,
          computeAlternativeRoutes: true,
          routingPreference: RoutingPreference.trafficAware,
          headers: customHeaders,
        );

        // Step 2: Verify request has headers
        expect(request.headers, isNotNull);
        expect(request.headers!['X-Android-Package'], 
            equals('com.example.flutter_polyline_points'));
        expect(request.headers!['X-Android-Cert'], 
            equals('AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD'));

        // Step 3: Verify request JSON structure (headers are not included in body)
        final requestJson = request.toJson();
        expect(requestJson['origin']['location']['latLng']['latitude'],
            equals(37.7749));
        expect(requestJson['destination']['location']['latLng']['latitude'],
            equals(34.0522));
        expect(requestJson['travelMode'], equals('DRIVE'));
        // Headers should not be in the JSON body
        expect(requestJson.containsKey('X-Android-Package'), isFalse);
        expect(requestJson.containsKey('X-Android-Cert'), isFalse);

        // Step 4: Simulate API response
        final mockApiResponse = {
          'routes': [
            {
              'duration': '14400s',
              'staticDuration': '13500s',
              'distanceMeters': 615000,
              'polyline': {'encodedPolyline': 'u{~vFvyys@fS]'}
            }
          ]
        };

        // Step 5: Parse response
        final response = RoutesApiResponse.fromJson(mockApiResponse);

        // Step 6: Verify complete workflow
        expect(response.hasRoutes, isTrue);
        expect(response.primaryRoute, isNotNull);
        expect(response.primaryRoute!.polylinePoints, isNotNull);
        expect(response.primaryRoute!.polylinePoints, isNotEmpty);
        expect(response.primaryRoute!.durationMinutes, equals(240.0));
        expect(response.primaryRoute!.distanceKm, equals(615.0));
      });
    });

    group('Error Handling and Edge Cases', () {
      test('should handle malformed location strings', () {
        expect(
          () => RoutesApiRequest(
            origin: origin,
            destination: destination,
            intermediates: [PolylineWayPoint(location: 'invalid-format')],
          ).toJson(),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should handle missing polyline in response', () {
        final responseWithoutPolyline = {
          'routes': [
            {
              'duration': '3600s',
              'distanceMeters': 150000,
              // Missing polyline
            }
          ]
        };

        final response = RoutesApiResponse.fromJson(responseWithoutPolyline);
        final route = response.primaryRoute!;

        expect(route.polylineEncoded, isNull);
        expect(route.polylinePoints, isNull);
        expect(route.duration, equals(3600));
        expect(route.distanceMeters, equals(150000));
      });

      test('should handle partial route data', () {
        final partialResponse = {
          'routes': [
            {
              'duration': '3600s',
              // Missing staticDuration and distanceMeters
              'polyline': {'encodedPolyline': 'u{~vFvyys@fS]'}
            }
          ]
        };

        final response = RoutesApiResponse.fromJson(partialResponse);
        final route = response.primaryRoute!;

        expect(route.duration, equals(3600));
        expect(route.staticDuration, isNull);
        expect(route.distanceMeters, isNull);
        expect(route.polylineEncoded, equals('u{~vFvyys@fS]'));
        expect(route.polylinePoints, isNotNull);
      });

      test('should preserve all raw JSON data for advanced usage', () {
        final complexResponse = {
          'routes': [
            {
              'duration': '3600s',
              'distanceMeters': 150000,
              'polyline': {'encodedPolyline': 'u{~vFvyys@fS]'},
              'legs': [
                {
                  'duration': '1800s',
                  'distanceMeters': 75000,
                  'startLocation': {
                    'latLng': {'latitude': 37.7749, 'longitude': -122.4194}
                  },
                  'endLocation': {
                    'latLng': {'latitude': 36.0, 'longitude': -120.0}
                  }
                }
              ]
            }
          ],
          'geocodingResults': {
            'origin': {'placeId': 'place123'},
            'destination': {'placeId': 'place456'}
          },
          'fallbackInfo': {'routingMode': 'FALLBACK_TRAFFIC_UNAWARE'}
        };

        final response = RoutesApiResponse.fromJson(complexResponse);

        // Verify that all raw data is preserved
        expect(response.rawJson, equals(complexResponse));
        expect(response.rawJson['routes'][0]['legs'], isNotNull);
        expect(response.rawJson['geocodingResults'], isNotNull);
        expect(response.rawJson['fallbackInfo'], isNotNull);

        // Verify that simplified parsing still works
        expect(response.primaryRoute!.duration, equals(3600));
        expect(response.primaryRoute!.polylinePoints, isNotNull);
      });
    });
  });
}
