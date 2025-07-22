import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_polyline_points/src/routes_api/routes_response.dart';

void main() {
  group('RoutesApiResponse', () {
    test('should parse valid JSON response correctly', () {
      final jsonResponse = {
        'routes': [
          {
            'duration': '3600s',
            'staticDuration': '3300s',
            'distanceMeters': 150000,
            'polyline': {'encodedPolyline': 'u{~vFvyys@fS]'}
          },
          {
            'duration': '4200s',
            'staticDuration': '3900s',
            'distanceMeters': 180000,
            'polyline': {'encodedPolyline': 'a{~vFxyys@gT^'}
          }
        ]
      };

      final response = RoutesApiResponse.fromJson(jsonResponse);

      expect(response.routes, hasLength(2));
      expect(response.rawJson, equals(jsonResponse));

      // Test first route
      final firstRoute = response.routes[0];
      expect(firstRoute.duration, equals(3600));
      expect(firstRoute.staticDuration, equals(3300));
      expect(firstRoute.distanceMeters, equals(150000));
      expect(firstRoute.polylineEncoded, equals('u{~vFvyys@fS]'));
      expect(firstRoute.polylinePoints, isNotNull);

      // Test second route
      final secondRoute = response.routes[1];
      expect(secondRoute.duration, equals(4200));
      expect(secondRoute.staticDuration, equals(3900));
      expect(secondRoute.distanceMeters, equals(180000));
      expect(secondRoute.polylineEncoded, equals('a{~vFxyys@gT^'));
    });

    test('should handle empty routes array', () {
      final jsonResponse = {'routes': <Map<String, dynamic>>[]};

      final response = RoutesApiResponse.fromJson(jsonResponse);

      expect(response.routes, isEmpty);
      expect(response.rawJson, equals(jsonResponse));
    });

    test('should handle null routes', () {
      final jsonResponse = <String, dynamic>{};

      final response = RoutesApiResponse.fromJson(jsonResponse);

      expect(response.routes, isEmpty);
      expect(response.rawJson, equals(jsonResponse));
    });

    test('should handle routes with missing optional fields', () {
      final jsonResponse = {
        'routes': [
          {
            'duration': '3600s',
            'distanceMeters': 150000,
            'polyline': {'encodedPolyline': 'u{~vFvyys@fS]'}
            // Missing staticDuration
          }
        ]
      };

      final response = RoutesApiResponse.fromJson(jsonResponse);

      expect(response.routes, hasLength(1));
      final route = response.routes[0];
      expect(route.duration, equals(3600));
      expect(route.staticDuration, isNull);
      expect(route.distanceMeters, equals(150000));
      expect(route.polylineEncoded, equals('u{~vFvyys@fS]'));
    });

    test('should handle routes with missing polyline', () {
      final jsonResponse = {
        'routes': [
          {
            'duration': '3600s',
            'staticDuration': '3300s',
            'distanceMeters': 150000
            // Missing polyline
          }
        ]
      };

      final response = RoutesApiResponse.fromJson(jsonResponse);

      expect(response.routes, hasLength(1));
      final route = response.routes[0];
      expect(route.polylineEncoded, isNull);
      expect(route.polylinePoints, isNull);
    });

    test('should handle routes with empty polyline object', () {
      final jsonResponse = {
        'routes': [
          {
            'duration': '3600s',
            'staticDuration': '3300s',
            'distanceMeters': 150000,
            'polyline': <String, dynamic>{}
          }
        ]
      };

      final response = RoutesApiResponse.fromJson(jsonResponse);

      expect(response.routes, hasLength(1));
      final route = response.routes[0];
      expect(route.polylineEncoded, isNull);
      expect(route.polylinePoints, isNull);
    });

    test('should handle routes data correctly', () {
      final routes = [
        Route(
          duration: 3600,
          staticDuration: 3300,
          distanceMeters: 150000,
          polylineEncoded: 'u{~vFvyys@fS]',
        ),
        Route(
          duration: 4200,
          distanceMeters: 180000,
          polylineEncoded: 'a{~vFxyys@gT^',
        ),
      ];

      final response = RoutesApiResponse(
        routes: routes,
        rawJson: {'test': 'data'},
      );

      expect(response.routes, hasLength(2));
      expect(response.routes[0].duration, equals(3600));
      expect(response.routes[0].staticDuration, equals(3300));
      expect(response.routes[0].distanceMeters, equals(150000));
      expect(response.routes[0].polylineEncoded, equals('u{~vFvyys@fS]'));

      expect(response.routes[1].duration, equals(4200));
      expect(response.routes[1].staticDuration, isNull);
      expect(response.routes[1].distanceMeters, equals(180000));
      expect(response.routes[1].polylineEncoded, equals('a{~vFxyys@gT^'));
    });

    test('should preserve raw JSON data', () {
      final originalJson = {
        'routes': [
          {
            'duration': '3600s',
            'distanceMeters': 150000,
            'polyline': {'encodedPolyline': 'u{~vFvyys@fS]'}
          }
        ],
        'geocodingResults': {
          'origin': {'placeId': 'place123'},
          'destination': {'placeId': 'place456'}
        },
        'fallbackInfo': {'routingMode': 'FALLBACK_TRAFFIC_UNAWARE'}
      };

      final response = RoutesApiResponse.fromJson(originalJson);

      expect(response.rawJson, equals(originalJson));
      expect(response.rawJson['geocodingResults'], isNotNull);
      expect(response.rawJson['fallbackInfo'], isNotNull);
    });
  });

  group('Route', () {
    test('should create route with all fields', () {
      final route = Route(
        duration: 3600,
        staticDuration: 3300,
        distanceMeters: 150000,
        polylineEncoded: 'u{~vFvyys@fS]',
      );

      expect(route.duration, equals(3600));
      expect(route.staticDuration, equals(3300));
      expect(route.distanceMeters, equals(150000));
      expect(route.polylineEncoded, equals('u{~vFvyys@fS]'));
    });

    test('should create route with minimal fields', () {
      final route = Route();

      expect(route.duration, isNull);
      expect(route.staticDuration, isNull);
      expect(route.distanceMeters, isNull);
      expect(route.polylineEncoded, isNull);
    });

    test('should parse from JSON correctly', () {
      final json = {
        'duration': '3600s',
        'staticDuration': '3300s',
        'distanceMeters': 150000,
        'polyline': {'encodedPolyline': 'u{~vFvyys@fS]'}
      };

      final route = Route.fromJson(json);

      expect(route.duration, equals(3600));
      expect(route.staticDuration, equals(3300));
      expect(route.distanceMeters, equals(150000));
      expect(route.polylineEncoded, equals('u{~vFvyys@fS]'));
    });

    test('should provide convenience getters', () {
      final route = Route(
        duration: 3600,
        staticDuration: 3300,
        distanceMeters: 150000,
        polylineEncoded: 'u{~vFvyys@fS]',
      );

      expect(route.durationMinutes, equals(60.0));
      expect(route.staticDurationMinutes, equals(55.0));
      expect(route.distanceKm, equals(150.0));
      expect(route.polylineEncoded, equals('u{~vFvyys@fS]'));
    });

    test('should handle null values in convenience getters', () {
      final route = Route(
        duration: null,
        distanceMeters: null,
      );

      expect(route.durationMinutes, isNull);
      expect(route.staticDurationMinutes, isNull);
      expect(route.distanceKm, isNull);
      expect(route.polylineEncoded, isNull);
    });

    test('should implement equality correctly', () {
      final route1 = Route(
        duration: 3600,
        staticDuration: 3300,
        distanceMeters: 150000,
        polylineEncoded: 'u{~vFvyys@fS]',
      );

      final route2 = Route(
        duration: 3600,
        staticDuration: 3300,
        distanceMeters: 150000,
        polylineEncoded: 'u{~vFvyys@fS]',
      );

      final route3 = Route(
        duration: 4200,
        staticDuration: 3300,
        distanceMeters: 150000,
        polylineEncoded: 'u{~vFvyys@fS]',
      );

      expect(route1, equals(route2));
      expect(route1, isNot(equals(route3)));
      expect(route1.hashCode, equals(route2.hashCode));
    });
  });
}
