import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ride_booking_system/core/constants/constants/variables.dart';
import 'package:ride_booking_system/core/style/main_style.dart';
import 'package:ride_booking_system/presentations/home_screen.dart';
import 'package:ride_booking_system/presentations/login.dart';
import 'package:ride_booking_system/presentations/main_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlashScreen extends StatefulWidget {
  const FlashScreen({Key? key}) : super(key: key);
  static String routeName = "/flash_screen";

  @override
  State<FlashScreen> createState() => _FlashScreenState();
}

class _FlashScreenState extends State<FlashScreen> {
  @override
  void initState() {
    super.initState();
    redirectToIntro();
  }

  void redirectToIntro() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    Object? accessToken = sp.get(Varibales.ACCESS_TOKEN);
    await Future.delayed(const Duration(seconds: 2));
    if (accessToken == null) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false);
    } else {
      Navigator.of(context).pushNamed(MainApp.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              children: [
                Expanded(
                    child: Lottie.asset(
                        "assets/images/imagejson/flash_screen.json")),
              ],
            ),
          )
        ],
      ),
    );
  }
}
