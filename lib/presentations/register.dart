// ignore_for_file: avoid_print, use_build_context_synchronously
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_progress/loading_progress.dart';
import 'package:ride_booking_system/application/authentication_service.dart';
import 'package:ride_booking_system/core/constants/constants/color_constants.dart';
import 'package:ride_booking_system/core/constants/constants/dimension_constanst.dart';
import 'package:ride_booking_system/core/constants/constants/font_size_constanst.dart';
import 'package:ride_booking_system/core/style/main_style.dart';
import 'package:ride_booking_system/core/widgets/text_field_widget.dart';
import 'package:ride_booking_system/presentations/login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static const String routeName = "/register";

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final fullnameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
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
    var fullName = fullnameController.text;
    var phoneNumber = phoneNumberController.text;
    var email = emailController.text;
    var address = addressController.text;
    var password = passwordController.text;
    bool gender = genderSelected == "Female" ? false : true;
    if (fullName == "" ||
        phoneNumber == "" ||
        email == "" ||
        address == "" ||
        password == "" ||
        genderSelected == "") {
      Fluttertoast.showToast(msg: "Các ô giá trị cần phải điển đầy đủ");
    }
    LoadingProgress.start(context);
    authenticationService
        .register(fullName, gender, email, phoneNumber, address, password)
        .then((res) async {
      if (res.statusCode == HttpStatus.ok) {
        LoadingProgress.stop(context);
        Fluttertoast.showToast(msg: "Đăng ký thành công, hãy đăng nhập");
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false);
      } else {
        LoadingProgress.stop(context);
        Fluttertoast.showToast(
            msg: "Đăng ký không thành công", webPosition: "top");
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
                  SizedBox(
                    height: ds_2,
                  ),
                  Text(
                    "Đăng Ký Tài Khoản",
                    style: MainStyle.textStyle1.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: fs_3 * 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  TextFieldWidget(
                    nameLable: "Họ và tên",
                    controller: fullnameController,
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
                    controller: phoneNumberController,
                  ),
                  TextFieldWidget(
                    nameLable: "Email",
                    controller: emailController,
                  ),
                  TextFieldWidget(
                    nameLable: "Địa chỉ",
                    controller: addressController,
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
    fullnameController.dispose();
    passwordController.dispose();
    addressController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
