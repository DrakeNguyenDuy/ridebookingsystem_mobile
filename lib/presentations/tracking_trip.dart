import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ride_booking_system/application/main_app_service.dart';
import 'package:ride_booking_system/core/constants/constants/assets_images.dart';
import 'package:ride_booking_system/core/constants/constants/color_constants.dart';
import 'package:ride_booking_system/core/constants/constants/dimension_constanst.dart';
import 'package:ride_booking_system/core/style/button_style.dart';
import 'package:ride_booking_system/core/style/main_style.dart';
import 'package:ride_booking_system/core/utils/dialog_utils.dart';
import 'package:ride_booking_system/presentations/main_app.dart';

// ignore: must_be_immutable
class TrackingTripScreen extends StatefulWidget {
  int codeTrip;
  String phoneNumberDriver;
  String nameDriver;
  String des;
  String pick;
  String price;
  TrackingTripScreen(
      {super.key,
      required this.codeTrip,
      required this.phoneNumberDriver,
      required this.nameDriver,
      required this.des,
      required this.pick,
      required this.price});

  @override
  State<TrackingTripScreen> createState() => _TrackingTripScreenState();
}

class _TrackingTripScreenState extends State<TrackingTripScreen> {
  MainAppService mainAppService = MainAppService();
  var controller = TextEditingController();

  void cancel() {
    Widget okButton = TextButton(
        style: ButtonStyleHandle.bts_1,
        onPressed: () {
          cancelRide();
        },
        child: const Text(
          "OK",
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
        barrierDismissible: false,
        barrierLabel: "đas",
        useSafeArea: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Bạn vẫn muốn hủy xe chứ"),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Nhập nội dung hủy chiến",
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(ds_3)),
                  borderSide:
                      BorderSide(width: ds_0, color: ColorPalette.primaryColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(ds_3)),
                  borderSide:
                      BorderSide(width: ds_0, color: ColorPalette.primaryColor),
                ),
              ),
              maxLines: 8,
            ),
            actions: [cancelButton, okButton],
            actionsAlignment: MainAxisAlignment.spaceEvenly,
          );
        });
  }

  SizedBox sizeBox = const SizedBox(height: 15);

  Widget renderText(String nameLable, dynamic value) {
    return RichText(
      text: TextSpan(
        text: "$nameLable: ",
        style: MainStyle.textStyle2.copyWith(
          fontSize: 20,
          color: Colors.black,
        ),
        children: <TextSpan>[
          TextSpan(
              text: "$value",
              style: MainStyle.textStyle2.copyWith(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.normal)),
        ],
      ),
    );
  }

  void cancelRide() async {
    Navigator.pop(context);
    mainAppService
        .cancelRide(widget.codeTrip, controller.text)
        .then((res) async {
      if (res.statusCode == HttpStatus.ok) {
        Fluttertoast.showToast(msg: "Hủy chuyến thành công");
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainApp()),
            (route) => false);
      } else {
        DialogUtils.showDialogNotfication(
            context, "Xảy ra lỗi khi hủy chuyến", Icons.error);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Tạm thời bạn không thể rời khỏi màn hình này',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      },
      child: Scaffold(
          backgroundColor: ColorPalette.white,
          appBar: AppBar(
            title: const Text('Theo dõi chuyến đi'),
            backgroundColor: ColorPalette.primaryColor,
          ),
          body: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(ds_1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.asset(
                        AssetImages.login,
                        height: MediaQuery.of(context).size.height / 4,
                      ),
                      renderText("Mã chuyến đi", widget.codeTrip),
                      sizeBox,
                      renderText("Điểm đón", widget.pick),
                      sizeBox,
                      renderText("Điểm trả", widget.des),
                      sizeBox,
                      renderText("Tên tài xế", widget.nameDriver),
                      sizeBox,
                      renderText(
                          "Số điện thoại tài xế", widget.phoneNumberDriver),
                      sizeBox,
                      renderText("Gía", widget.price),
                    ],
                  ),
                ),
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 18,
                    margin: const EdgeInsets.fromLTRB(ds_1, ds_1, ds_1, ds_1),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalette.red,
                      ),
                      onPressed: cancel,
                      child: Text(
                        "Hủy Chuyến",
                        style: MainStyle.textStyle5,
                      ),
                    )),
              ],
            ),
          )),
    );
  }
}
