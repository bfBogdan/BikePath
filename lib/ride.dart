import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideScreen extends StatefulWidget {
  @override
  _RideScreenState createState() => _RideScreenState();
}

class _RideScreenState extends State<RideScreen> {

  GoogleMapController? _mapController;
  final LatLng _center = const LatLng(45.521563, -122.677433); // Example: Portland, OR

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text('Speed', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('0 km/h'), // Replace with actual speed
                  ],
                ),
                Column(
                  children: [
                    Text('Distance', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('0 km'), // Replace with actual distance
                  ],
                ),
                Column(
                  children: [
                    Text('Time', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('0 min'), // Replace with actual time
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}