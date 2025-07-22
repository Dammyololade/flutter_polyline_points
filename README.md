# Flutter Polyline Points

[![pub package](https://img.shields.io/pub/v/flutter_polyline_points.svg)](https://pub.dartlang.org/packages/flutter_polyline_points)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Flutter package for decoding polyline points from Google Maps Directions API and the new Google Routes API. This package provides a unified interface supporting both legacy Directions API and the enhanced Google Routes API.

## 🚀 Version 3.0 - Simplified Routes API Integration

Version 3.0 introduces a **simplified and unified approach** to Google's routing services:

- **Single `PolylinePoints` class** for both APIs
- **Simplified Routes API integration** with essential features
- **Enhanced request/response models** with better type safety
- **Custom body parameters** for advanced use cases
- **Comprehensive test coverage** for reliability
- **Backward compatibility** maintained for existing code

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_polyline_points: ^3.0.0
```

Then run:

```bash
flutter pub get
```

## 🔑 API Key Setup

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Enable the **Directions API** and/or **Routes API**
3. Create an API key
4. Configure API key restrictions as needed

> **Note**: The Routes API may have different pricing than the Directions API. Check the [Google Routes API documentation](https://developers.google.com/maps/documentation/routes) for details.

## 📱 Basic Usage

### Legacy Directions API (Backward Compatibility)

```dart
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

// Initialize PolylinePoints
PolylinePoints polylinePoints = PolylinePoints(apiKey: "YOUR_API_KEY");

// Get route using legacy Directions API
PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  request: PolylineRequest(
    origin: PointLatLng(37.7749, -122.4194), // San Francisco
    destination: PointLatLng(37.3382, -121.8863), // San Jose
    mode: TravelMode.driving,
  ),
);

if (result.points.isNotEmpty) {
  // Convert to LatLng for Google Maps
  List<LatLng> polylineCoordinates = result.points
      .map((point) => LatLng(point.latitude, point.longitude))
      .toList();
}
```

### Routes API (Enhanced Features)

```dart
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

// Initialize PolylinePoints
PolylinePoints polylinePoints = PolylinePoints(apiKey: "YOUR_API_KEY");

// Create Routes API request
RoutesApiRequest request = RoutesApiRequest(
  origin: PointLatLng(37.7749, -122.4194),
  destination: PointLatLng(37.3382, -121.8863),
  travelMode: TravelMode.driving,
  routingPreference: RoutingPreference.trafficAware,
);

// Get route using Routes API
RoutesApiResponse response = await polylinePoints.getRouteBetweenCoordinatesV2(
  request: request,
);

if (response.routes.isNotEmpty) {
  Route route = response.routes.first;
  
  // Access route information
  print('Duration: ${route.durationMinutes} minutes');
  print('Distance: ${route.distanceKm} km');
  
  // Get polyline points
  List<PointLatLng> points = route.polylinePoints ?? [];
}
```

## 🏍️ Two-Wheeler Routing

```dart
// Get optimized route for motorcycles/scooters
RoutesApiRequest request = RoutesApiRequest(
  origin: PointLatLng(37.7749, -122.4194),
  destination: PointLatLng(37.3382, -121.8863),
  travelMode: TravelMode.twoWheeler,
  routeModifiers: RouteModifiers(
    avoidHighways: true,
    avoidTolls: false,
  ),
);

RoutesApiResponse response = await polylinePoints.getRouteBetweenCoordinatesV2(
  request: request,
);
```

## 🛣️ Alternative Routes

```dart
// Get multiple route options
RoutesApiRequest request = RoutesApiRequest(
  origin: PointLatLng(37.7749, -122.4194),
  destination: PointLatLng(37.3382, -121.8863),
  computeAlternativeRoutes: true,
  intermediates: [
    PolylineWayPoint(location: "37.4419,-122.1430"), // Palo Alto coordinates
  ],
);

RoutesApiResponse response = await polylinePoints.getRouteBetweenCoordinatesV2(
  request: request,
);

// Access all alternative routes
for (int i = 0; i < response.routes.length; i++) {
  Route route = response.routes[i];
  print('Route ${i + 1}: ${route.durationMinutes} min, ${route.distanceKm} km');
}
```

## ⚙️ Advanced Configuration

### Route Modifiers

```dart
RoutesApiRequest request = RoutesApiRequest(
  origin: PointLatLng(37.7749, -122.4194),
  destination: PointLatLng(37.3382, -121.8863),
  travelMode: TravelMode.driving,
  routeModifiers: RouteModifiers(
    avoidTolls: true,
    avoidHighways: false,
    avoidFerries: true,
    avoidIndoor: false,
  ),
  routingPreference: RoutingPreference.trafficAware,
  units: Units.metric,
  polylineQuality: PolylineQuality.highQuality,
);

RoutesApiResponse response = await polylinePoints.getRouteBetweenCoordinatesV2(
  request: request,
);
```

### Custom Body Parameters

```dart
// Add custom parameters not covered by the standard API
RoutesApiRequest request = RoutesApiRequest(
  origin: PointLatLng(37.7749, -122.4194),
  destination: PointLatLng(37.3382, -121.8863),
  customBodyParameters: {
    'extraComputations': ['TRAFFIC_ON_POLYLINE'],
    'requestedReferenceTime': DateTime.now().toIso8601String(),
  },
);
```

### Timing Preferences

```dart
RoutesApiRequest request = RoutesApiRequest(
  origin: PointLatLng(37.7749, -122.4194),
  destination: PointLatLng(37.3382, -121.8863),
  travelMode: TravelMode.driving,
  routingPreference: RoutingPreference.trafficAware,
  departureTime: DateTime.now().add(Duration(hours: 1)),
  // OR
  // arrivalTime: DateTime.now().add(Duration(hours: 2)),
);
```

## 🔄 Migration Guide

### From v2.x to v3.0

Version 3.0 simplifies the API while maintaining backward compatibility:

```dart
// OLD (v2.x)
PolylinePoints polylinePoints = PolylinePoints();
PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  googleApiKey: "YOUR_API_KEY",
  request: request,
);

