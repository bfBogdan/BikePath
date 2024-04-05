import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:async';

class RideScreen extends StatefulWidget {
  @override
  _RideScreenState createState() => _RideScreenState();
}

class _RideScreenState extends State<RideScreen> {

  GoogleMapController? _mapController;
  final LatLng _center = const LatLng(45.521563, -122.677433); // Example: Portland, OR
  Timer? _timer;
  bool toggle = false;

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _getCurrentLocation() async {
    // Check permissions (if you haven't already)

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(position.latitude, position.longitude), 15.0) 
    );
  }

  Future<void> _callCloudFunction() async {
    try {
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('processUserData');
      final results = await callable.call({
        'name': 'Alice',
        'email': 'alice@example.com'
      });
      print(results.data); // Access the returned data
    } on FirebaseFunctionsException catch (e) {
      print('Caught exception: $e');
    } 
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      _callCloudFunction();
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [

          // device data
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
          
          // google map
          Expanded(
            child: Stack(
              children: [GoogleMap(
                onMapCreated: _onMapCreated,
                myLocationEnabled: true,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 17.0,
                ),
              ),
              // buttons to start/stop the ride
              Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        RawMaterialButton(
                          onPressed: () {
                            if(toggle) {
                              //startTimer();
                              print("Timer started");
                            } else {
                              //stopTimer();
                              print("Timer stopped");
                            }
                            setState(() {
                              // changing the icon
                              toggle = !toggle;
                            });
                          },
                          elevation: 2.0,
                          fillColor: Colors.white,
                          child: Icon(
                            toggle ? Icons.play_arrow :
                            Icons.pause,
                            size: 35.0,
                          ),
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        ),
                        RawMaterialButton(
                          onPressed: () {
                            // Add functionality for stop button
                            print("Stop button pressed");
                          },
                          elevation: 2.0,
                          fillColor: Colors.white,
                          child: Icon(
                            Icons.stop,
                            size: 35.0,
                          ),
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],),
          ),
        ],
      )
    );
  }
}