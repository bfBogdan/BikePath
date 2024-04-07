import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:weather/weather.dart';

class RideScreen extends StatefulWidget {
  const RideScreen({super.key});

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
  int distance = 0;
  int speed = 0;
  Timer? _timer;
  bool toggle = false;
  int seconds = 0;
  String digitSeconds = '00';
  Timer? timer;
  bool started = false;
  late Future<List> dataList;
  int traveledDistance = 0;
  static const OPENWEATHER_API_KEY='854190768a121f80c54f46909cca4864';
  final WeatherFactory _wf=WeatherFactory(OPENWEATHER_API_KEY);
  Weather? weather;


  void _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    String mapStyle = await getMapStyle();
    controller.setMapStyle(mapStyle);
  }

  Future<String> getMapStyle() async {
    return await rootBundle.loadString('lib/assets/map_style.json');
  }

  Future<Position> _getCurrentLocation() async {
    currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(currentPosition.latitude, currentPosition.longitude), 15.0) 
    );
    return currentPosition;
  }

  int _getDistance() {
    traveledDistance = Geolocator.distanceBetween(startingPosition.latitude, startingPosition.longitude, currentPosition.latitude, currentPosition.longitude).toInt();
    return distance.toInt();
  }

  int _getSpeed() {
    speed = currentPosition.speed.toInt();
    return speed.toInt();
  }

  void startTracking() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if(firstRun) {
        position1 = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        startingPosition = position1;
        firstRun = false;
      }
      else{
        _getDistance();
        double qIndex = accZ[0];
        for(int i = 1; i < accZ.length; i++) {
          qIndex -= (accZ[i]).abs();
        }
        Position position2 = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        _sendDataToFirestore(position1, position2, qIndex);
        position1 = position2;
        accZ = [];
      }
      _getCurrentLocation();
      _getSpeed();
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
      print("Pachet: $qIndex");
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
      if(dataList[i ~/ 2]['qIndex'] < -1 && dataList[i ~/ 2]['qIndex'] > -2) {
        color = Colors.orange;
      } else if(dataList[i ~/ 2]['qIndex'] <= -2) color = Colors.red;
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
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    _getCurrentLocation();
    startTracking();
    startCronometer();
    userAccelerometerEventStream().listen(
      (UserAccelerometerEvent event) {
        accZ.add(event.z);
      }
    );
    _wf.currentWeatherByLocation(currentPosition.latitude, currentPosition.longitude).then((w) {
      setState((){
      weather = w;
      });
    });
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 53, 53, 53),
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 29, 29, 29),
              iconTheme: IconThemeData(color: Colors.white),
              centerTitle: true,
              title: Image.asset('lib/assets/logo_long_white.png', width: 200),
            ),
            body: FutureBuilder(
      future: dataList, 
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Show loading spinner while waiting
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Show error if any
        } else {
          return Column(
                children: [
                  // device data
                  Container(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 29, 29, 29),
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            const Text('Speed', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            StreamBuilder<int>(
                              stream: Stream.value(_getSpeed()), // Replace null with your actual stream
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  int? speed = snapshot.data; // Replace with the actual speed value from the stream
                                  return Text('$speed m/s', style: const TextStyle(color: Colors.white));
                                } else {
                                  return const Text('-'); // Show loading indicator while waiting for data
                                }
                              }
                            ),
                          ],
                        ),
                        Container(
                          height: 35,
                          width: 2,
                          color: Colors.white24,
                        ),
                        Column(
                          children: [
                            const Text('Distance', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            StreamBuilder<dynamic>(
                              stream: Stream.value(_getDistance()), // Replace null with your actual stream
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text('${snapshot.data} m', style: const TextStyle(color: Colors.white));
                                } else if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Text('-'); // Show loading indicator while waiting for data
                                }
                                return Container(); // Add a return statement at the end
                              },
                            
                            ),
                          ],
                        ),
                        Container(
                          height: 35,
                          width: 2,
                          color: Colors.white24,
                        ),
                        Column(
                          children: [
                            const Text('Time', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            Text(
                              started ? '$digitSeconds s' : '$seconds s', // Show updated seconds only if timer started
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                        Container(
                          height: 35,
                          width: 2,
                          color: Colors.white24,
                        ),
                        Column(children: [
                          const Text('Temperature', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          Text("${weather?.temperature?.celsius?.toStringAsFixed(0)} °C", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),],
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 5,),
                  // google map
                  Expanded(
                    child: Stack(
                      children: [ClipRRect(
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                        child: GoogleMap(
                          onMapCreated: _onMapCreated,
                          myLocationEnabled: true,
                          minMaxZoomPreference: const MinMaxZoomPreference(0, 25),
                          initialCameraPosition: CameraPosition(
                            target: currentPosition != null ? LatLng(currentPosition.latitude, currentPosition.longitude) : _center,
                            zoom: 19.0,
                          ),
                          polylines: _polylines,
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
                                  padding: const EdgeInsets.all(15.0),
                                  shape: const CircleBorder(),
                                  child: Icon(
                                    toggle ? Icons.play_arrow :
                                    Icons.pause,
                                    size: 35.0,
                                  ),
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
                                  padding: const EdgeInsets.all(15.0),
                                  shape: const CircleBorder(),
                                  child: const Icon(
                                    Icons.stop,
                                    size: 35.0,
                                  ),
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