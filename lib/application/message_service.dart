import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:ride_booking_system/application/main_app_service.dart';
import 'package:ride_booking_system/application/personal_service.dart';
import 'package:ride_booking_system/core/constants/constants/color_constants.dart';
import 'package:ride_booking_system/core/constants/variables.dart';
import 'package:ride_booking_system/core/style/button_style.dart';
import 'package:ride_booking_system/core/style/main_style.dart';
import 'package:ride_booking_system/core/utils/dialog_utils.dart';
import 'package:ride_booking_system/main.dart';
import 'package:ride_booking_system/presentations/tracking_trip.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageService {
  static String? fcmToken; // Variable to store the FCM token

  static final MessageService _instance = MessageService._internal();

  static String titleCancellRide = "Chuyến đi đã bị hủy bởi tài xế!";
  static String titleCompleteTrip = "Cuốc xe đã hoàn tất";

  final SizedBox sizedBox = const SizedBox(height: 10);

  factory MessageService() => _instance;

  PersonService personService = PersonService();

  MessageService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  MainAppService mainAppService = MainAppService();

  String tripId = "";
  double ratingValue = 0;

  Future<void> init() async {
    // Requesting permission for notifications
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint(
        'User granted notifications permission: ${settings.authorizationStatus}');

    // Retrieving the FCM token
    await _fcm.getToken().then((value) async {
      await SharedPreferences.getInstance().then((ins) {
        ins.setString(Varibales.TOKEN_FIREBASE, value!);
      });
    });

    // Handling background messages using the specified handler
    FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
      print(message);
    });

    // Listening for incoming messages while the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        if (message.notification!.title != null &&
            message.notification!.body != null) {
          String? title = message.notification!.title;
          if (title != titleCancellRide && titleCompleteTrip != title) {
            showDialogAcceptedRide(title!, message.notification!.body);
          } else if (titleCompleteTrip == title) {
            Navigator.of(navigatorKey.currentContext!).pushNamed("/home");
            showDialogCompleteTrip(title!, message.notification!.body);
          } else {
            showDialogCancelRide(title!, message.notification!.body);
          }
        }
      }
    });

    // Handling the initial message received when the app is launched from dead (killed state)
    // When the app is killed and a new notification arrives when user clicks on it
    // It gets the data to which screen to open
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        // _handleNotificationClick(context, message);
      }
    });

    // Handling a notification click event when the app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
          'onMessageOpenedApp: ${message.notification!.title.toString()}');
      // _handleNotificationClick(context, message);
    });
  }

  // Handling a notification click event by navigating to the specified screen
  void _handleNotificationClick(BuildContext context, RemoteMessage message) {
    final notificationData = message.data;

    if (notificationData.containsKey('screen')) {
      final screen = notificationData['screen'];
      Navigator.of(context).pushNamed(screen);
    }
  }

  void showDialogAcceptedRide(String title, dynamic body) {
    Map<String, dynamic> notificationData = jsonDecode(body);
    String nameDriver = notificationData["Tên tài xế"];
    tripId = notificationData["Mã chuyến đi"];
    String pick = notificationData["Điêm đón khách"];
    String des = notificationData["Điêm trả khách"];
    String phoneNumber = notificationData["Số điện thoại"];
    String price = notificationData["Giá cuốc xe"];
    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            surfaceTintColor: ColorPalette.primaryColor,
            title: Text(title),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                renderText("Mã chuyến đi", tripId),
                sizedBox,
                renderText("Tên tài xế", nameDriver),
                sizedBox,
                renderText("Điểm đón", pick),
                sizedBox,
                renderText("Điểm trả", des),
                sizedBox,
                RichText(
                  text: TextSpan(
                    text: 'Gía: ',
                    style: MainStyle.textStyle2
                        .copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                    children: <TextSpan>[
                      TextSpan(
                          text: price,
                          style: MainStyle.textStyle2.copyWith(
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                              color: Colors.black)),
                      TextSpan(
                          text: " VNĐ",
                          style: MainStyle.textStyle2.copyWith(
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                              color: Colors.black)),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => TrackingTripScreen(
                              codeTrip: int.parse(tripId),
                              phoneNumberDriver: phoneNumber,
                              nameDriver: nameDriver,
                              des: des,
                              pick: pick,
                              price: price)),
                      (route) => false);
                },
                style: ButtonStyleHandle.bts_1,
                child: const Text("Xem chi tiết",
                    style: TextStyle(color: ColorPalette.white)),
              ),
            ],
            icon: Icon(Icons.directions_car_rounded,
                size: 50, color: ColorPalette.primaryColor),
            actionsAlignment: MainAxisAlignment.center,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25))),
          ),
        );
      },
    );
  }

  void showDialogCompleteTrip(String title, dynamic body) {
    Map<String, dynamic> notificationData = jsonDecode(body);
    String nameDriver = notificationData["Tên tài xế"];
    String tripId = notificationData["Mã chuyến đi"];
    String pick = notificationData["Điêm đón khách"];
    String des = notificationData["Điêm trả khách"];
    String price = notificationData["Giá cuốc xe"];
    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            surfaceTintColor: ColorPalette.primaryColor,
            title: Text(title),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                renderText("Mã chuyến đi", tripId),
                sizedBox,
                renderText("Tên tài xế", nameDriver),
                sizedBox,
                renderText("Điểm đón", pick),
                sizedBox,
                renderText("Điểm trả", des),
                sizedBox,
                RichText(
                  text: TextSpan(
                    text: 'Gía: ',
                    style: MainStyle.textStyle2
                        .copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                    children: <TextSpan>[
                      TextSpan(
                          text: price,
                          style: MainStyle.textStyle2.copyWith(
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                              color: Colors.black)),
                      TextSpan(
                          text: " VNĐ",
                          style: MainStyle.textStyle2.copyWith(
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                              color: Colors.black)),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  showRatingDialog(context);
                },
                style: ButtonStyleHandle.bts_1,
                child: const Text("OK",
                    style: TextStyle(color: ColorPalette.white)),
              ),
            ],
            icon: const Icon(Icons.directions_car_rounded,
                size: 50, color: ColorPalette.primaryColor),
            actionsAlignment: MainAxisAlignment.center,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25))),
          ),
        );
      },
    );
  }

  void showRatingDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Đánh Giá Chuyến Đi"),
            actions: [
              TextButton(
                style: ButtonStyleHandle.bts_1,
                onPressed: () {
                  Navigator.pop(context);
                  rating();
                },
                child: const Text(
                  "OK",
                  style: TextStyle(color: ColorPalette.white),
                ),
              ),
            ],
            content: RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                ratingValue = rating;
              },
            ),
          );
        });
  }

  void showDialogCancelRide(String title, dynamic body) {
    Map<String, dynamic> notificationData = jsonDecode(body);
    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text(title),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    text: 'Mã chuyến đi: ',
                    style: MainStyle.textStyle2.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                          text: notificationData["Mã chuyến đi"],
                          style: MainStyle.textStyle2.copyWith(
                            fontSize: 16,
                            color: Colors.black,
                          )),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: 'Lý do: ',
                    style: MainStyle.textStyle2.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                          text: notificationData["Lý do hủy cuốc"],
                          style: MainStyle.textStyle2.copyWith(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.normal)),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                style: ButtonStyleHandle.bts_1,
                onPressed: () {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    Navigator.of(context)
                        .pushNamed("/home")
                        .then((value) async {
                      Navigator.of(context).pop();
                    });
                  });
                },
                child: Text(
                  "OK",
                  style: TextStyle(color: ColorPalette.white),
                ),
              ),
            ],
            icon: const Icon(Icons.notification_important,
                size: 50, color: ColorPalette.primaryColor),
            actionsAlignment: MainAxisAlignment.spaceAround,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25))),
          ),
        );
      },
    );
  }

  void rating() async {
    mainAppService.rating(int.parse(tripId), ratingValue).then((res) async {
      if (res.statusCode == HttpStatus.ok) {
        DialogUtils.showDialogNotfication(navigatorKey.currentContext!, false,
            "Cảm ơn bạn đã đánh giá", Icons.face);
      } else {
        DialogUtils.showDialogNotfication(navigatorKey.currentContext!, true,
            "Lỗi khi đánh giá", Icons.error);
      }
    });
  }

  Widget renderText(String nameLable, dynamic value) {
    return RichText(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
      text: TextSpan(
        text: '$nameLable: ',
        style: MainStyle.textStyle2.copyWith(
            fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
        children: <TextSpan>[
          TextSpan(
              text: value,
              style: MainStyle.textStyle2.copyWith(
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                  color: Colors.black)),
        ],
      ),
    );
  }
}
