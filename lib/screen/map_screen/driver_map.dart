// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_unnecessary_containers, sized_box_for_whitespace, unused_element, avoid_print, unnecessary_new, unused_local_variable, non_constant_identifier_names, prefer_final_fields, must_be_immutable, unnecessary_brace_in_string_interps
import 'dart:async';
import 'dart:convert';
import 'package:cartrackingapp/screen/profile_screen/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../ipconnect.dart';

class DriverMap extends StatefulWidget {
  String? car_id;
  String? user_id;
  DriverMap({Key? key, required this.car_id, required this.user_id})
      : super(key: key);

  @override
  State<DriverMap> createState() => _DriverMapState();
}

class _DriverMapState extends State<DriverMap> {
  GoogleMapController? mapController;
  Position? driverLocation;

  String? user_id;

  Set<Marker> _makers = {};
  // late BitmapDescriptor mapMaker;
  // void setCustomeMarker() async {
  //   mapMaker = await BitmapDescriptor.fromAssetImage(
  //       ImageConfiguration(), 'assets/images/peofile.jpg');
  // }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      _makers.add(
        Marker(
            markerId: MarkerId('id-1'),
            // icon: mapMaker,
            position: LatLng(13.7820, 100.6354),
            infoWindow: InfoWindow(title: 'hello', snippet: 'hello2')),
      );
    });
  }

  Future select_car_driver() async {
    var url = Uri.parse(
        'http://${ipconnect}/cartraking/get_car/select_car_driver.php');
    var response = await http.post(url, body: {
      "car_id": widget.car_id.toString(),
      "user_id": widget.user_id.toString(),
    });
    var data = json.decode(response.body);
    print(data.toString());
  }

  Future get_user_id() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = preferences.getString('user_id');
    });
    // print(user_id);
  }

  Future<Position?> _getLocation() async {
    driverLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    return driverLocation;
  }

  getDataRealTime() async {
    Timer.periodic(new Duration(seconds: 5), (timer) async {
      _getLocation();
      // print("latitude ${driverLocation!.latitude}");
      // print("longtitude ${driverLocation!.longitude}");
      insert_location();
      // timer.cancel(); //ถ้าต้องการให้หยุดทำงาน
    });
  }

  Future insert_location() async {
    var url = Uri.parse(
        'http://$ipconnect/cartraking/insert_location/insert_location.php');
    var response = await http.post(url, body: {
      "user_id": user_id.toString(),
      "car_id": widget.car_id.toString(),
      "lati": driverLocation!.latitude.toString(),
      "longti": driverLocation!.longitude.toString(),
    });
  }

  List dataList = [];
  Future get_data_user() async {
    final response = await http.get(Uri.parse(
        "http://$ipconnect/cartraking/login/get_data_user.php?user_id=$user_id"));
    var data = json.decode(response.body);

    setState(() {
      dataList = data;
    });
    //print(data);
  }

  @override
  void initState() {
    select_car_driver();
    get_user_id();
    getDataRealTime();

    //setCustomeMarker();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _getLocation(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            // print(driverLocation!.latitude);
            //  print(driverLocation!.longitude);
            return Stack(
              children: [
                GoogleMap(
                    markers: _makers,
                    zoomControlsEnabled: false,
                    mapType: MapType.normal,
                    myLocationButtonEnabled: false,
                    onMapCreated: _onMapCreated,
                    myLocationEnabled: true,
                    initialCameraPosition: CameraPosition(
                        zoom: 19,
                        target: LatLng(driverLocation!.latitude,
                            driverLocation!.longitude))),
                Positioned(
                  left: 20,
                  top: 75,
                  child: Container(
                    width: 355,
                    height: 60,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color.fromARGB(255, 133, 88, 148),
                              Color.fromARGB(255, 167, 110, 186)
                            ]),
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                        SizedBox(
                          width: 25,
                        ),
                        Text(
                          "รถคันที่ ${widget.car_id} ",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (BuildContext context) {
                              return ProFileScreen();
                            }));
                          },
                          child: Icon(
                            Icons.account_circle,
                            color: Colors.white,
                            size: 35,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Stack(
              children: [
                Positioned(
                  left: 20,
                  top: 80,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 1,
                              offset: Offset(3, 3), // Shadow position
                            ),
                          ],
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.arrow_back_ios_new),
                    ),
                  ),
                ),
                Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          mapController?.animateCamera(CameraUpdate.newLatLngZoom(
              LatLng(driverLocation!.latitude, driverLocation!.longitude), 20));
          // showDialog(
          //     context: context,
          //     builder: (context) {
          //       return AlertDialog(
          //         content: Container(
          //           height: 50,
          //           child: Column(
          //             children: [
          //               Text(userLocation!.latitude.toString()),
          //               Text(userLocation!.longitude.toString()),
          //             ],
          //           ),
          //         ),
          //       );
          //     });
        },
        child: Icon(Icons.near_me),
      ),
    );
  }
}
