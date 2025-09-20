import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polyline Points Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() {
    return MainScreenState();
  }
}

class MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String googleApiKey =
      "YOUR_GOOGLE_API_KEY_HERE"; // Replace with your actual API key

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Polyline Points'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Legacy API', icon: Icon(Icons.route)),
            Tab(text: 'Routes API', icon: Icon(Icons.alt_route)),
            Tab(text: 'Two-Wheeler', icon: Icon(Icons.motorcycle)),
            Tab(text: 'Headers', icon: Icon(Icons.security)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          LegacyMapScreen(apiKey: googleApiKey),
          RoutesApiMapScreen(apiKey: googleApiKey),
          TwoWheelerMapScreen(apiKey: googleApiKey),
          CustomHeadersMapScreen(apiKey: googleApiKey),
        ],
      ),
    );
  }
}

// Legacy API Example (Backward Compatibility)
class LegacyMapScreen extends StatefulWidget {
  final String apiKey;

  const LegacyMapScreen({super.key, required this.apiKey});

  @override
  LegacyMapScreenState createState() => LegacyMapScreenState();
}

class LegacyMapScreenState extends State<LegacyMapScreen> {
  late GoogleMapController mapController;
  final double _originLatitude = 6.5212402, _originLongitude = 3.3679965;
  final double _destLatitude = 6.849660, _destLongitude = 3.648190;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    polylinePoints = PolylinePoints(apiKey: widget.apiKey);

    _addMarker(LatLng(_originLatitude, _originLongitude), "origin",
        BitmapDescriptor.defaultMarker);
    _addMarker(LatLng(_destLatitude, _destLongitude), "destination",
        BitmapDescriptor.defaultMarkerWithHue(90));

