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
import 'package:ride_booking_system/presentations/login.dart';
import 'package:ride_booking_system/presentations/main_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static const String routeName = "/register";

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final fullnameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  AuthenticationService authenticationService = AuthenticationService();
  List<String> _genders = <String>['Female', 'Male'];
  String genderSelected = "";
  @override
  void initState() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    super.initState();
  }

  void _register() async {
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
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                  top: ds_1, bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    "ĐĂNG KÝ",
                    style: MainStyle.textStyle1.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: fs_3 * 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  TextFieldWidget(
                    nameLable: "Họ và tên",
                    controller: userNameController,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(ds_1),
                    child: DropdownMenu<String>(
                      inputDecorationTheme: const InputDecorationTheme(
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(ds_3)),
                            borderSide: BorderSide(
                                width: ds_0, color: ColorPalette.primaryColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(ds_3)),
                            borderSide: BorderSide(
                                width: ds_0, color: ColorPalette.primaryColor),
                          )),
                      width: MediaQuery.of(context).size.width - ds_2,
                      hintText: "Giới tính",
                      initialSelection: genderSelected,
                      onSelected: (String? value) {
                        setState(() {
                          genderSelected = value!;
                        });
                      },
                      dropdownMenuEntries: _genders
                          .map<DropdownMenuEntry<String>>((String value) {
                        return DropdownMenuEntry<String>(
                            value: value, label: value);
                      }).toList(),
                    ),
                  ),
                  TextFieldWidget(
                    nameLable: "Số điện thoại",
                    controller: passwordController,
                    typePassword: true,
                  ),
                  TextFieldWidget(
                    nameLable: "Email",
                    controller: passwordController,
                    typePassword: true,
                  ),
                  TextFieldWidget(
                    nameLable: "Địa chỉ",
                    controller: passwordController,
                    typePassword: true,
                  ),
                  TextFieldWidget(
                    nameLable: "Username",
                    controller: passwordController,
                    typePassword: true,
                  ),
                  TextFieldWidget(
                    nameLable: "Mật khẩu",
                    controller: passwordController,
                    typePassword: true,
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 18,
                      margin: const EdgeInsets.fromLTRB(ds_1, ds_1, ds_1, ds_1),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPalette.primaryColor,
                        ),
                        onPressed: _register,
                        child: Text(
                          "Đăng Ký",
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
                                builder: (_) => const LoginScreen()),
                            (route) => false);
                      },
                      child: Text(
                        "Bạn đã có tài khoản? Đăng nhập ngay",
                        style: TextStyle(color: ColorPalette.primaryColor),
                      )),
                ],
              ),
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
