import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_polyline_points/src/routes_api/routes_request.dart';
import 'package:flutter_polyline_points/src/commons/point_lat_lng.dart';
import 'package:flutter_polyline_points/src/commons/travel_mode.dart';
import 'package:flutter_polyline_points/src/routes_api/enums/routing_preference.dart';
import 'package:flutter_polyline_points/src/routes_api/enums/units.dart';
import 'package:flutter_polyline_points/src/routes_api/enums/polyline_quality.dart';
import 'package:flutter_polyline_points/src/utils/polyline_waypoint.dart';

void main() {
  group('RoutesApiRequest', () {
    late PointLatLng origin;
    late PointLatLng destination;

    setUp(() {
      origin = PointLatLng(37.7749, -122.4194); // San Francisco
      destination = PointLatLng(34.0522, -118.2437); // Los Angeles
    });

    test('should create basic request with required fields', () {
      final request = RoutesApiRequest(
        origin: origin,
        destination: destination,
      );

      expect(request.origin, equals(origin));
      expect(request.destination, equals(destination));
      expect(request.travelMode, equals(TravelMode.driving));
      expect(request.computeAlternativeRoutes, isFalse);
      expect(request.routingPreference, equals(RoutingPreference.trafficUnaware));
      expect(request.units, equals(Units.metric));
      expect(request.polylineQuality, equals(PolylineQuality.overview));
      expect(request.optimizeWaypointOrder, isFalse);
    });

    test('should create request with all optional fields', () {
      final intermediates = [
        PolylineWayPoint(location: '36.1699,-115.1398'), // Las Vegas
      ];
      final departureTime = DateTime.now().add(Duration(hours: 1));
      final customParams = {'customField': 'customValue'};
      final customHeaders = {
        'X-Android-Package': 'com.example.app',
        'X-Android-Cert': 'ABC123DEF456',
      };

      final request = RoutesApiRequest(
        origin: origin,
        destination: destination,
        travelMode: TravelMode.transit,
        intermediates: intermediates,
        computeAlternativeRoutes: true,
        routingPreference: RoutingPreference.trafficAwareOptimal,
        units: Units.imperial,
        polylineQuality: PolylineQuality.highQuality,
        languageCode: 'en',
        regionCode: 'US',
        departureTime: departureTime,
        optimizeWaypointOrder: true,
        responseFieldMask: 'routes.duration,routes.distanceMeters',
        customBodyParameters: customParams,
        headers: customHeaders,
      );

      expect(request.travelMode, equals(TravelMode.transit));
      expect(request.intermediates, equals(intermediates));
      expect(request.computeAlternativeRoutes, isTrue);
      expect(request.routingPreference, equals(RoutingPreference.trafficAwareOptimal));
      expect(request.units, equals(Units.imperial));
      expect(request.polylineQuality, equals(PolylineQuality.highQuality));
      expect(request.languageCode, equals('en'));
      expect(request.regionCode, equals('US'));
      expect(request.departureTime, equals(departureTime));
      expect(request.optimizeWaypointOrder, isTrue);
      expect(request.responseFieldMask, equals('routes.duration,routes.distanceMeters'));
      expect(request.customBodyParameters, equals(customParams));
      expect(request.headers, equals(customHeaders));
    });

    test('should convert to JSON correctly', () {
      final request = RoutesApiRequest(
        origin: origin,
        destination: destination,
        travelMode: TravelMode.walking,
        computeAlternativeRoutes: true,
        languageCode: 'es',
        customBodyParameters: {'testParam': 'testValue'},
      );

      final json = request.toJson();

      expect(json['origin']['location']['latLng']['latitude'], equals(37.7749));
      expect(json['origin']['location']['latLng']['longitude'], equals(-122.4194));
      expect(json['destination']['location']['latLng']['latitude'], equals(34.0522));
      expect(json['destination']['location']['latLng']['longitude'], equals(-118.2437));
      expect(json['travelMode'], equals('WALK'));
      expect(json['computeAlternativeRoutes'], isTrue);
      expect(json['languageCode'], equals('es'));
      expect(json['testParam'], equals('testValue'));
    });

    test('should include intermediates in JSON when provided', () {
      final intermediates = [
        PolylineWayPoint(location: '36.1699,-115.1398', stopOver: true),
        PolylineWayPoint(location: '35.2271,-80.8431', stopOver: false),
      ];

      final request = RoutesApiRequest(
        origin: origin,
        destination: destination,
        intermediates: intermediates,
        optimizeWaypointOrder: true,
      );

      final json = request.toJson();

      expect(json['intermediates'], isNotNull);
      expect(json['intermediates'], hasLength(2));
      expect(json['intermediates'][0]['via'], isFalse); // stopOver: true means via: false
      expect(json['intermediates'][1]['via'], isTrue); // stopOver: false means via: true
      expect(json['optimizeWaypointOrder'], isTrue);
    });

    test('should generate correct field mask', () {
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

      expect(fieldMask, equals(expectedFields.join(',')));
    });

    test('should use custom field mask when provided', () {
      final customFieldMask = 'routes.duration,routes.legs.duration';
      final request = RoutesApiRequest(
        origin: origin,
        destination: destination,
        responseFieldMask: customFieldMask,
      );

      expect(request.getFieldMask(), equals(customFieldMask));
    });

    test('should create copy with modified values', () {
      final originalRequest = RoutesApiRequest(
        origin: origin,
        destination: destination,
        travelMode: TravelMode.driving,
      );

      final newDestination = PointLatLng(40.7128, -74.0060); // New York
      final modifiedRequest = originalRequest.copyWith(
        destination: newDestination,
        travelMode: TravelMode.walking,
        computeAlternativeRoutes: true,
      );

      expect(modifiedRequest.origin, equals(origin)); // unchanged
      expect(modifiedRequest.destination, equals(newDestination)); // changed
      expect(modifiedRequest.travelMode, equals(TravelMode.walking)); // changed
      expect(modifiedRequest.computeAlternativeRoutes, isTrue); // changed
    });

    test('should handle timing preferences in JSON', () {
      final departureTime = DateTime(2024, 1, 15, 9, 30);
      final arrivalTime = DateTime(2024, 1, 15, 17, 0);

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

    test('should handle invalid location format', () {
      expect(
        () => RoutesApiRequest(
          origin: origin,
          destination: destination,
          intermediates: [PolylineWayPoint(location: 'invalid-format')],
        ).toJson(),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should merge custom body parameters correctly', () {
      final customParams = {
        'extraField1': 'value1',
        'extraField2': {'nested': 'value2'},
        'extraField3': [1, 2, 3],
      };

      final request = RoutesApiRequest(
        origin: origin,
        destination: destination,
        customBodyParameters: customParams,
      );

      final json = request.toJson();

      expect(json['extraField1'], equals('value1'));
      expect(json['extraField2'], equals({'nested': 'value2'}));
      expect(json['extraField3'], equals([1, 2, 3]));
      // Ensure standard fields are still present
      expect(json['origin'], isNotNull);
      expect(json['destination'], isNotNull);
    });

    group('Headers functionality', () {
      test('should handle null headers', () {
        final request = RoutesApiRequest(
          origin: origin,
          destination: destination,
          headers: null,
        );

        expect(request.headers, isNull);
      });

      test('should handle empty headers map', () {
        final request = RoutesApiRequest(
          origin: origin,
          destination: destination,
          headers: {},
        );

        expect(request.headers, isEmpty);
      });

      test('should store custom headers correctly', () {
        final customHeaders = {
          'X-Android-Package': 'com.example.myapp',
          'X-Android-Cert': 'SHA1_FINGERPRINT_HERE',
          'Custom-Header': 'custom-value',
        };

        final request = RoutesApiRequest(
          origin: origin,
          destination: destination,
          headers: customHeaders,
        );

        expect(request.headers, equals(customHeaders));
        expect(request.headers!['X-Android-Package'], equals('com.example.myapp'));
        expect(request.headers!['X-Android-Cert'], equals('SHA1_FINGERPRINT_HERE'));
        expect(request.headers!['Custom-Header'], equals('custom-value'));
      });

      test('should include headers in copyWith method', () {
        final originalHeaders = {
          'X-Android-Package': 'com.example.original',
          'X-Android-Cert': 'ORIGINAL_CERT',
        };

        final newHeaders = {
          'X-Android-Package': 'com.example.updated',
          'X-Android-Cert': 'UPDATED_CERT',
          'Additional-Header': 'new-value',
        };

        final originalRequest = RoutesApiRequest(
          origin: origin,
          destination: destination,
          headers: originalHeaders,
        );

        final updatedRequest = originalRequest.copyWith(
          headers: newHeaders,
        );

        expect(originalRequest.headers, equals(originalHeaders));
        expect(updatedRequest.headers, equals(newHeaders));
        expect(updatedRequest.headers!['Additional-Header'], equals('new-value'));
      });

      test('should preserve other fields when updating headers via copyWith', () {
        final originalRequest = RoutesApiRequest(
          origin: origin,
          destination: destination,
          travelMode: TravelMode.walking,
          computeAlternativeRoutes: true,
          headers: {'Original': 'header'},
        );

        final updatedRequest = originalRequest.copyWith(
          headers: {'Updated': 'header'},
        );

        expect(updatedRequest.origin, equals(origin));
        expect(updatedRequest.destination, equals(destination));
        expect(updatedRequest.travelMode, equals(TravelMode.walking));
        expect(updatedRequest.computeAlternativeRoutes, isTrue);
        expect(updatedRequest.headers, equals({'Updated': 'header'}));
      });

      test('should handle Android-specific headers for restricted API keys', () {
        final androidHeaders = {
          'X-Android-Package': 'com.example.flutter_app',
          'X-Android-Cert': 'AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD',
        };

        final request = RoutesApiRequest(
          origin: origin,
          destination: destination,
          headers: androidHeaders,
        );

        expect(request.headers!['X-Android-Package'], equals('com.example.flutter_app'));
        expect(request.headers!['X-Android-Cert'], 
            equals('AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD'));
      });
    });
  });
}