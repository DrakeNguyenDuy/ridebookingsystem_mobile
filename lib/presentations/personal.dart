// ignore_for_file: avoid_print, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:ride_booking_system/application/authentication_service.dart';
import 'package:ride_booking_system/core/constants/constants/color_constants.dart';
import 'package:ride_booking_system/core/constants/constants/dimension_constanst.dart';
import 'package:ride_booking_system/core/constants/constants/font_size_constanst.dart';
import 'package:ride_booking_system/core/style/text_style.dart';

class PersonalScreen extends StatefulWidget {
  const PersonalScreen({super.key});
  static const String routeName = "/login";

  @override
  State<PersonalScreen> createState() => _PersonalScreenState();
}

class _PersonalScreenState extends State<PersonalScreen> {
  // bool _isLogged = false;
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  String dataFromChild = "";
  AuthenticationService authenticationService = AuthenticationService();
  @override
  void initState() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    super.initState();
  }

  String getSayHi() {
    DateTime now = DateTime.now();
    int hourCurrent = now.hour;
    return hourCurrent < 12
        ? "Good Morning"
        : hourCurrent < 18
            ? "Good Afternoon"
            : "Good Evening";
  }

  void onDataFromChild(String data) {
    setState(() {
      dataFromChild = data;
      print(data);
    });
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
                    // decoration: BoxDecoration(
                    //     image: DecorationImage(
                    //         fit: BoxFit.fill,
                    //         image: NetworkImage(
                    //             "https://docs.flutter.dev/assets/images/dash/dash-fainting.gif"))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(getSayHi(),
                                style: TextStyleApp.ts_1.copyWith(
                                  color: ColorPalette.primaryColor,
                                  letterSpacing: 1,
                                )),
                            Text("Nguyễn Dũy Long",
                                style: TextStyleApp.tsHeader.copyWith(
                                    fontSize: fs_6,
                                    inherit: true,
                                    textBaseline: TextBaseline.ideographic,
                                    overflow: TextOverflow.fade))
                          ],
                        ),
                        CircleAvatar(
                          radius: MediaQuery.of(context).size.height / 20,
                          backgroundColor: Colors.teal,
                          backgroundImage:
                              const NetworkImage("https://i.pravatar.cc/300"),
                          child: const ElevatedButton(
                            onPressed: null,
                            child: Text("c",
                                style: TextStyle(
                                    backgroundColor: ColorPalette.yellow)),
                          ),
                        )
                      ],
                    ),
                  )),
              Expanded(
                flex: 3,
                child: ListView(
                  padding: EdgeInsets.all(ds_1),
                  children: const [
                    ListTile(
                      title: Text("Edit personal"),
                      autofocus: true,
                      // iconColor: ColorPalette.organge,
                      // leading: Icon(Icons.abc),
                      minLeadingWidth: 0,
                      selectedColor: ColorPalette.blue,
                    ),
                    ListTile(
                      title: Text("Language"),
                    ),
                    ListTile(
                      title: Text("Log out"),
                    ),
                    ListTile(
                      title: Text("Language"),
                    ),
                    ListTile(
                      title: Text("Log out"),
                    ),
                    ListTile(
                      title: Text("Language"),
                    ),
                    ListTile(
                      title: Text("Log out"),
                    ),
                    ListTile(
                      title: Text("Language"),
                    ),
                    ListTile(
                      title: Text("Log out"),
                    ),
                    ListTile(
                      title: Text("Language"),
                    ),
                    ListTile(
                      title: Text("Log out"),
                    ),
                    ListTile(
                      title: Text("Language"),
                    ),
                    ListTile(
                      title: Text("Log out"),
                    ),
                    ListTile(
                      title: Text("Language"),
                    ),
                    ListTile(
                      title: Text("Log out"),
                    ),
                    ListTile(
                      title: Text("Language"),
                    ),
                    ListTile(
                      title: Text("Log out"),
                    ),
                    ListTile(
                      title: Text("Language"),
                    ),
                    ListTile(
                      title: Text("Log out"),
                    ),
                    ListTile(
                      title: Text("Language"),
                    ),
                    ListTile(
                      title: Text("Log out"),
                    ),
                    ListTile(
                      title: Text("Language"),
                    ),
                    ListTile(
                      title: Text("Log out"),
                    ),
                    ListTile(
                      title: Text("Language"),
                    ),
                    ListTile(
                      title: Text("Log out"),
                    )
                  ],
                ),
              )
            ],
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
