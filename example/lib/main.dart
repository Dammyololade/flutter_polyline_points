import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polyline Points Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String googleApiKey = "YOUR_GOOGLE_API_KEY_HERE"; // Replace with your actual API key

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: Text('Flutter Polyline Points'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Legacy API', icon: Icon(Icons.route)),
            Tab(text: 'Routes API', icon: Icon(Icons.alt_route)),
            Tab(text: 'Two-Wheeler', icon: Icon(Icons.motorcycle)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          LegacyMapScreen(apiKey: googleApiKey),
          RoutesApiMapScreen(apiKey: googleApiKey),
          TwoWheelerMapScreen(apiKey: googleApiKey),
        ],
      ),
    );
  }
}

// Legacy API Example (Backward Compatibility)
class LegacyMapScreen extends StatefulWidget {
  final String apiKey;

  const LegacyMapScreen({Key? key, required this.apiKey}) : super(key: key);

  @override
  _LegacyMapScreenState createState() => _LegacyMapScreenState();
}

class _LegacyMapScreenState extends State<LegacyMapScreen> {
  late GoogleMapController mapController;
  double _originLatitude = 6.5212402, _originLongitude = 3.3679965;
  double _destLatitude = 6.849660, _destLongitude = 3.648190;
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

    _addMarker(LatLng(_originLatitude, _originLongitude), "origin", BitmapDescriptor.defaultMarker);
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
            initialCameraPosition:
                CameraPosition(target: LatLng(_originLatitude, _originLongitude), zoom: 12),
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
              child: Center(
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
                  padding: EdgeInsets.all(16),
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
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Legacy Directions API',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Using the original Google Directions API with basic routing features.',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _getPolyline,
                      child: Text('Refresh Route'),
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
    Marker marker = Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline =
        Polyline(polylineId: id, color: Colors.blue, points: polylineCoordinates, width: 5);
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
        points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
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

// Routes API Example (Enhanced Features)
class RoutesApiMapScreen extends StatefulWidget {
  final String apiKey;

  const RoutesApiMapScreen({Key? key, required this.apiKey}) : super(key: key);

  @override
  _RoutesApiMapScreenState createState() => _RoutesApiMapScreenState();
}

class _RoutesApiMapScreenState extends State<RoutesApiMapScreen> {
  late GoogleMapController mapController;
  double _originLatitude = 6.5212402, _originLongitude = 3.3679965;
  double _destLatitude = 6.849660, _destLongitude = 3.648190;
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
    _addMarker(LatLng(_originLatitude, _originLongitude), "origin", BitmapDescriptor.defaultMarker);
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
            initialCameraPosition:
                CameraPosition(target: LatLng(_originLatitude, _originLongitude), zoom: 12),
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
              child: Center(
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
                  padding: EdgeInsets.all(16),
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
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Enhanced Routes API',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Using the new Google Routes API with traffic-aware routing, toll information, and enhanced features.',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    if (currentResponse != null && currentResponse!.routes.isNotEmpty)
                      ..._buildRouteInfo(),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _getEnhancedRoute,
                          child: Text('Enhanced Route'),
                        ),
                        ElevatedButton(
                          onPressed: _getAlternativeRoutes,
                          child: Text('Alternatives'),
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
      SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text('Duration', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(route.duration?.toString() ?? 'N/A'),
            ],
          ),
          Column(
            children: [
              Text('Distance', style: TextStyle(fontWeight: FontWeight.bold)),
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
    Marker marker = Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  _addPolyLine(List<LatLng> coordinates, {Color color = Colors.green, String id = "poly"}) {
    PolylineId polylineId = PolylineId(id);
    Polyline polyline =
        Polyline(polylineId: polylineId, color: color, points: coordinates, width: 5);
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
      RoutesApiResponse response = await polylinePoints.getRouteBetweenCoordinatesV2(
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
          final coordinates =
              points.map((point) => LatLng(point.latitude, point.longitude)).toList();
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
      RoutesApiResponse response = await polylinePoints.getRouteBetweenCoordinatesV2(
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

  const TwoWheelerMapScreen({Key? key, required this.apiKey}) : super(key: key);

  @override
  _TwoWheelerMapScreenState createState() => _TwoWheelerMapScreenState();
}

class _TwoWheelerMapScreenState extends State<TwoWheelerMapScreen> {
  late GoogleMapController mapController;
  double _originLatitude = 6.5212402, _originLongitude = 3.3679965;
  double _destLatitude = 6.849660, _destLongitude = 3.648190;
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
    _addMarker(LatLng(_originLatitude, _originLongitude), "origin", BitmapDescriptor.defaultMarker);
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
            initialCameraPosition:
                CameraPosition(target: LatLng(_originLatitude, _originLongitude), zoom: 12),
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
              child: Center(
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
                  padding: EdgeInsets.all(16),
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
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.motorcycle, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Two-Wheeler Routing',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Optimized routing for motorcycles and scooters. This feature is exclusive to the Routes API.',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            title: Text('Avoid Highways', style: TextStyle(fontSize: 12)),
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
                            title: Text('Avoid Tolls', style: TextStyle(fontSize: 12)),
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
                    if (currentResponse != null && currentResponse!.routes.isNotEmpty)
                      ..._buildRouteInfo(),
                    SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _getTwoWheelerRoute,
                      icon: Icon(Icons.motorcycle),
                      label: Text('Get Two-Wheeler Route'),
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
      SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text('Duration', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(route.duration?.toString() ?? 'N/A'),
            ],
          ),
          Column(
            children: [
              Text('Distance', style: TextStyle(fontWeight: FontWeight.bold)),
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
    Marker marker = Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  _addPolyLine(List<LatLng> coordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline =
        Polyline(polylineId: id, color: Colors.orange, points: coordinates, width: 5);
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
      RoutesApiResponse response = await polylinePointsV2.getRouteBetweenCoordinatesV2(
        request: RequestConverter.createEnhancedRequest(
          origin: PointLatLng(_originLatitude, _originLongitude),
          destination: PointLatLng(_destLatitude, _destLongitude),
          travelMode: TravelMode.twoWheeler,
        )
      );

      setState(() {
        currentResponse = response;
      });

      if (response.routes.isNotEmpty) {
        final route = response.routes.first;
        if (route.polylinePoints != null) {
          final points = polylinePointsV2.convertToLegacyResult(response).points;
          final coordinates =
              points.map((point) => LatLng(point.latitude, point.longitude)).toList();
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
