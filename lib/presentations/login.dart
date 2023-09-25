// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ride_booking_system/application/authentication_service.dart';
import 'package:ride_booking_system/common/share_preferences.dart';
import 'package:ride_booking_system/core/constants/constants/assets_images.dart';
import 'package:ride_booking_system/core/constants/constants/color_constants.dart';
import 'package:ride_booking_system/core/constants/constants/dimension_constanst.dart';
import 'package:ride_booking_system/core/constants/constants/font_size_constanst.dart';
import 'package:ride_booking_system/core/constants/constants/variables.dart';
import 'package:ride_booking_system/core/style/main_style.dart';
import 'package:ride_booking_system/core/widgets/input_label.dart';
import 'package:ride_booking_system/presentations/main_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.title});
  static const String routeName = "/login";
  final String title;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // bool _isLogged = false;
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  AuthenticationService authenticationService = new AuthenticationService();
  @override
  void initState() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    super.initState();
  }

  void _loggin() {
    String username = userNameController.text;
    String password = passwordController.text;
    authenticationService.login(username, password).then((res) async {
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final SharedPreferences sp = await SharedPreferences.getInstance();
        print(body);
        sp.setString(Varibales.ACCESS_TOKEN, body['data']['accessToken']);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainApp()),
            (route) => false);
      } else {
        print("Login fail");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: ColorPalette.white,
        body: SafeArea(
          child: Container(
            margin: const EdgeInsets.all(ds_3),
            child: Column(
              children: [
                Container(
                    padding: EdgeInsets.fromLTRB(ds_0, ds_3, ds_0, ds_0),
                    child: Image.asset(
                      AssetImages.login,
                      height: MediaQuery.of(context).size.height / 3,
                    )),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "LOGIN",
                              style: MainStyle.textStyle1.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: fs_2 * 2),
                              textAlign: TextAlign.center,
                            ),
                            // Text(
                            //   "Hãy Đăng Nhập Trước Nhé",
                            //   style: MainStyle.textStyle1.copyWith(
                            //       fontWeight: FontWeight.normal, fontSize: fs_1),
                            //   textAlign: TextAlign.center,
                            // )
                          ],
                        ),
                      ),
                      Container(
                          margin: const EdgeInsets.only(top: ds_3),
                          child: InputLable(
                            nameLable: "Email",
                            controller: userNameController,
                          )),
                      Container(
                          margin: const EdgeInsets.only(top: ds_3),
                          child: InputLable(
                            nameLable: "Mật khẩu",
                            typePassword: true,
                            controller: passwordController,
                          )),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: ColorPalette.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 15)),
                        onPressed: _loggin,
                        child: Text(
                          "Login",
                          style: MainStyle.textStyle5,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}

// const Text("Hãy đăng nhập đi",
//           style: TextStyle(
//               color: Color.fromARGB(255, 57, 241, 100),
//               fontSize: 100.0,
//               fontWeight: FontWeight.w700)),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _logged,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),
//  Image.network(
//                 "https://assets.materialup.com/uploads/c18c728e-b55c-4195-9b50-16bb2d767908/mockup.png"),
//           )
