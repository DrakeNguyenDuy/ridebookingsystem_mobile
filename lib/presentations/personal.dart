// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ride_booking_system/application/authentication_service.dart';
import 'package:ride_booking_system/application/personal_service.dart';
import 'package:ride_booking_system/core/constants/constants/color_constants.dart';
import 'package:ride_booking_system/core/constants/constants/dimension_constanst.dart';
import 'package:ride_booking_system/core/constants/constants/font_size_constanst.dart';
import 'package:ride_booking_system/core/constants/variables.dart';
import 'package:ride_booking_system/core/style/text_style.dart';
import 'package:ride_booking_system/presentations/edit_personal.dart';
import 'package:ride_booking_system/presentations/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalScreen extends StatefulWidget {
  const PersonalScreen({super.key});
  static const String routeName = "/personal";

  @override
  State<PersonalScreen> createState() => _PersonalScreenState();
}

class _PersonalScreenState extends State<PersonalScreen> {
  final PersonService personalService = PersonService();
  String name = "";
  String gender = "";
  String address = "";
  String phoneNumber = "";
  String avatar = "";
  String email = "";
  String tokenFirebase = "";
  int idUser = -1;

  AuthenticationService authenticationService = AuthenticationService();
  @override
  void initState() {
    innitData();
    super.initState();
  }

  void changeAvatar() async {
    final ImagePicker picker = ImagePicker();
    XFile? choosedimage = await picker.pickImage(source: ImageSource.gallery);
    List<int> bytes = await choosedimage!.readAsBytes();
    String base64 = base64Encode(bytes);
    personalService.uploadImage(choosedimage!.path, idUser).then((res) async {
      if (res.statusCode == HttpStatus.ok) {
        Fluttertoast.showToast(msg: "Cập nhật ảnh thành công");
        await SharedPreferences.getInstance()
            .then((ins) => {ins.setString(Varibales.AVATAR_USER, base64)});
        setState(() {
          avatar = base64;
        });
      }
    });
  }

  void _logout() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.clear();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false);
  }

  void moveEditScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditPersonalScreen(
                name: name,
                address: address,
                phoneNumber: phoneNumber,
                gender: gender,
                email: email,
                userId: idUser,
              )),
    ).then((value) async {
      await SharedPreferences.getInstance().then((ins) {
        setState(() {
          name = ins.getString(Varibales.NAME_USER)!;
        });
      });
    });
  }

  String getSayHi() {
    DateTime now = DateTime.now();
    int hourCurrent = now.hour;
    return hourCurrent < 12
        ? "Chào buổi sáng"
        : hourCurrent < 18
            ? "Good Afternoon"
            : "Good Evening";
  }

  void _pressItem(BuildContext context) async {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Hủy"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Ok"),
      onPressed: () {
        _logout();
      },
    );

    showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return AlertDialog(
            title: const Text("Bạn có muốn đăng xuất không?"),
            actions: [
              cancelButton,
              continueButton,
            ],
          );
        });
  }

  void changeStateConnect(bool status) async {
    await SharedPreferences.getInstance().then((ins) {
      ins.setBool(Varibales.IS_CONNECT, status);
    });
  }

  void innitData() async {
    await SharedPreferences.getInstance().then((ins) {
      setState(() {
        name = ins.getString(Varibales.NAME_USER)!;
        address = ins.getString(Varibales.ADDRESS)!;
        avatar = ins.getString(Varibales.AVATAR_USER)!;
        gender = ins.getString(Varibales.GENDER_USER)!;
        phoneNumber = ins.getString(Varibales.PHONE_NUMBER_USER)!;
        email = ins.getString(Varibales.EMAIL)!;
        idUser = ins.getInt(Varibales.CUSTOMER_ID)!;
        tokenFirebase = ins.getString(Varibales.TOKEN_FIREBASE)!;
      });
    });
  }

  ImageProvider<Object> getAvt() {
    return avatar == ""
        ? const NetworkImage("https://ui-avatars.com/api/?name=rbs")
            as ImageProvider
        : MemoryImage(base64Decode(avatar));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: ColorPalette.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                  flex: 1,
                  child: Container(
                    color: ColorPalette.grayLight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(getSayHi(),
                                  style: TextStyleApp.ts_1.copyWith(
                                    color: ColorPalette.primaryColor,
                                    letterSpacing: 1,
                                  )),
                              Text(name,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyleApp.tsHeader.copyWith(
                                      fontSize: fs_6,
                                      inherit: true,
                                      textBaseline: TextBaseline.ideographic,
                                      overflow: TextOverflow.fade)),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: MediaQuery.of(context).size.height / 18,
                                backgroundColor: Colors.teal,
                                backgroundImage: getAvt(),
                              ),
                              Positioned(
                                bottom: 1,
                                right: 1,
                                child: GestureDetector(
                                  onTap: () {
                                    changeAvatar();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 2,
                                          color: Colors.white,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(
                                            50,
                                          ),
                                        ),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            offset: Offset(2, 4),
                                            color: Colors.black.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 3,
                                          ),
                                        ]),
                                    child: const Padding(
                                      padding: EdgeInsets.all(ds_1),
                                      child: Icon(Icons.add_a_photo,
                                          color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )),
              Expanded(
                flex: 3,
                child: ListView(
                  padding: const EdgeInsets.all(ds_1),
                  children: [
                    ListTile(
                      title: const Text("Chỉnh sửa thông tin cá nhân"),
                      autofocus: true,
                      minLeadingWidth: 0,
                      selectedColor: ColorPalette.blue,
                      onTap: () => moveEditScreen(),
                    ),
                    ListTile(
                        title: const Text("Đăng xuất"),
                        onTap: () => _pressItem(context)),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
