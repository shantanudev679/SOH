import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:soh_app/MapView.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  List<LatLng> destination = [LatLng(26.97, 75.65), LatLng(26.97, 75.65)];
  Position? currentPos;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: ListView.builder(
              itemCount: destination.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                    leading: const Icon(Icons.list),
                    trailing: TextButton(
                      child: Text(
                        "Map",
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () async {
                        Position position = await getLocation();
                        print(position);
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => MapView(
                                source: LatLng(
                                    position.latitude, position.longitude),
                                destination: destination[index]),
                          ),
                        );
                      },
                    ),
                    title: Text(currentPos == null
                        ? "Distance"
                        : calculateDistance(
                                    currentPos!.latitude,
                                    currentPos!.longitude,
                                    destination[index].latitude,
                                    destination[index].longitude)
                                .toString() +
                            "km"));
              }),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          currentPos = await getLocation();
          setState(() {});
        },
        label: const Text('Fetch Distance!'),
        icon: const Icon(Icons.directions_boat),
      ),
    );
  }

  Future<Position> getLocation() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return position;
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}
