import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_progress/loading_progress.dart';
import 'package:location/location.dart';
import 'package:ride_booking_system/application/common.config.dart';
import 'package:ride_booking_system/application/google_service.dart';
import 'package:ride_booking_system/application/main_app_service.dart';
import 'package:ride_booking_system/application/message_service.dart';
import 'package:ride_booking_system/core/constants/constants/color_constants.dart';
import 'package:ride_booking_system/core/constants/constants/dimension_constanst.dart';
import 'package:ride_booking_system/core/constants/variables.dart';
import 'package:ride_booking_system/core/style/button_style.dart';
import 'package:ride_booking_system/core/style/main_style.dart';
import 'package:ride_booking_system/core/utils/dialog_utils.dart';
import 'package:ride_booking_system/core/widgets/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  // static String routeName = "/home";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final double zoom = 16.0;
  late GoogleMapController mapController;
  final Location _locationController = Location();
  final noteController = TextEditingController();
  GoogleService googleService = GoogleService();
  MainAppService mainAppService = MainAppService();
  String pick = "";
  String des = "";

  Map<PolylineId, Polyline> polylinesMap = {};

  Map<String, dynamic> mapLocation = {};
  Map<String, dynamic> mapLocationDes = {};

  final _messagingService = MessageService();

  LatLng? _currentLocation;

  late LatLng pickLat;
  late LatLng desLat;

  List<dynamic> list = <dynamic>[];
  List<dynamic> listDes = <dynamic>[];

  double latidudePick = 0;
  double longtidudePick = 0;
  double latidudeDes = 0;
  double longtidudeDes = 0;
  double distance = 0;

  final Completer<GoogleMapController> _mapControllerCompleter =
      Completer<GoogleMapController>();

  void _onMapCreated(GoogleMapController controller) {
    // mapController = controller;
    _mapControllerCompleter.complete(controller);
  }

  @override
  void initState() {
    super.initState();
    // getAllLocation();
    getLocation().then((_) => getPolyPoint()
        .then((coordinates) => {generatePolylineFromPoints(coordinates)}));
    _messagingService.init();
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
        style: ButtonStyleHandle.bts_1,
        onPressed: () {
          Navigator.pop(context);
          requestRide(double.parse(priceResult));
        },
        child: const Text(
          "Đặt xe",
          style: TextStyle(color: ColorPalette.white),
        ));
    Widget cancelButton = TextButton(
      style: ButtonStyleHandle.bts_1,
      onPressed: () {
        Navigator.pop(context);
      },
      child: const Text(
        "Hủy",
        style: TextStyle(color: ColorPalette.white),
      ),
    );
    showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return AlertDialog(
            title: const Text("Đặt Xe", style: TextStyle(fontSize: 25)),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    text: 'Điểm đến: ',
                    style: MainStyle.textStyle2.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                          text: destination,
                          style: MainStyle.textStyle2.copyWith(
                            fontSize: 16,
                            color: Colors.black,
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: ds_1),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    hintText: "Ghi chú",
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(ds_3)),
                      borderSide: BorderSide(
                          width: ds_0, color: ColorPalette.primaryColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(ds_3)),
                      borderSide: BorderSide(
                          width: ds_0, color: ColorPalette.primaryColor),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: ds_1),
                RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    text: 'Gía cước: ',
                    style: MainStyle.textStyle2.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                          text: priceResult,
                          style: MainStyle.textStyle2.copyWith(
                            color: Colors.black,
                            fontSize: 16,
                          )),
                    ],
                  ),
                ),
              ],
            ),
            actions: [cancelButton, okButton],
            actionsAlignment: MainAxisAlignment.spaceAround,
            icon: const Icon(Icons.directions_car_rounded,
                size: 50, color: ColorPalette.primaryColor),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25))),
          );
        });
  }

  //get price by distance
  void _getPrice() async {
    if (des.isEmpty || pick.isEmpty) {
      DialogUtils.showDialogNotfication(context, true,
          "Điểm đến và điểm đi không được trống", Icons.warning_amber);
      return;
    }
    if (des == pick) {
      DialogUtils.showDialogNotfication(context, true,
          "Điểm đi và điểm đến không được trùng nhau", Icons.warning_amber);
      return;
    }
    LoadingProgress.start(context);
    //get detail location pick
    await googleService.getDetailLocation(mapLocation[pick]).then((res) async {
      if (res.statusCode == HttpStatus.ok) {
        final body = jsonDecode(res.body);
        latidudePick = body["result"]["geometry"]["location"]["lat"];
        longtidudePick = body["result"]["geometry"]["location"]["lng"];
      } else {
        LoadingProgress.stop(context);
        DialogUtils.showDialogNotfication(
            context, true, "Lỗi khi lấy chi tiết địa điểm", Icons.error);
      }
    });

    //get detail location destination
    await googleService
        .getDetailLocation(mapLocationDes[des])
        .then((res) async {
      if (res.statusCode == HttpStatus.ok) {
        final body = jsonDecode(res.body);
        latidudeDes = body["result"]["geometry"]["location"]["lat"];
        longtidudeDes = body["result"]["geometry"]["location"]["lng"];
      } else {
        LoadingProgress.stop(context);
        DialogUtils.showDialogNotfication(
            context, true, "Lỗi khi lấy chi tiết địa điểm", Icons.error);
      }
    });

    //get distance between location pick and destination
    await googleService
        .getDistance(latidudePick, longtidudePick, latidudeDes, longtidudeDes)
        .then((res1) async {
      if (res1.statusCode == HttpStatus.ok) {
        final body = jsonDecode(res1.body);
        final rows = body["rows"];
        final element = rows.elementAt(0)["elements"];
        final dis = element.elementAt(0)["distance"];
        distance = dis["value"] / 1000;
      }
    });
    mainAppService.getPrice(distance).then((res2) async {
      if (res2.statusCode == HttpStatus.ok) {
        final body = jsonDecode(res2.body);
        String priceTemp = body["data"];
        LoadingProgress.stop(context);
        order(context, des, priceTemp);
      }
    });
  }

  searchLocation(String name, bool isdes) async {
    await googleService.searchLocation(name).then((res) async {
      if (res.statusCode == HttpStatus.ok) {
        final body = jsonDecode(res.body);
        List<dynamic> locations = body["predictions"];
        Map<String, dynamic> tempMap = {};
        for (var i = 0; i < locations.length; i++) {
          String des = locations.elementAt(i)["description"];
          String placeId = locations.elementAt(i)["place_id"];
          // ignore: unnecessary_null_comparison
          if (placeId != null || placeId.isEmpty) {
            tempMap[des] = placeId;
          }
        }
        if (isdes) {
          setState(() {
            tempMap.addAll(mapLocationDes);
            mapLocationDes = tempMap;
          });
        } else {
          setState(() {
            tempMap.addAll(mapLocation);
            mapLocation = tempMap;
          });
        }
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
              viewLeading: ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.location_searching_sharp),
                  label: const Text("Vị trí hiện tại")),
              builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  hintText: "Điểm đi",
                  controller: controller,
                  padding: const MaterialStatePropertyAll<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 16.0)),
                  onTap: () {
                    controller.openView();
                  },
                  onChanged: (_) {},
                  leading: const Icon(Icons.search),
                  // trailing: [
                  //   ElevatedButton.icon(
                  //       onPressed: null,
                  //       icon: const Icon(Icons.location_searching_sharp),
                  //       label: const Text("Vị trí hiện tại"))
                  // ],
                );
              },
              isFullScreen: true,
              suggestionsBuilder:
                  (BuildContext context, SearchController controller) {
                String value = controller.value.text;
                if (value.isNotEmpty) {
                  searchLocation(value, false);
                }
                return mapLocation.keys.map((e) => ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(
                        e,
                      ),
                      onTap: () {
                        setState(() {
                          pick = e;
                          // mapLocation.clear();
                          controller.closeView(e);
                        });
                      },
                    ));
              },
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.arrow_downward, color: ColorPalette.primaryColor),
                Icon(
                  Icons.arrow_downward,
                  color: ColorPalette.primaryColor,
                )
              ],
            ),
            SearchAnchor(
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
                    // controller.openView();
                  },
                  leading: const Icon(Icons.search),
                );
              },
              isFullScreen: true,
              suggestionsBuilder:
                  (BuildContext context, SearchController controller) {
                String value = controller.value.text;
                if (value.isNotEmpty) {
                  searchLocation(value, true);
                }
                return mapLocationDes.keys.map((e) => ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(
                        e,
                      ),
                      onTap: () {
                        setState(() {
                          des = e;
                          // mapLocationDes.clear();
                          controller.closeView(e);
                        });
                      },
                    ));
              },
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 18,
                margin: const EdgeInsets.fromLTRB(ds_1, ds_2 * 2, ds_1, ds_1),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.primaryColor,
                  ),
                  onPressed: _getPrice,
                  child: Text(
                    "Đặt chuyến",
                    style: MainStyle.textStyle5,
                  ),
                ))
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
                markers: {
                  Marker(
                    markerId: const MarkerId("locationCustomerCurrently"),
                    position: _currentLocation!,
                    icon: BitmapDescriptor.defaultMarker,
                  ),
                },
                polylines: Set<Polyline>.of(polylinesMap.values),
              ),
      ),
    );
  }

  void requestRide(double price) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    String? firebaseToken = sp.getString(Varibales.TOKEN_FIREBASE);
    int? customerId = sp.getInt(Varibales.CUSTOMER_ID);
    mainAppService
        .requestRide(latidudePick, longtidudePick, latidudeDes, longtidudeDes,
            price, noteController.text, customerId!, firebaseToken!, pick, des)
        .then((res) async {
      final body = jsonDecode(res.body);
      if (res.statusCode == HttpStatus.ok) {
        if (body["message"] == "Failed") {
          DialogUtils.showDialogNotfication(
              context, false, body["data"], Icons.message);
          return;
        }
        mapLocation.clear();
        mapLocationDes.clear();
        DialogUtils.showDialogNotfication(
            context, false, "Bạn đã đặt xe thành công", Icons.done);
      } else {
        DialogUtils.showDialogNotfication(
            context, true, "Đã xãy ra lỗi", Icons.error);
      }
    });
  }
}
