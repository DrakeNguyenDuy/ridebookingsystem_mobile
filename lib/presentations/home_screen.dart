import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:ride_booking_system/application/common.config.dart';
import 'package:ride_booking_system/application/google_service.dart';
import 'package:ride_booking_system/application/main_app_service.dart';
import 'package:ride_booking_system/core/constants/variables.dart';
import 'package:ride_booking_system/core/widgets/loading.dart';
import 'package:ride_booking_system/data/model/personal.dart';
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
  double price = 0;
  late GoogleMapController mapController;
  final Location _locationController = Location();
  GoogleService googleService = GoogleService();
  MainAppService mainAppService = MainAppService();

  Map<PolylineId, Polyline> polylinesMap = {};

  LatLng? _currentLocation;

  LatLng l1 = LatLng(10.868, 106.751);
  LatLng l2 = LatLng(10.878, 106.757);

  final Completer<GoogleMapController> _mapControllerCompleter =
      Completer<GoogleMapController>();

  void _onMapCreated(GoogleMapController controller) {
    // mapController = controller;
    _mapControllerCompleter.complete(controller);
  }

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance?.addPostFrameCallback((_) {
    //   _getPrice();
    //   order(this.context);
    // });
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
          cameraToPosition(l1);
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
            PointLatLng(l1.latitude, l1.longitude),
            PointLatLng(l2.latitude, l2.longitude),
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

  void order(BuildContext context) async {
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.pop(context);
        requestRide();
      },
    );
    Widget okCancel = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    _getPrice();
    showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return AlertDialog(
            title: const Text("Đặt xe"),
            content: Text("Gía cước: $price"),
            actions: [okCancel, okButton],
          );
        });
  }

  //get price by distance
  void _getPrice() async {
    // googleService
    //     .getDistance(l1.latitude, l1.longitude, l2.latitude, l2.longitude)
    //     .then((res1) async {
    //   print(res1);
    //   if (res1.statusCode == 200) {
    //     final body = jsonDecode(res1.body);
    //     double destination =
    //         body["rows"]["elements"]["distance"]["value"] / 1000;
    //     print(destination);
    //   }
    // });
    mainAppService.getPrice(4.4).then((res2) async {
      if (res2.statusCode == HttpStatus.ok) {
        final body = jsonDecode(res2.body);
        setState(() {
          price = body["data"];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green[700],
      ),
      home: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            order(context);
          },
          child: Text("ĐẶT XE"),
          backgroundColor: Colors.amberAccent,
        ),
        body: _currentLocation == null
            ? const LoadingWidget()
            : GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _currentLocation!,
                  zoom: zoom,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId("location2"),
                    position: l1,
                    icon: BitmapDescriptor.defaultMarker,
                  ),
                  Marker(
                    markerId: const MarkerId("location1"),
                    position: l2,
                    icon: BitmapDescriptor.defaultMarkerWithHue(2),
                  ),
                },
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

  void requestRide() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    String? firebaseToken = sp.getString(Varibales.TOKEN_FIREBASE);
    int? customerId = sp.getInt(Varibales.CUSTOMER_ID);
    mainAppService
        .requestRide(10.763932849773887, 106.6817367439953, l2.latitude,
            l2.longitude, price, "Làm ơn đến sớm", customerId!, firebaseToken!)
        .then((res) async {
      print(jsonDecode(res.body));
      if (res.statusCode == HttpStatus.ok) {
        final body = jsonDecode(res.body);
      }
    });
  }
}
