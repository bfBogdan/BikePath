import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bikepath/ride.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Position currentPosition = Position(longitude: 0.0, latitude: 0.0, timestamp: DateTime.now(), accuracy: 0, altitude: 0, altitudeAccuracy: 0, heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0);  

  GoogleMapController? _mapController;
  final LatLng _center = const LatLng(45.521563, -122.677433); // Example: Portland, OR

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      // Permission granted - proceed
    } else {
      // Handle permission denial 
    }
  }

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _getCurrentLocation();
    //getData();
  }

  Future<void> fetchDataFromFirestore() async {
    // Reference the Firestore collection
    CollectionReference collectionRef = FirebaseFirestore.instance.collection("actual");

    // Get a snapshot of the documents
    QuerySnapshot querySnapshot = await collectionRef.get();

    // Convert the documents to a list of maps 
    List<Map<String, dynamic>>? dataList = (querySnapshot.docs.map((doc) => doc.data()).toList() ?? []).cast<Map<String, dynamic>>();

    print(dataList);

    drawLines(dataList);
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
      if(dataList[i ~/ 2]['qIndex'] > 5 && dataList[i ~/ 2]['qIndex'] < 7) {
        color = Colors.orange;
      } else if(dataList[i ~/ 2]['qIndex'] >= 7) color = Colors.red;
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchDataFromFirestore(), // Assuming this is the function you want to wait for
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Show loading spinner while waiting
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Show error if any
        } else {
          return SafeArea(
            child: Scaffold(
              backgroundColor: const Color.fromARGB(255, 53, 53, 53),
              body: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 109,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 29, 29, 29),
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Image.asset('lib/assets/logo_long_white.png', width: 200),
                          ),
                          const Text('Welcome back, Claudiu!', style: TextStyle(fontSize: 25, color: Colors.white),),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5,),
                  Expanded(
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                          child: GoogleMap(
                            onMapCreated: _onMapCreated,
                            myLocationEnabled: true,
                            initialCameraPosition: CameraPosition(
                              target: currentPosition != null ? LatLng(currentPosition.latitude, currentPosition.longitude) : _center,
                              zoom: 11.0,
                            ),
                            polylines: _polylines,
                          ),
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              bottom: 20,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const RideScreen()),
                                  );
                                },
                                child: Container(
                                  width: 120,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.pedal_bike, color: Colors.white,),
                                      SizedBox(width: 5,),
                                      Text('Start a ride', style: TextStyle(color: Colors.white),),
                                    ],
                                  ),
                                ),
                              )
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                ],
              ),
            ),
          );
        }
      },
    );
  }
}