import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatefulWidget {
  final LatLng source;
  final LatLng destination;
  const MapView({Key? key, required this.source, required this.destination})
      : super(key: key);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  Completer<GoogleMapController> _controller = Completer();

  List<Marker> _markers = <Marker>[];

  // Object for PolylinePoints
  late PolylinePoints polylinePoints;

  // List of coordinates to join
  List<LatLng> polylineCoordinates = [];

  // Map storing polylines created by connecting two points
  Map<PolylineId, Polyline> polylines = {};

  // Create the polylines for showing the route between two places

  _createPolylines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyBkUtbijALdJYONHxoUnXsLgK8gneUM-xc", // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.transit,
    );

    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    } else {
      print("hello");
    }

    // Defining an ID
    PolylineId id = const PolylineId('poly');

    // Initializing Polyline
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );

    // Adding the polyline to the map
    polylines[id] = polyline;
  }

  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.4444, -122.084801),
    zoom: 14.4746,
  );

  @override
  void initState() {
    _kGooglePlex = CameraPosition(
      target: widget.source,
      zoom: 14.4746,
    );
    _markers.add(
      Marker(
        markerId: MarkerId('1'),
        position: widget.source,
        infoWindow: InfoWindow(title: 'Source'),
      ),
    );
    _markers.add(
      Marker(
        markerId: MarkerId('2'),
        position: widget.destination,
        infoWindow: InfoWindow(title: 'Destination'),
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: Set<Marker>.of(_markers),
        polylines: Set<Polyline>.of(polylines.values),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: const Text('Create Route!'),
        icon: const Icon(Icons.directions_boat),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    _createPolylines(widget.source.latitude, widget.source.longitude,
        widget.destination.latitude, widget.destination.longitude);
    setState(() {});
  }
}
