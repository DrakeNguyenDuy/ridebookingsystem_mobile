import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ride_booking_system/application/message_service.dart';
import 'package:ride_booking_system/application/personal_service.dart';
import 'package:ride_booking_system/core/constants/constants/color_constants.dart';
import 'package:ride_booking_system/core/constants/constants/font_size_constanst.dart';
import 'package:ride_booking_system/core/constants/variables.dart';
import 'package:ride_booking_system/core/style/main_style.dart';
import 'package:ride_booking_system/core/widgets/loading.dart';
import 'package:ride_booking_system/core/widgets/task_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  static const String routeName = "/history";

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  PersonService personService = PersonService();
  int idUser = 0;
  List<dynamic> itemHistorys = [];
  bool isLoaded = false;

  final _messagingService = MessageService();
  @override
  void initState() {
    super.initState();
    _messagingService.init();
    innitData().then((value) => getHistory());
  }

  Future<void> innitData() async {
    await SharedPreferences.getInstance().then((ins) {
      setState(() {
        idUser = ins.getInt(Varibales.CUSTOMER_ID)!;
      });
    });
  }

  void getHistory() async {
    personService.getHistory(idUser).then((res) async {
      List<dynamic> temp = [];
      if (res.statusCode == HttpStatus.ok) {
        final body = jsonDecode(res.body);
        temp = body["data"];
      }
      setState(() {
        isLoaded = true;
        if (temp.isNotEmpty) {
          itemHistorys = temp;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: ColorPalette.white,
        appBar: AppBar(
            title: const Text("Lịch sử chuyến đi"),
            backgroundColor: ColorPalette.primaryColor),
        body: itemHistorys.isEmpty && isLoaded == false
            ? const Center(
                child: LoadingWidget(),
              )
            : itemHistorys.isEmpty && isLoaded
                ? Center(
                    child: Text(
                      "Chưa có lịch sử",
                      style: MainStyle.textStyle2.copyWith(
                          color: ColorPalette.primaryColor, fontSize: fs_2),
                    ),
                  )
                : SafeArea(
                    child: ListView.builder(
                        itemCount: itemHistorys.length,
                        itemBuilder: (ct, index) {
                          return TaskItem(
                              tripId: itemHistorys[index]["tripId"],
                              from: itemHistorys[index]["pickupLocation"],
                              to: itemHistorys[index]["destinationLocation"],
                              price: itemHistorys[index]["price"],
                              rating: itemHistorys[index]["rating"],
                              driverName: itemHistorys[index]["driver"] == null
                                  ? "Không có thông tin"
                                  : itemHistorys[index]["driver"]["name"],
                              phoneNumber: itemHistorys[index]["driver"] == null
                                  ? "Không có thông tin"
                                  : itemHistorys[index]["driver"]
                                      ["phoneNumber"],
                              gender: itemHistorys[index]["customer"]
                                  ["gender"]);
                        })));
  }
}
