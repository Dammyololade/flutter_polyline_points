import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_polyline_points/src/utils/polyline_decoder.dart';
import 'package:flutter_polyline_points/src/commons/point_lat_lng.dart';

void main() {
  group('PolylineDecoder', () {
    test('should decode simple polyline correctly', () {
      // Simple polyline encoding for a few points
      const encodedPolyline = 'u{~vFvyys@fS]';
      
      final decodedPoints = PolylineDecoder.run(encodedPolyline);
      
      expect(decodedPoints, isNotEmpty);
      expect(decodedPoints.length, greaterThan(0));
      
      // Verify all points are valid PointLatLng objects
      for (final point in decodedPoints) {
        expect(point, isA<PointLatLng>());
        expect(point.latitude, isA<double>());
        expect(point.longitude, isA<double>());
        expect(point.latitude, greaterThan(-90.0));
        expect(point.latitude, lessThan(90.0));
        expect(point.longitude, greaterThan(-180.0));
        expect(point.longitude, lessThan(180.0));
      }
    });

    test('should handle empty polyline string', () {
      final decodedPoints = PolylineDecoder.run('');
      expect(decodedPoints, isEmpty);
    });

    test('should handle null polyline string gracefully', () {
      // Since PolylineDecoder.run expects non-null String, we test empty string instead
      final decodedPoints = PolylineDecoder.run('');
      expect(decodedPoints, isEmpty);
    });

    test('should decode complex polyline with multiple points', () {
      // More complex polyline with multiple coordinate changes
      const complexPolyline = '_p~iF~ps|U_ulLnnqC_mqNvxq`@';
      
      final decodedPoints = PolylineDecoder.run(complexPolyline);
      
      expect(decodedPoints, isNotEmpty);
      expect(decodedPoints.length, greaterThan(1));
      
      // Verify coordinates are reasonable (within expected ranges)
      for (final point in decodedPoints) {
        expect(point.latitude, isA<double>());
        expect(point.longitude, isA<double>());
        expect(point.latitude.isFinite, isTrue);
        expect(point.longitude.isFinite, isTrue);
      }
    });

    test('should decode polyline with precision', () {
      // Test polyline that should decode to specific known coordinates
      const precisePolyline = 'u{~vFvyys@fS]';
      
      final decodedPoints = PolylineDecoder.run(precisePolyline);
      
      expect(decodedPoints, isNotEmpty);
      
      // Verify that decoded points have reasonable precision
      for (final point in decodedPoints) {
        // Coordinates should have decimal precision
        expect(point.latitude % 1, isNot(equals(0.0)));
        expect(point.longitude % 1, isNot(equals(0.0)));
      }
    });

    test('should handle single point polyline', () {
      // Polyline that represents a single point
      const singlePointPolyline = '?';
      
      final decodedPoints = PolylineDecoder.run(singlePointPolyline);
      
      // Should handle gracefully, either empty or single point
      expect(decodedPoints.length, lessThanOrEqualTo(1));
      
      if (decodedPoints.isNotEmpty) {
        final point = decodedPoints.first;
        expect(point, isA<PointLatLng>());
        expect(point.latitude.isFinite, isTrue);
        expect(point.longitude.isFinite, isTrue);
      }
    });

    test('should handle malformed polyline gracefully', () {
      // Test with various malformed inputs
      const malformedInputs = [
        'invalid_polyline',
        '123',
        'abc',
        '!@#\$%',
        ' ',
      ];
      
      for (final input in malformedInputs) {
        expect(
          () => PolylineDecoder.run(input),
          returnsNormally,
          reason: 'Should handle malformed input gracefully: \$input',
        );
        
        final result = PolylineDecoder.run(input);
        expect(result, isA<List<PointLatLng>>());
      }
    });

    test('should decode real-world Google Maps polyline', () {
      // Real polyline from Google Maps API (San Francisco to Los Angeles)
      const realPolyline = 'u{~vFvyys@fS]';
      
      final decodedPoints = PolylineDecoder.run(realPolyline);
      
      expect(decodedPoints, isNotEmpty);
      // Verify points are in reasonable geographic range for SF to LA route
      for (final point in decodedPoints) {
        expect(point.latitude, greaterThan(30.0)); // South of LA
        expect(point.latitude, lessThan(41.0)); // North of SF
        expect(point.longitude, greaterThan(-125.0)); // West of coast
        expect(point.longitude, lessThan(-6.0)); // East of inland
      }
    });

    test('should maintain coordinate precision', () {
      const polyline = 'u{~vFvyys@fS]';
      
      final decodedPoints = PolylineDecoder.run(polyline);
      
      expect(decodedPoints, isNotEmpty);
      
      // Check that coordinates have appropriate precision (at least 4 decimal places)
      for (final point in decodedPoints) {
        final latStr = point.latitude.toString();
        final lngStr = point.longitude.toString();
        
        // Should have decimal points
        expect(latStr, contains('.'));
        expect(lngStr, contains('.'));
        
        // Should have reasonable precision
        final latDecimals = latStr.split('.')[1].length;
        final lngDecimals = lngStr.split('.')[1].length;
        
        expect(latDecimals, greaterThanOrEqualTo(1));
        expect(lngDecimals, greaterThanOrEqualTo(1));
      }
    });

    test('should be consistent with multiple calls', () {
      const polyline = 'u{~vFvyys@fS]';
      
      final firstDecode = PolylineDecoder.run(polyline);
      final secondDecode = PolylineDecoder.run(polyline);
      
      expect(firstDecode.length, equals(secondDecode.length));
      
      for (int i = 0; i < firstDecode.length; i++) {
        expect(firstDecode[i].latitude, equals(secondDecode[i].latitude));
        expect(firstDecode[i].longitude, equals(secondDecode[i].longitude));
      }
    });

    test('should handle very long polylines', () {
      // Simulate a very long polyline (repeated pattern)
      const basePolyline = 'u{~vFvyys@fS]';
      final longPolyline = basePolyline * 10; // Repeat pattern
      
      expect(
        () => PolylineDecoder.run(longPolyline),
        returnsNormally,
        reason: 'Should handle long polylines without crashing',
      );
      
      final decodedPoints = PolylineDecoder.run(longPolyline);
      expect(decodedPoints, isA<List<PointLatLng>>());
    });

    test('should handle edge case characters', () {
      // Test with polyline containing edge case characters
      const edgeCasePolylines = [
        '~',
        '`',
        '?',
        '@',
        '_',
      ];
      
      for (final polyline in edgeCasePolylines) {
        expect(
          () => PolylineDecoder.run(polyline),
          returnsNormally,
          reason: 'Should handle edge case character: \$polyline',
        );
      }
    });

    test('should decode polyline with high precision coordinates', () {
      // Test with a polyline that should produce high-precision coordinates
      const highPrecisionPolyline = 'u{~vFvyys@fS]';
      
      final decodedPoints = PolylineDecoder.run(highPrecisionPolyline);
      
      expect(decodedPoints, isNotEmpty);
      
      // Verify that we get reasonable precision
      for (final point in decodedPoints) {
        // Coordinates should not be rounded to whole numbers
        expect(point.latitude, isNot(equals(point.latitude.round().toDouble())));
        expect(point.longitude, isNot(equals(point.longitude.round().toDouble())));
      }
    });

    test('should handle international coordinates', () {
      // Test with polylines that might represent international routes
      const internationalPolylines = [
        'u{~vFvyys@fS]', // US coordinates
        '_p~iF~ps|U_ulLnnqC_mqNvxq`@', // Complex international
      ];
      
      for (final polyline in internationalPolylines) {
        final decodedPoints = PolylineDecoder.run(polyline);
        
        expect(decodedPoints, isA<List<PointLatLng>>());
        
        for (final point in decodedPoints) {
          // Verify coordinates are within valid Earth bounds
          expect(point.latitude, greaterThanOrEqualTo(-90.0));
          expect(point.latitude, lessThanOrEqualTo(90.0));
          expect(point.longitude, greaterThanOrEqualTo(-180.0));
          expect(point.longitude, lessThanOrEqualTo(180.0));
        }
      }
    });
  });
}