    _getPolyline();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
                target: LatLng(_originLatitude, _originLongitude), zoom: 12),
            myLocationEnabled: true,
            tiltGesturesEnabled: true,
            compassEnabled: true,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            onMapCreated: _onMapCreated,
            markers: Set<Marker>.of(markers.values),
            polylines: Set<Polyline>.of(polylines.values),
          ),
          if (isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          if (errorMessage != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.red[100],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error: $errorMessage',
                    style: TextStyle(color: Colors.red[800]),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Legacy Directions API',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Using the original Google Directions API with basic routing features.',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _getPolyline,
                      child: const Text('Refresh Route'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  _addPolyLine() {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue,
        points: polylineCoordinates,
        width: 5);
    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      polylineCoordinates.clear();
      polylines.clear();
    });

    try {
      final result = await polylinePoints.getRouteBetweenCoordinatesV2(
        request: RoutesApiRequest(
          origin: PointLatLng(_originLatitude, _originLongitude),
          destination: PointLatLng(_destLatitude, _destLongitude),
        ),
      );

      if (result.primaryRoute?.polylinePoints case List<PointLatLng> points) {
        for (var point in points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
        _addPolyLine();
      } else {
        setState(() {
          errorMessage = result.errorMessage ?? 'No route found';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}

// Custom Headers Example (Android-restricted API keys)
class CustomHeadersMapScreen extends StatefulWidget {
  final String apiKey;

  const CustomHeadersMapScreen({super.key, required this.apiKey});

  @override
  CustomHeadersMapScreenState createState() => CustomHeadersMapScreenState();
}

class CustomHeadersMapScreenState extends State<CustomHeadersMapScreen> {
  late GoogleMapController mapController;
  final double _originLatitude = 6.5212402, _originLongitude = 3.3679965;
  final double _destLatitude = 6.849660, _destLongitude = 3.648190;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  late PolylinePoints polylinePoints;
  bool isLoading = false;
  String? errorMessage;
  RoutesApiResponse? currentResponse;

  // Custom headers for Android-restricted API keys
  final TextEditingController _packageNameController = TextEditingController();
  final TextEditingController _certFingerprintController =
      TextEditingController();
  bool _useCustomHeaders = false;

  @override
  void initState() {
    super.initState();
    polylinePoints = PolylinePoints.enhanced(widget.apiKey);
    _addMarker(LatLng(_originLatitude, _originLongitude), "origin",
        BitmapDescriptor.defaultMarker);
    _addMarker(LatLng(_destLatitude, _destLongitude), "destination",
        BitmapDescriptor.defaultMarkerWithHue(90));

    // Set default values for demonstration
    _packageNameController.text = 'com.example.myapp';
    _certFingerprintController.text = 'YOUR_SHA1_FINGERPRINT';
  }

  @override
  void dispose() {
    _packageNameController.dispose();
    _certFingerprintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
                target: LatLng(_originLatitude, _originLongitude), zoom: 12),
            myLocationEnabled: true,
            tiltGesturesEnabled: true,
            compassEnabled: true,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            onMapCreated: _onMapCreated,
            markers: Set<Marker>.of(markers.values),
            polylines: Set<Polyline>.of(polylines.values),
          ),
          if (isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          if (errorMessage != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.red[100],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error: $errorMessage',
                    style: TextStyle(color: Colors.red[800]),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.security, color: Colors.purple),
                        const SizedBox(width: 8),
                        Text(
                          'Custom Headers Demo',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Demonstrates using custom headers for Android-restricted API keys.',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      title: const Text('Use Custom Headers',
                          style: TextStyle(fontSize: 14)),
                      subtitle: const Text('For Android-restricted API keys',
                          style: TextStyle(fontSize: 12)),
                      value: _useCustomHeaders,
                      onChanged: (value) {
                        setState(() {
                          _useCustomHeaders = value ?? false;
                        });
                      },
                      dense: true,
                    ),
                    if (_useCustomHeaders) ..._buildHeaderInputs(),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _getRouteWithHeaders,
                      icon: const Icon(Icons.security),
                      label: const Text('Get Route with Headers'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildHeaderInputs() {
    return [
      const SizedBox(height: 8),
      TextField(
        controller: _packageNameController,
        decoration: const InputDecoration(
          labelText: 'Package Name',
          hintText: 'com.example.myapp',
          border: OutlineInputBorder(),
        ),
        style: const TextStyle(fontSize: 12),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _certFingerprintController,
        decoration: const InputDecoration(
          labelText: 'SHA1 Fingerprint',
          hintText: 'YOUR_SHA1_FINGERPRINT',
          border: OutlineInputBorder(),
        ),
        style: const TextStyle(fontSize: 12),
      ),
    ];
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  _addPolyLine(List<LatLng> coordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id, color: Colors.purple, points: coordinates, width: 5);
    polylines[id] = polyline;
    setState(() {});
  }

  _getRouteWithHeaders() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      polylines.clear();
      currentResponse = null;
    });

    try {
      // Prepare custom headers if enabled
      Map<String, String>? customHeaders;
      if (_useCustomHeaders) {
        customHeaders = {
          'X-Android-Package': _packageNameController.text.trim(),
          'X-Android-Cert': _certFingerprintController.text.trim(),
        };
      }

      RoutesApiResponse response =
          await polylinePoints.getRouteBetweenCoordinatesV2(
        request: RoutesApiRequest(
          origin: PointLatLng(_originLatitude, _originLongitude),
          destination: PointLatLng(_destLatitude, _destLongitude),
          travelMode: TravelMode.driving,
          headers: customHeaders, // Pass custom headers
        ),
      );

      setState(() {
        currentResponse = response;
      });

      if (response.routes.isNotEmpty) {
        final route = response.routes.first;
        if (route.polylinePoints != null) {
          final points = polylinePoints.convertToLegacyResult(response).points;
          final coordinates = points
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();
          _addPolyLine(coordinates);
        }
      } else {
        setState(() {
          errorMessage = response.errorMessage ?? 'No route found';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}

// Routes API Example (Enhanced Features)
class RoutesApiMapScreen extends StatefulWidget {
  final String apiKey;

  const RoutesApiMapScreen({super.key, required this.apiKey});

  @override
  RoutesApiMapScreenState createState() => RoutesApiMapScreenState();
}

class RoutesApiMapScreenState extends State<RoutesApiMapScreen> {
  late GoogleMapController mapController;
  final double _originLatitude = 6.5212402, _originLongitude = 3.3679965;
  final double _destLatitude = 6.849660, _destLongitude = 3.648190;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;
  bool isLoading = false;
  String? errorMessage;
  RoutesApiResponse? currentResponse;

  @override
  void initState() {
    super.initState();
    polylinePoints = PolylinePoints.enhanced(widget.apiKey);
    _addMarker(LatLng(_originLatitude, _originLongitude), "origin",
        BitmapDescriptor.defaultMarker);
    _addMarker(LatLng(_destLatitude, _destLongitude), "destination",
        BitmapDescriptor.defaultMarkerWithHue(90));
    _getEnhancedRoute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
                target: LatLng(_originLatitude, _originLongitude), zoom: 12),
            myLocationEnabled: true,
            tiltGesturesEnabled: true,
            compassEnabled: true,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            onMapCreated: _onMapCreated,
            markers: Set<Marker>.of(markers.values),
            polylines: Set<Polyline>.of(polylines.values),
          ),
          if (isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          if (errorMessage != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.red[100],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error: $errorMessage',
                    style: TextStyle(color: Colors.red[800]),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Enhanced Routes API',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Using the new Google Routes API with traffic-aware routing, toll information, and enhanced features.',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    if (currentResponse != null &&
                        currentResponse!.routes.isNotEmpty)
                      ..._buildRouteInfo(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _getEnhancedRoute,
                          child: const Text('Enhanced Route'),
                        ),
                        ElevatedButton(
                          onPressed: _getAlternativeRoutes,
                          child: const Text('Alternatives'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRouteInfo() {
    final route = currentResponse!.routes.first;
    return [
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text('Duration',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(route.duration?.toString() ?? 'N/A'),
            ],
          ),
          Column(
            children: [
              const Text('Distance',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(route.distanceMeters != null
                  ? '${(route.distanceMeters! / 1000).toStringAsFixed(1)} km'
                  : 'N/A'),
            ],
          ),
        ],
      ),
    ];
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  _addPolyLine(List<LatLng> coordinates,
      {Color color = Colors.green, String id = "poly"}) {
    PolylineId polylineId = PolylineId(id);
    Polyline polyline = Polyline(
        polylineId: polylineId, color: color, points: coordinates, width: 5);
    polylines[polylineId] = polyline;
    setState(() {});
  }

  _getEnhancedRoute() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      polylineCoordinates.clear();
      polylines.clear();
      currentResponse = null;
    });

    try {
      RoutesApiResponse response =
          await polylinePoints.getRouteBetweenCoordinatesV2(
              request: RequestConverter.createEnhancedRequest(
        origin: PointLatLng(_originLatitude, _originLongitude),
        destination: PointLatLng(_destLatitude, _destLongitude),
      ));

      setState(() {
        currentResponse = response;
      });

      if (response.routes.isNotEmpty) {
        final route = response.routes.first;
        if (route.polylinePoints != null) {
          final points = polylinePoints.convertToLegacyResult(response).points;
          final coordinates = points
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();
          _addPolyLine(coordinates, color: Colors.green);
        }
      } else {
        setState(() {
          errorMessage = response.errorMessage ?? 'No route found';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  _getAlternativeRoutes() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      polylines.clear();
      currentResponse = null;
    });

    try {
      RoutesApiResponse response =
          await polylinePoints.getRouteBetweenCoordinatesV2(
              request: RequestConverter.createEnhancedRequest(
        origin: PointLatLng(_originLatitude, _originLongitude),
        destination: PointLatLng(_destLatitude, _destLongitude),
        waypoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")],
        alternatives: true,
        extraComputations: [ExtraComputation.fuelConsumption],
      ));

      setState(() {
        currentResponse = response;
      });

      if (response.routes.isNotEmpty) {
        final colors = [Colors.green, Colors.blue, Colors.orange];
        for (int i = 0; i < response.routes.length && i < colors.length; i++) {
          final route = response.routes[i];
          if (route.polylinePoints != null) {
            final coordinates = route.polylinePoints!
                .map((point) => LatLng(point.latitude, point.longitude))
                .toList();
            _addPolyLine(coordinates, color: colors[i], id: "poly_$i");
          }
        }
      } else {
        setState(() {
          errorMessage = response.errorMessage ?? 'No routes found';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}

// Two-Wheeler Example (Routes API Exclusive Feature)
class TwoWheelerMapScreen extends StatefulWidget {
  final String apiKey;

  const TwoWheelerMapScreen({super.key, required this.apiKey});

  @override
  TwoWheelerMapScreenState createState() => TwoWheelerMapScreenState();
}

class TwoWheelerMapScreenState extends State<TwoWheelerMapScreen> {
  late GoogleMapController mapController;
  final double _originLatitude = 6.5212402, _originLongitude = 3.3679965;
  final double _destLatitude = 6.849660, _destLongitude = 3.648190;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  late PolylinePoints polylinePointsV2;
  bool isLoading = false;
  String? errorMessage;
  RoutesApiResponse? currentResponse;
  bool avoidHighways = false;
  bool avoidTolls = false;

  @override
  void initState() {
    super.initState();
    polylinePointsV2 = PolylinePoints.enhanced(widget.apiKey);
    _addMarker(LatLng(_originLatitude, _originLongitude), "origin",
        BitmapDescriptor.defaultMarker);
    _addMarker(LatLng(_destLatitude, _destLongitude), "destination",
        BitmapDescriptor.defaultMarkerWithHue(90));
    _getTwoWheelerRoute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
                target: LatLng(_originLatitude, _originLongitude), zoom: 12),
            myLocationEnabled: true,
            tiltGesturesEnabled: true,
            compassEnabled: true,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            onMapCreated: _onMapCreated,
            markers: Set<Marker>.of(markers.values),
            polylines: Set<Polyline>.of(polylines.values),
          ),
          if (isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          if (errorMessage != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.red[100],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error: $errorMessage',
                    style: TextStyle(color: Colors.red[800]),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.motorcycle, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          'Two-Wheeler Routing',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Optimized routing for motorcycles and scooters. This feature is exclusive to the Routes API.',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text('Avoid Highways',
                                style: TextStyle(fontSize: 12)),
                            value: avoidHighways,
                            onChanged: (value) {
                              setState(() {
                                avoidHighways = value ?? false;
                              });
                              _getTwoWheelerRoute();
                            },
                            dense: true,
                          ),
                        ),
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text('Avoid Tolls',
                                style: TextStyle(fontSize: 12)),
                            value: avoidTolls,
                            onChanged: (value) {
                              setState(() {
                                avoidTolls = value ?? false;
                              });
                              _getTwoWheelerRoute();
                            },
                            dense: true,
                          ),
                        ),
                      ],
                    ),
                    if (currentResponse != null &&
                        currentResponse!.routes.isNotEmpty)
                      ..._buildRouteInfo(),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _getTwoWheelerRoute,
                      icon: const Icon(Icons.motorcycle),
                      label: const Text('Get Two-Wheeler Route'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRouteInfo() {
    final route = currentResponse!.routes.first;
    return [
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text('Duration',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(route.duration?.toString() ?? 'N/A'),
            ],
          ),
          Column(
            children: [
              const Text('Distance',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(route.distanceMeters != null
                  ? '${(route.distanceMeters! / 1000).toStringAsFixed(1)} km'
                  : 'N/A'),
            ],
          ),
        ],
      ),
    ];
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  _addPolyLine(List<LatLng> coordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id, color: Colors.orange, points: coordinates, width: 5);
    polylines[id] = polyline;
    setState(() {});
  }

  _getTwoWheelerRoute() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      polylines.clear();
      currentResponse = null;
    });

    try {
      RoutesApiResponse response =
          await polylinePointsV2.getRouteBetweenCoordinatesV2(
              request: RequestConverter.createEnhancedRequest(
        origin: PointLatLng(_originLatitude, _originLongitude),
        destination: PointLatLng(_destLatitude, _destLongitude),
        travelMode: TravelMode.twoWheeler,
      ));

      setState(() {
        currentResponse = response;
      });

      if (response.routes.isNotEmpty) {
        final route = response.routes.first;
        if (route.polylinePoints != null) {
          final points =
              polylinePointsV2.convertToLegacyResult(response).points;
          final coordinates = points
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();
          _addPolyLine(coordinates);
        }
      } else {
        setState(() {
          errorMessage = response.errorMessage ?? 'No route found';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
