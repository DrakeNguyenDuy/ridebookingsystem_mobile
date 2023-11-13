import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_progress/loading_progress.dart';
import 'package:location/location.dart';
import 'package:ride_booking_system/application/common.config.dart';
import 'package:ride_booking_system/application/google_service.dart';
import 'package:ride_booking_system/application/main_app_service.dart';
import 'package:ride_booking_system/core/constants/constants/color_constants.dart';
import 'package:ride_booking_system/core/constants/constants/dimension_constanst.dart';
import 'package:ride_booking_system/core/constants/variables.dart';
import 'package:ride_booking_system/core/style/main_style.dart';
import 'package:ride_booking_system/core/widgets/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  // static String routeName = "/home";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final FirebaseMessaging _messaging;
  final double zoom = 17.0;
  late GoogleMapController mapController;
  final Location _locationController = Location();
  GoogleService googleService = GoogleService();
  MainAppService mainAppService = MainAppService();
  String pick = "";
  String des = "";
  bool isOpen = false;

  Map<PolylineId, Polyline> polylinesMap = {};

  Map<String, dynamic> mapLocation = {};

  LatLng? _currentLocation;

  late LatLng pickLat;
  late LatLng desLat;

  List<String> list = <String>[];

  final Completer<GoogleMapController> _mapControllerCompleter =
      Completer<GoogleMapController>();

  void _onMapCreated(GoogleMapController controller) {
    // mapController = controller;
    _mapControllerCompleter.complete(controller);
  }

  @override
  void initState() {
    super.initState();
    getAllLocation();
    getLocation().then((_) => getPolyPoint()
        .then((coordinates) => {generatePolylineFromPoints(coordinates)}));
    registerNotification();
  }

  Future<void> getLocation() async {
    bool serviceEnable;
    PermissionStatus permissionGranted;
    serviceEnable = await _locationController.serviceEnabled();
    if (serviceEnable) {
      serviceEnable = await _locationController.requestService();
    } else {
      return;
    }
    permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.longitude != null &&
          currentLocation.latitude != null) {
        setState(() {
          _currentLocation =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          // cameraToPosition(_currentLocation);
        });
      }
    });
  }

  Future<List<LatLng>> getPolyPoint() async {
    List<LatLng> polyPointCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult polylineResult =
        await polylinePoints.getRouteBetweenCoordinates(
            CommonConfig.API_GOOGLE_KEY,
            PointLatLng(pickLat.latitude, pickLat.longitude),
            PointLatLng(desLat.latitude, desLat.longitude),
            travelMode: TravelMode.driving);
    if (polylineResult.points.isNotEmpty) {
      for (var element in polylineResult.points) {
        polyPointCoordinates.add(LatLng(element.latitude, element.longitude));
      }
    } else {
      print(polylineResult.errorMessage);
    }
    return polyPointCoordinates;
  }

  //move camera to new position by position search
  Future<void> cameraToPosition(LatLng newPosition) async {
    final GoogleMapController controller = await _mapControllerCompleter.future;
    CameraPosition newCameraPosition =
        CameraPosition(target: newPosition, zoom: zoom);
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(newCameraPosition),
    );
  }

  void generatePolylineFromPoints(List<LatLng> polylineCoordinates) async {
    PolylineId polylineId = PolylineId("d");
    Polyline polyline = Polyline(
        polylineId: polylineId,
        color: Colors.blue,
        points: polylineCoordinates,
        width: 8);
    setState(() {
      polylinesMap[polylineId] = polyline;
    });
  }

  void order(BuildContext context, String destination, String priceResult) {
    Widget okButton = TextButton(
      child: const Text("Đặt chuyến"),
      onPressed: () {
        Navigator.pop(context);
        requestRide(double.parse(priceResult));
      },
    );
    Widget okCancel = TextButton(
      child: const Text("Hủy"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return AlertDialog(
            title: const Text("Đặt xe"),
            content: Text("Địa điểm:$destination \nGía cước: $priceResult VND"),
            actions: [okCancel, okButton],
          );
        });
  }

  //get price by distance
  void _getPrice() async {
    if (des.isEmpty || pick.isEmpty) {
      Fluttertoast.showToast(
          msg: "Điểm đến và điểm đi không được trống", webPosition: "top");
      return;
    }
    LoadingProgress.start(context);
    double latidudePick = mapLocation[pick]["latitude"];
    double longtidudePick = mapLocation[pick]["longtitude"];
    double latidudeDes = mapLocation[des]["latitude"];
    double longtidudeDes = mapLocation[des]["longtitude"];
    double distance = 0;
    googleService
        .getDistance(latidudePick, longtidudePick, latidudeDes, longtidudeDes)
        .then((res1) async {
      print(res1);
      if (res1.statusCode == 200) {
        final body = jsonDecode(res1.body);
        distance = body["rows"]["elements"]["distance"]["value"] / 1000;
      }
    });
    distance = distance == 0 ? 4.4 : distance;
    mainAppService.getPrice(distance).then((res2) async {
      if (res2.statusCode == HttpStatus.ok) {
        final body = jsonDecode(res2.body);
        String priceTemp = body["data"];
        LoadingProgress.stop(context);
        order(context, des, priceTemp);
      }
    });
  }

  void getAllLocation() async {
    mainAppService.getAllLocation().then((res) async {
      if (res.statusCode == HttpStatus.ok) {
        final body = jsonDecode(res.body);
        List<dynamic> locations = body["data"];
        List<String> temp = [];
        Map<String, dynamic> tempMap = {};
        for (var i = 0; i < locations.length; i++) {
          temp.add(locations.elementAt(i)["name"]);
          tempMap[locations.elementAt(i)["name"]] = locations.elementAt(i);
        }
        setState(() {
          list = temp;
          mapLocation = tempMap;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      checkerboardOffscreenLayers: false,
      home: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
        floatingActionButton: Column(
          children: [
            SearchAnchor(
              builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  hintText: "Điêm đi",
                  controller: controller,
                  padding: const MaterialStatePropertyAll<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 16.0)),
                  onTap: () {
                    controller.openView();
                    // setState(() {
                    //   isOpen = !isOpen;
                    // });
                  },
                  onChanged: (_) {
                    controller.openView();
                  },
                  leading: const Icon(Icons.search),
                );
              },
              suggestionsBuilder:
                  (BuildContext context, SearchController controller) {
                return list.map((e) => ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(e),
                      onTap: () {
                        setState(() {
                          controller.closeView(e);
                          pick = e;
                        });
                      },
                    ));
              },
            ),
            Visibility(
              // visible: isOpen,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.arrow_downward, color: ColorPalette.primaryColor),
                  Icon(
                    Icons.arrow_downward,
                    color: ColorPalette.primaryColor,
                  )
                ],
              ),
            ),
            Visibility(
              // visible: isOpen,
              child: SearchAnchor(
                builder: (BuildContext context, SearchController controller) {
                  return SearchBar(
                    hintText: "Điểm đến",
                    controller: controller,
                    padding: const MaterialStatePropertyAll<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 16.0)),
                    onTap: () {
                      controller.openView();
                    },
                    onChanged: (_) {
                      controller.openView();
                    },
                    leading: const Icon(Icons.search),
                  );
                },
                suggestionsBuilder:
                    (BuildContext context, SearchController controller) {
                  return list.map((e) => ListTile(
                        leading: const Icon(Icons.location_on),
                        title: Text(e),
                        onTap: () {
                          setState(() {
                            des = e;
                            controller.closeView(e);
                          });
                        },
                      ));
                },
              ),
            ),
            Visibility(
              // visible: isOpen,
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 18,
                  margin: const EdgeInsets.fromLTRB(ds_1, ds_2 * 2, ds_1, ds_1),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.primaryColor,

                      // padding: const EdgeInsets.all(15.0),
                    ),
                    onPressed: _getPrice,
                    child: Text(
                      "Đặt chuyến",
                      style: MainStyle.textStyle5,
                    ),
                  )),
            )
          ],
        ),
        body: _currentLocation == null
            ? const LoadingWidget()
            : GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _currentLocation!,
                  zoom: zoom,
                ),
                // markers: pickLat!=null && desLat!=null  {
                //   Marker(
                //     markerId: const MarkerId("location2"),
                //     position: pickLat,
                //     icon: BitmapDescriptor.defaultMarker,
                //   ),
                //   Marker(
                //     markerId: const MarkerId("location1"),
                //     position: desLat,
                //     icon: BitmapDescriptor.defaultMarkerWithHue(2),
                //   ),
                // },
                polylines: Set<Polyline>.of(polylinesMap.values),
              ),
      ),
    );
  }

  void registerNotification() async {
    await Firebase.initializeApp();
    // 2. Instantiate Firebase Messaging
    _messaging = FirebaseMessaging.instance;
    _messaging.getToken().then((value) async {
      await SharedPreferences.getInstance().then((ins) {
        ins.setString(Varibales.TOKEN_FIREBASE, value!);
      });
    });
  }

  void requestRide(double price) async {
    double latidudePick = mapLocation[pick]["latitude"];
    double longtidudePick = mapLocation[pick]["longtitude"];
    double latidudeDes = mapLocation[des]["latitude"];
    double longtidudeDes = mapLocation[des]["longtitude"];
    final SharedPreferences sp = await SharedPreferences.getInstance();
    String? firebaseToken = sp.getString(Varibales.TOKEN_FIREBASE);
    int? customerId = sp.getInt(Varibales.CUSTOMER_ID);
    mainAppService
        .requestRide(latidudePick, longtidudePick, latidudeDes, longtidudeDes,
            price, "Làm ơn đến sớm", customerId!, firebaseToken!)
        .then((res) async {
      if (res.statusCode == HttpStatus.ok) {
        final body = jsonDecode(res.body);
      }
    });
  }
}
