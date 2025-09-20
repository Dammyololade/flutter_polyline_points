import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_polyline_points/src/routes_api/routes_request.dart';
import 'package:flutter_polyline_points/src/commons/point_lat_lng.dart';
import 'package:flutter_polyline_points/src/commons/travel_mode.dart';

void main() {
  group('NetworkProvider', () {
    late PointLatLng origin;
    late PointLatLng destination;

    setUp(() {
      origin = PointLatLng(37.7749, -122.4194); // San Francisco
      destination = PointLatLng(34.0522, -118.2437); // Los Angeles
    });

    group('Headers functionality', () {
      test('should generate basic headers without custom headers', () {
        final request = RoutesApiRequest(
          origin: origin,
          destination: destination,
        );

        // Access the private method through reflection or create a test helper
        // For now, we'll test the integration through the public API behavior
        expect(request.headers, isNull);
      });

      test('should include custom headers in request', () {
        final customHeaders = {
          'X-Android-Package': 'com.example.testapp',
          'X-Android-Cert': 'TEST_CERT_FINGERPRINT',
          'Custom-Header': 'custom-value',
        };

        final request = RoutesApiRequest(
          origin: origin,
          destination: destination,
          headers: customHeaders,
        );

        expect(request.headers, isNotNull);
        expect(request.headers!['X-Android-Package'], equals('com.example.testapp'));
        expect(request.headers!['X-Android-Cert'], equals('TEST_CERT_FINGERPRINT'));
        expect(request.headers!['Custom-Header'], equals('custom-value'));
      });

      test('should handle Android-specific headers for restricted API keys', () {
        final androidHeaders = {
          'X-Android-Package': 'com.example.flutter_polyline_points',
          'X-Android-Cert': 'AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD',
        };

        final request = RoutesApiRequest(
          origin: origin,
          destination: destination,
          travelMode: TravelMode.driving,
          headers: androidHeaders,
        );

        expect(request.headers, isNotNull);
        expect(request.headers!['X-Android-Package'], 
            equals('com.example.flutter_polyline_points'));
        expect(request.headers!['X-Android-Cert'], 
            equals('AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD'));
      });

      test('should handle multiple custom headers', () {
        final multipleHeaders = {
          'X-Android-Package': 'com.example.app',
          'X-Android-Cert': 'cert123',
          'Authorization': 'Bearer token123',
          'X-Custom-Header-1': 'value1',
          'X-Custom-Header-2': 'value2',
        };

        final request = RoutesApiRequest(
          origin: origin,
          destination: destination,
          headers: multipleHeaders,
        );

        expect(request.headers, hasLength(5));
        multipleHeaders.forEach((key, value) {
          expect(request.headers![key], equals(value));
        });
      });

      test('should handle empty headers map', () {
        final request = RoutesApiRequest(
          origin: origin,
          destination: destination,
          headers: {},
        );

        expect(request.headers, isNotNull);
        expect(request.headers, isEmpty);
      });

      test('should preserve headers when copying request', () {
        final originalHeaders = {
          'X-Android-Package': 'com.example.original',
          'X-Android-Cert': 'original_cert',
        };

        final newHeaders = {
          'X-Android-Package': 'com.example.updated',
          'X-Android-Cert': 'updated_cert',
          'New-Header': 'new_value',
        };

        final originalRequest = RoutesApiRequest(
          origin: origin,
          destination: destination,
          headers: originalHeaders,
        );

        final copiedRequest = originalRequest.copyWith(
          headers: newHeaders,
        );

        // Original request should remain unchanged
        expect(originalRequest.headers, equals(originalHeaders));
        expect(originalRequest.headers!['X-Android-Package'], equals('com.example.original'));

        // Copied request should have new headers
        expect(copiedRequest.headers, equals(newHeaders));
        expect(copiedRequest.headers!['X-Android-Package'], equals('com.example.updated'));
        expect(copiedRequest.headers!['New-Header'], equals('new_value'));
      });

      test('should handle language code with custom headers', () {
        final customHeaders = {
          'X-Android-Package': 'com.example.app',
          'X-Android-Cert': 'cert123',
        };

        final request = RoutesApiRequest(
          origin: origin,
          destination: destination,
          languageCode: 'es',
          headers: customHeaders,
        );

        expect(request.languageCode, equals('es'));
        expect(request.headers, equals(customHeaders));
        expect(request.headers!['X-Android-Package'], equals('com.example.app'));
      });

      test('should handle request with both custom body parameters and headers', () {
        final customHeaders = {
          'X-Android-Package': 'com.example.app',
          'X-Android-Cert': 'cert123',
        };

        final customBodyParams = {
          'extraComputations': ['TRAFFIC_ON_POLYLINE'],
          'customField': 'customValue',
        };

        final request = RoutesApiRequest(
          origin: origin,
          destination: destination,
          headers: customHeaders,
          customBodyParameters: customBodyParams,
        );

        expect(request.headers, equals(customHeaders));
        expect(request.customBodyParameters, equals(customBodyParams));
        
        final json = request.toJson();
        expect(json['extraComputations'], contains('TRAFFIC_ON_POLYLINE'));
        expect(json['customField'], equals('customValue'));
      });
    });

    group('Header validation', () {
      test('should accept valid header names and values', () {
        final validHeaders = {
          'X-Android-Package': 'com.example.app',
          'X-Android-Cert': 'AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD',
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9',
          'Content-Type': 'application/json',
          'User-Agent': 'MyApp/1.0.0',
          'Accept-Language': 'en-US,en;q=0.9',
        };

        final request = RoutesApiRequest(
          origin: origin,
          destination: destination,
          headers: validHeaders,
        );

        expect(request.headers, equals(validHeaders));
        validHeaders.forEach((key, value) {
          expect(request.headers![key], equals(value));
        });
      });

      test('should handle special characters in header values', () {
        final headersWithSpecialChars = {
          'X-Android-Package': 'com.example.app_test-123',
          'X-Android-Cert': 'AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD',
          'Custom-Header': 'value with spaces and-dashes_underscores',
        };

        final request = RoutesApiRequest(
          origin: origin,
          destination: destination,
          headers: headersWithSpecialChars,
        );

        expect(request.headers, equals(headersWithSpecialChars));
        expect(request.headers!['Custom-Header'], 
            equals('value with spaces and-dashes_underscores'));
      });
    });
  });
}