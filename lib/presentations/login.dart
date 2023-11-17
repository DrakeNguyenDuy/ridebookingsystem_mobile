// ignore_for_file: avoid_print, use_build_context_synchronously
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_progress/loading_progress.dart';
import 'package:ride_booking_system/application/authentication_service.dart';
import 'package:ride_booking_system/core/constants/constants/assets_images.dart';
import 'package:ride_booking_system/core/constants/constants/color_constants.dart';
import 'package:ride_booking_system/core/constants/constants/dimension_constanst.dart';
import 'package:ride_booking_system/core/constants/constants/font_size_constanst.dart';
import 'package:ride_booking_system/core/constants/variables.dart';
import 'package:ride_booking_system/core/style/main_style.dart';
import 'package:ride_booking_system/core/widgets/text_field_widget.dart';
import 'package:ride_booking_system/presentations/main_app.dart';
import 'package:ride_booking_system/presentations/register.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String routeName = "/login";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  AuthenticationService authenticationService = AuthenticationService();
  @override
  void initState() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    super.initState();
  }

  void _loggin() async {
    LoadingProgress.start(context);
    var username = userNameController.text;
    var password = passwordController.text;
    authenticationService.login(username, password).then((res) async {
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        String statusCode = body['status'];
        if (statusCode.compareTo("ERROR") == 0) {
          LoadingProgress.stop(context);
          Fluttertoast.showToast(
              backgroundColor: Colors.amberAccent,
              msg: body['data']['message'],
              webPosition: "top");
        }
        var userInfo = body['data']['userInfo'];
        await SharedPreferences.getInstance().then((ins) {
          ins.setString(Varibales.ACCESS_TOKEN, body['data']['accessToken']);
          ins.setInt(Varibales.CUSTOMER_ID, userInfo["personModel"]["userId"]);
          ins.setString(Varibales.NAME_USER, userInfo["personModel"]["name"]);
          ins.setString(
              Varibales.GENDER_USER, userInfo["personModel"]["gender"]);
          ins.setString(Varibales.PHONE_NUMBER_USER,
              userInfo["personModel"]["phoneNumber"]);
          ins.setString(
              Varibales.AVATAR_USER, userInfo["personModel"]["avatar"]);
          ins.setString(Varibales.ADDRESS, userInfo["personModel"]["address"]);
          ins.setString(Varibales.EMAIL, userInfo["personModel"]["email"]);
        });
        LoadingProgress.stop(context);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainApp()),
            (route) => false);
      } else {
        LoadingProgress.stop(context);
        Fluttertoast.showToast(
            msg: "Username or Password incorrect!", webPosition: "top");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: ColorPalette.white,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Image.asset(
                    AssetImages.login,
                    height: MediaQuery.of(context).size.height / 3,
                  ),
                ),
                Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Text(
                          "Đăng Nhập",
                          style: MainStyle.textStyle1.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: fs_3 * 2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        TextFieldWidget(
                          nameLable: "Tên đăng nhập",
                          controller: userNameController,
                        ),
                        TextFieldWidget(
                          nameLable: "Mật khẩu",
                          controller: passwordController,
                          typePassword: true,
                        ),
                        Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height / 18,
                            margin: const EdgeInsets.fromLTRB(
                                ds_1, ds_1, ds_1, ds_1),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorPalette.primaryColor,
                              ),
                              onPressed: _loggin,
                              child: Text(
                                "Đăng nhập",
                                style: MainStyle.textStyle5,
                              ),
                            )),
                        const SizedBox(
                          height: ds_3,
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const RegisterScreen()),
                                  (route) => false);
                            },
                            child: Text(
                              "Bạn chưa có tài khoản? Đăng ký ngay",
                              style:
                                  TextStyle(color: ColorPalette.primaryColor),
                            ))
                      ],
                    )),
              ],
            ),
          ),
        ));
  }

  @override
  void dispose() {
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
