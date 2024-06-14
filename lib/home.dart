import 'dart:ui';
import 'package:bikepath/map.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:bikepath/ride.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 53, 53, 53),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15, left: 10, right: 10, bottom: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset('lib/assets/logo_long_white.png', height: 60,),
                        // const Text('Welcome back', style: TextStyle(fontSize: 17, color: Colors.white),),
                        // const Text('Claudiu Spiescu', style: TextStyle(fontSize: 23, color: Colors.white),),
                      ],
                    ),
                    Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 29, 29, 29),
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.person, color: Colors.white, size: 30,),
                      ],
                  ),
                ),
              ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15, top: 10, right: 15, bottom: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Start a ride', style: TextStyle(color: Colors.white, fontSize: 35),),
                    ),
                    const SizedBox(height: 10,),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RideScreen()),
                        );
                      },
                      child: Container(
                        height: 150,
                        padding: EdgeInsets.only(bottom: 5),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('lib/assets/bike.jpg'),
                            fit: BoxFit.cover,
                          ),
                          color: Colors.green,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 250,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.pedal_bike, color: Colors.white, size: 35,),
                                const SizedBox(width: 10,),
                                Text('Press to start', style: TextStyle(color: Colors.white, fontSize: 30),),
                              ],
                            ),
                          ),
                        ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15, top: 20, right: 15, bottom: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Points of interest', style: TextStyle(color: Colors.white, fontSize: 35),),
                    ),
                    const SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: AssetImage('lib/assets/iulius-town.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          height: 210,
                          width: MediaQuery.of(context).size.width * 0.45,
                          child: Align(alignment: Alignment.bottomCenter, child: Container(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Text('Iulius Town', style: TextStyle(color: Colors.white, fontSize: 27),))),
                        ),
                        Column(
                          children: [
                            Container(
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                image: DecorationImage(
                                  image: AssetImage('lib/assets/unirii.jpg'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              height: 100,
                              width: MediaQuery.of(context).size.width * 0.45,
                              child: Align(alignment: Alignment.bottomCenter, child: Container(
                                padding: EdgeInsets.only(left: 10, right: 10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                ),
                                child: Text('Unirii Square', style: TextStyle(color: Colors.white, fontSize: 23),))),
                            ),
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                image: DecorationImage(
                                  image: AssetImage('lib/assets/padurice.jpg'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              width: MediaQuery.of(context).size.width * 0.45,
                              height: 100,
                              child: ClipRRect(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                                  child: Align(alignment: Alignment.center, child: Text('Show more',  style: TextStyle(color: Colors.white, fontSize: 27),))),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
              ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15, top: 20, right: 15, bottom: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('View the map', style: TextStyle(color: Colors.white, fontSize: 35),),
                    ),
                    const SizedBox(height: 10,),
                    InkWell(
                      onTap:() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MapPage()),
                        );
                      },
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          image: new DecorationImage(
                            image: new ExactAssetImage('lib/assets/map.png'),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                            child: Align(alignment: Alignment.center, child: Text('Open the map', style: TextStyle(color: Colors.white, fontSize: 30),)))),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15, top: 20, right: 15, bottom: 20),
                child: Column(
                  children: [
                    Text('BikePath is a project developed by', style: TextStyle(color: Colors.white, fontSize: 15),),
                    const SizedBox(height: 10,),
                    Image.asset('lib/assets/redevo_logo_white.png', height: 50,),
                  ],
                ),
              ),
            ],
                      ),
        ),
    ),
    );
  }
}