# flutter_polyline_points
A flutter plugin that decodes encoded google polyline string into list of geo-coordinates suitable for showing route/polyline on maps

<div style="text-align: center"><table><tr>
  <td style="text-align: center">
  <a href="https://raw.githubusercontent.com/Dammyololade/flutter_polyline_points/master/poly.jpeg">
    <img src="https://raw.githubusercontent.com/Dammyololade/flutter_polyline_points/master/poly.jpeg" width="200"/></a>
</td>
</tr></table></div>

## Getting Started
This package contains functions to decode google encoded polyline string which returns a list of co-ordinates
indicating route between two geographical position

## Usage
To use this package, add flutter_polyline_points as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/packages-and-plugins/using-packages).

## Import the package
```dart
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
```

## First method
Get the list of points by Geo-coordinate, this return an instance of PolylineResult, which
contains the status of the api, the errorMessage, and the list of decoded points.
```dart
PolylinePoints polylinePoints = PolylinePoints();
PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(googleAPiKey,
        _originLatitude, _originLongitude, _destLatitude, _destLongitude);
print(result.points);
```

## Second method
Decode an encoded google polyline string e.g _p~iF~ps|U_ulLnnqC_mqNvxq`@
```dart
List<PointLatLng> result = polylinePoints.decodePolyline("_p~iF~ps|U_ulLnnqC_mqNvxq`@");
print(result);
``` 

See the example directory for a complete sample app

## Hint
kindly ensure you use a valid google api key,  
[If you need help generating api key for your project click this link](https://developers.google.com/maps/documentation/directions/get-api-key)