// NEW (v3.0)
PolylinePoints polylinePoints = PolylinePoints(apiKey: "YOUR_API_KEY");
PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  request: request,
);
```

### Converting Between APIs

```dart
// Convert Routes API response to legacy format
RoutesApiResponse routesResponse = await polylinePoints.getRouteBetweenCoordinatesV2(
  request: routesRequest,
);

PolylineResult legacyResult = polylinePoints.convertToLegacyResult(routesResponse);
```

### Factory Constructors

```dart
// Optimized for legacy API
PolylinePoints legacyPoints = PolylinePoints.legacy("YOUR_API_KEY");

// Optimized for Routes API
PolylinePoints enhancedPoints = PolylinePoints.enhanced("YOUR_API_KEY");

// Custom configuration
PolylinePoints customPoints = PolylinePoints.custom(
  apiKey: "YOUR_API_KEY",
  timeout: Duration(seconds: 60),
  preferRoutesApi: true,
);
```

## 📊 Response Data

### Legacy API Response

```dart
class PolylineResult {
  List<PointLatLng> points;
  String? errorMessage;
  String? status;
}
```

### Routes API Response

```dart
class RoutesApiResponse {
  List<Route> routes;
  String? status;
  String? errorMessage;
}

class Route {
  int? duration;              // Duration in seconds
  int? staticDuration;        // Static duration in seconds
  int? distanceMeters;        // Distance in meters
  String? polylineEncoded;    // Encoded polyline string
  List<PointLatLng>? polylinePoints; // Decoded polyline points
  
  // Convenience getters
  double? get durationMinutes => duration != null ? duration! / 60.0 : null;
  double? get staticDurationMinutes => staticDuration != null ? staticDuration! / 60.0 : null;
  double? get distanceKm => distanceMeters != null ? distanceMeters! / 1000.0 : null;
}
```

## 🎯 Features Comparison

| Feature | Legacy Directions API | Routes API |
|---------|----------------------|------------|
| Basic routing | ✅ | ✅ |
| Waypoints | ✅ | ✅ |
| Travel modes | Driving, Walking, Bicycling, Transit | + Two-Wheeler |
| Alternative routes | ✅ | ✅ |
| Route modifiers | Basic | Enhanced |
| Polyline quality | Standard | High-quality, Overview |
| Request format | GET with query params | POST with JSON |
| Custom parameters | ❌ | ✅ |
| Timing preferences | ❌ | ✅ |
| Field mask support | ❌ | ✅ |

## 🔧 Troubleshooting

### Common Issues

1. **API Key Issues**
   - Ensure your API key has the correct APIs enabled
   - Check API key restrictions and quotas
   - Verify billing is enabled for your Google Cloud project

2. **Routes API Errors**
   - The Routes API requires different permissions than Directions API
   - Check the [Routes API documentation](https://developers.google.com/maps/documentation/routes) for requirements

3. **Migration Issues**
   - Update constructor calls to include `apiKey` parameter
   - Use `convertToLegacyResult()` for compatibility
   - Check method signatures for parameter changes

### Error Handling

```dart
try {
  RoutesApiResponse response = await polylinePoints.getRouteBetweenCoordinatesV2(
    request: RoutesApiRequest(
      origin: PointLatLng(37.7749, -122.4194),
      destination: PointLatLng(37.3382, -121.8863),
    ),
  );
  
  if (response.routes.isNotEmpty) {
    // Success
    Route route = response.routes.first;
  } else {
    print('Error: ${response.errorMessage ?? "No routes found"}');
  }
} catch (e) {
  print('Exception: $e');
}
```

## 📚 Examples

Check out the `/example` folder for comprehensive examples:

- **Legacy API Example**: Basic routing with backward compatibility
- **Routes API Example**: Enhanced features and custom parameters
- **Two-Wheeler Example**: Motorcycle/scooter optimized routing
- **Advanced Configuration**: Custom body parameters and timing preferences

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests to our repository.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- [Google Directions API Documentation](https://developers.google.com/maps/documentation/directions)
- [Google Routes API Documentation](https://developers.google.com/maps/documentation/routes)
- [Package on pub.dev](https://pub.dev/packages/flutter_polyline_points)
- [GitHub Repository](https://github.com/your-repo/flutter_polyline_points)

## 📈 Changelog

### Version 3.0.0
- 🔄 **BREAKING**: Simplified API with unified `PolylinePoints` class
- 🔄 **BREAKING**: Constructor now requires `apiKey` parameter
- ✨ Enhanced Routes API integration with `RoutesApiRequest`/`RoutesApiResponse`
- 🛠️ Added custom body parameters support
- 🏍️ Added two-wheeler routing mode
- ⏰ Added timing preferences (departure/arrival time)
- 🎯 Added field mask support for response optimization
- 🧪 Comprehensive test coverage added
- 📊 Improved response models with convenience getters
- 🔧 Better error handling and type safety
- 🛠️ Maintained backward compatibility for legacy API

### Previous Versions
See [CHANGELOG.md](CHANGELOG.md) for complete version history.
