import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  GoogleMapController? _mapController;
  final LatLng _center = const LatLng(45.521563, -122.677433); // Example: Portland, OR
  Position currentPosition = Position(
    longitude: 0.0,
    latitude: 0.0,
    timestamp: DateTime.now(),
    accuracy: 0,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
  double _distance = 0.0;
  double _currentSpeed = 0.0;
  bool _tracking = false;
  Timer? timer;
  bool started = false;
  int seconds = 0;
  String digitSeconds = '00';
  late Future<List> dataList;
  static const OPENWEATHER_API_KEY = '854190768a121f80c54f46909cca4864';
  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);
  Weather? weather;

  Position? _startPosition;
  StreamSubscription<Position>? _positionStreamSubscription;

  final Set<Polyline> _polylines = {};
  List accZ = [];

  @override
  void initState() {
    super.initState();
    dataList = fetchDataFromFirestore();
    _getCurrentLocation();
    startCronometer();
    _startTracking();
    userAccelerometerEventStream().listen((UserAccelerometerEvent event) {
      accZ.add(event.z);
    });
    _wf.currentWeatherByLocation(currentPosition.latitude, currentPosition.longitude).then((w) {
      setState(() {
        weather = w;
      });
    });
  }

  Future<Position> _getCurrentLocation() async {
    currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(currentPosition.latitude, currentPosition.longitude), 15.0),
    );
    return currentPosition;
  }

  void _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    String mapStyle = await rootBundle.loadString('lib/assets/map_style.json');
    controller.setMapStyle(mapStyle);
  }

  void _startTracking() {
    setState(() {
      _tracking = true;
      _distance = 0.0;
      _currentSpeed = 0.0;
    });

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // meters
      ),
    ).listen((Position position) {
      setState(() {
        if (_startPosition == null) {
          _startPosition = position;
        } else {
          _distance += Geolocator.distanceBetween(
            _startPosition!.latitude,
            _startPosition!.longitude,
            position.latitude,
            position.longitude,
          );
          _startPosition = position;
        }
        _currentSpeed = position.speed; // Speed in meters/second
      });
    });
  }

  void _stopTracking() {
    _positionStreamSubscription?.cancel();
    setState(() {
      _tracking = false;
      _startPosition = null;
      _currentSpeed = 0.0;
      timer?.cancel();
    });
  }

  Future<List> fetchDataFromFirestore() async {
    CollectionReference collectionRef = FirebaseFirestore.instance.collection("actual");
    QuerySnapshot querySnapshot = await collectionRef.get();
    List<Map<String, dynamic>> dataList = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    drawLines(dataList);
    return dataList;
  }

  void _sendDataToFirestore(Position position1, Position position2, double qIndex) {
    CollectionReference collectionRef = FirebaseFirestore.instance.collection("pre-check");
    collectionRef.add({
      'lat': position1.latitude,
      'lng': position1.longitude,
      'lat2': position2.latitude,
      'lng2': position2.longitude,
      'qIndex': qIndex,
    }).then((value) => print("Data Added")).catchError((error) => print("Failed to add data: $error"));
  }

  void drawLines(List<Map<String, dynamic>> dataList) {
    List<LatLng> points = [];
    for (var data in dataList) {
      points.add(LatLng(data['lat'], data['lng']));
      points.add(LatLng(data['lat2'], data['lng2']));
    }
    Color color = Colors.green;
    for (int i = 0; i < points.length - 1; i += 2) {
      if (dataList[i ~/ 2]['qIndex'] < -60 && dataList[i ~/ 2]['qIndex'] > -100) {
        color = Colors.orange;
      } else if (dataList[i ~/ 2]['qIndex'] <= -100) {
        color = Colors.red;
      }
      final PolylineId polylineId = PolylineId(i.toString());
      final Polyline polyline = Polyline(
        polylineId: polylineId,
        points: [points[i], points[i + 1]],
        color: color,
        width: 4,
      );
      _polylines.add(polyline);
    }
  }

  void startCronometer() {
    started = true;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        seconds++;
        digitSeconds = (seconds >= 10) ? "$seconds" : "0$seconds";
      });
    });
  }

  void stopCronometer() {
    timer?.cancel();
    setState(() {
      started = false;
    });
  }

  void resetCronometer() {
    timer?.cancel();
    setState(() {
      started = false;
      seconds = 0;
      digitSeconds = '00';
    });
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    timer?.cancel();
    super.dispose();
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
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      ClipRRect(
                        child: GoogleMap(
                          onMapCreated: _onMapCreated,
                          myLocationEnabled: true,
                          minMaxZoomPreference: const MinMaxZoomPreference(0, 25),
                          initialCameraPosition: CameraPosition(
                            target: currentPosition.latitude != 0.0 && currentPosition.longitude != 0.0
                                ? LatLng(currentPosition.latitude, currentPosition.longitude)
                                : _center,
                            zoom: 19.0,
                          ),
                          polylines: _polylines,
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            RawMaterialButton(
                              onPressed: () {
                                if (_tracking) {
                                  stopCronometer();
                                  _stopTracking();
                                } else {
                                  startCronometer();
                                  _startTracking();
                                }
                                setState(() {
                                  _tracking = !_tracking;
                                });
                              },
                              elevation: 2.0,
                              fillColor: Colors.white,
                              padding: const EdgeInsets.all(15.0),
                              shape: const CircleBorder(),
                              child: Icon(
                                _tracking ? Icons.pause : Icons.play_arrow,
                                size: 35.0,
                              ),
                            ),
                            RawMaterialButton(
                              onPressed: () {
                                resetCronometer();
                                _stopTracking();
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
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 29, 29, 29),
                  ),
                  padding: const EdgeInsets.all(10),
                  height: 200,
                  child: Column(
                    children: [
                      _buildInfoRow(Icons.speed, 'Speed', '${_currentSpeed.toStringAsFixed(2)} m/s'),
                      const SizedBox(height: 10),
                      _buildInfoRow(Icons.directions_bike, 'Distance', '${_distance.toStringAsFixed(2)} m'),
                      const SizedBox(height: 10),
                      _buildInfoRow(Icons.timer, 'Time', started ? '$digitSeconds s' : '$seconds s'),
                      const SizedBox(height: 10),
                      _buildInfoRow(Icons.thermostat, 'Temperature', "${weather?.temperature?.celsius?.toStringAsFixed(0)} °C"),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Robot',
                fontSize: 20,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Robot',
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
