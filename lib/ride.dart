import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:io';
import 'dart:isolate';

class RideScreen extends StatefulWidget {
  @override
  _RideScreenState createState() => _RideScreenState();
}

class _RideScreenState extends State<RideScreen> {
  Position position1 = Position(latitude: 0, longitude: 0, timestamp: DateTime.now(), accuracy: 0, altitude: 0, 
                                heading: 0, speed: 0, speedAccuracy: 0, floor: 0, isMocked: false, altitudeAccuracy: 0, headingAccuracy: 0);

  bool firstRun = true;
  List accZ = [];

  GoogleMapController? _mapController;
  final LatLng _center = const LatLng(45.521563, -122.677433); // Example: Portland, OR
  Position startingPosition = Position(longitude: 0.0, latitude: 0.0, timestamp: DateTime.now(), accuracy: 0, altitude: 0, altitudeAccuracy: 0, heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0);
  Position currentPosition = Position(longitude: 0.0, latitude: 0.0, timestamp: DateTime.now(), accuracy: 0, altitude: 0, altitudeAccuracy: 0, heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0);
  double distance = 0.0;
  double speed=0.0;
  Timer? _timer;
  bool toggle = false;
  int seconds = 0;
  String digitSeconds = '00';
  Timer? timer;
  bool started = false;
  late Future<List> dataList;


  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<Position> _getCurrentLocation() async {
    currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(currentPosition.latitude, currentPosition.longitude), 15.0) 
    );
    return currentPosition;
  }

  double _getDistance() {
    distance = Geolocator.distanceBetween(startingPosition.latitude, startingPosition.longitude, currentPosition.latitude, currentPosition.longitude);
    return distance;
  }

  double _getSpeed() {
    speed = currentPosition.speed;
    return speed;
  }

  void startTracking() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if(firstRun) {
        position1 = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        firstRun = false;
      }
      else{
        double qIndex = 0;
        for(int i = 0; i < accZ.length; i++) {
          qIndex += accZ[i];
        }
        qIndex = qIndex / accZ.length;
        Position position2 = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        _sendDataToFirestore(position1, position2, qIndex);
        position1 = position2;
        accZ = [];
      }
      _getCurrentLocation(); // TODO: nu functioneste
      _getDistance(); // TODO: nu functioneste
      _getSpeed(); // TODO: nu functioneste
    });
  }

  void stopTracking() {
    _timer?.cancel();
  }

  Future<List> fetchDataFromFirestore() async {
    // Reference the Firestore collection
    CollectionReference collectionRef = FirebaseFirestore.instance.collection("actual");

    // Get a snapshot of the documents
    QuerySnapshot querySnapshot = await collectionRef.get();

    // Convert the documents to a list of maps 
    List<Map<String, dynamic>>? dataList = (querySnapshot.docs.map((doc) => doc.data()).toList() ?? []).cast<Map<String, dynamic>>();

    print(dataList);

    drawLines(dataList);

    return dataList;
  }
 
 void _sendDataToFirestore(Position position1, Position position2, double qIndex) {
    CollectionReference collectionRef = FirebaseFirestore.instance.collection("pre-check");
      // Call the user's CollectionReference to add a new user
      print("Pachet: " + qIndex.toString());
     collectionRef.add({
            'lat': position1.latitude,
            'lng': position1.longitude,
            'lat2': position2.latitude,
            'lng2': position2.longitude,
            'qIndex': qIndex
          })
          .then((value) => print("Data Added"))
          .catchError((error) => print("Failed to add data: $error"));
 }

  final Set<Polyline> _polylines = {};
  void drawLines(List<Map<String, dynamic>> dataList) {
    List<LatLng> points = [];
    print("0->");
    for (var i = 0; i < dataList.length; i++) {
      points.add(LatLng(dataList[i]['lat'] ?? 0, dataList[i]['lng'] ?? 0));
      points.add(LatLng(dataList[i]['lat2'] ?? 0, dataList[i]['lng2'] ?? 0));
    }
    print(points);
    Color color = Colors.green;
    for (int i = 0; i < points.length-1; i+=2) {
      if(dataList[(i / 2).toInt()]['qIndex'] > 5 && dataList[(i / 2).toInt()]['qIndex'] < 7) color = Colors.orange;
      else if(dataList[(i / 2).toInt()]['qIndex'] >= 7) color = Colors.red;
      else color = Colors.green;
      final PolylineId polylineId = PolylineId(i.toString());
      final Polyline polyline = Polyline(
        polylineId: polylineId,
        points: [points[i], points[i+1]],
        color: color,
        width: 4,
      );

      _polylines.add(polyline);
      }
      print(_polylines);
  }

  //Stop timer function
  void stopCronometer() {
    timer!.cancel();
    setState(() {
      started = false;
    });
  }

  //Reset timer function
  void resetCronometer() {
    timer!.cancel();
    setState(() {
      started = false;
      seconds = 0;
      digitSeconds = '00';
    });
  }

  //Start timer function
  void startCronometer(){
    started=true;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      int localSeconds = seconds + 1;
      setState(() {
        seconds = localSeconds;
        digitSeconds = (localSeconds >= 10) ? "$localSeconds" : "0$localSeconds"; // corrected the formatting for seconds
      });
    });
  }

  @override
  void initState() {
    super.initState();
    dataList = fetchDataFromFirestore();
    distance = _getDistance();
    _getCurrentLocation();
    startTracking();
    startCronometer();
    userAccelerometerEventStream().listen(
      (UserAccelerometerEvent event) {
        accZ.add(event.z);
      }
    );
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(),
            body: FutureBuilder(
      future: dataList, 
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Show loading spinner while waiting
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Show error if any
        } else {
          return Column(
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
                            StreamBuilder<double>(
                              stream: Stream.value(_getSpeed()), // Replace null with your actual stream
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  double? speed = snapshot.data; // Replace with the actual speed value from the stream
                                  return Text('$speed m/s');
                                } else {
                                  return Text('Loading...'); // Show loading indicator while waiting for data
                                }
                              }
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text('Distance', style: TextStyle(fontWeight: FontWeight.bold)),
                            StreamBuilder<dynamic>(
                              stream: Stream.value(_getDistance()), // Replace null with your actual stream
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text('${snapshot.data} m');
                                } else if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Text('Loading...'); // Show loading indicator while waiting for data
                                }
                                return Container(); // Add a return statement at the end
                              },
                            
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text('Time', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              started ? '$digitSeconds s' : '$seconds s', // Show updated seconds only if timer started
                              style: TextStyle(fontWeight: FontWeight.bold)
                            ),
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
                          target: currentPosition != null ? LatLng(currentPosition.latitude, currentPosition.longitude) : _center,
                          zoom: 17.0,
                        ),
                        polylines: _polylines,
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
                                      print("Timer started");
                                      startCronometer();
                                      startTracking();
                                    } else {
                                      print("Timer stopped");
                                      stopCronometer();
                                      stopTracking();
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
                                    resetCronometer();
                                    stopTracking();
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
              );
        }
      },
              ),
          );
        }
      }