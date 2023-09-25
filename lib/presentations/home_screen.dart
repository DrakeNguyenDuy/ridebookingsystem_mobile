import 'package:flutter/material.dart';
import 'package:ride_booking_system/core/constants/constants/assets_images.dart';
import 'package:ride_booking_system/core/constants/constants/color_constants.dart';
import 'package:ride_booking_system/core/init/main_screen_init.dart';
import 'package:ride_booking_system/core/style/main_style.dart';
import 'package:ride_booking_system/core/style/text_style.dart';
import 'package:ride_booking_system/core/widgets/category.dart';
import 'package:ride_booking_system/core/widgets/catgory_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          'https://i.pravatar.cc/300',
                          width: 60,
                          height: 60,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Nguyễn Dũy Long",
                                style:
                                    MainStyle.textStyle3.copyWith(fontSize: 15),
                              ),
                              Text(
                                "Sinh viên",
                                textAlign: TextAlign.left,
                                style: MainStyle.textStyle6,
                              )
                            ]),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: null,
                        child: Image.asset(
                          AssetImages.searchIc,
                          height: 30,
                          width: 30,
                        ),
                      ),
                      Stack(children: [
                        Image.asset(
                          AssetImages.bellIc,
                          height: 30,
                          width: 30,
                        ),
                        const Positioned(
                          top: 0,
                          right: 0,
                          child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              child: Padding(
                                padding: EdgeInsets.all(2),
                                child: Text(
                                  "10",
                                  style: TextStyle(
                                      backgroundColor: ColorPalette.pink,
                                      color: ColorPalette.white),
                                ),
                              )),
                        )
                      ]),
                    ],
                  )
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 40),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      children: [
                        Text(
                          "Welcome back!",
                          style: TextStyleApp.tsHeader.copyWith(fontSize: 25),
                        )
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "Your shortcut",
                        style: TextStyleApp.ts_1,
                      )
                    ],
                  ),
                  Container(
                    height: 100,
                    margin: const EdgeInsets.only(bottom: 10, top: 10),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      primary: false,
                      shrinkWrap: true,
                      children: listShortcut
                          .map((item) => CategoryItem(
                              pathFile: item.image!,
                              nameCategoryItem: item.name))
                          .toList(),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "Thống kê",
                        style: TextStyleApp.ts_1,
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Container(
                            margin: const EdgeInsets.only(right: 5, top: 10),
                            child: Column(
                                children: listCategoryLeft
                                    .map((item) => Category(
                                        pathImage: item.pathImage,
                                        color1: item.color1,
                                        color2: item.color2,
                                        nameCategory: item.nameCategory,
                                        hasWaterMask: item.hasWatermask))
                                    .toList()),
                          )),
                      Expanded(
                          flex: 1,
                          child: Container(
                            margin: const EdgeInsets.only(left: 5),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: listCategoryRight
                                    .map((item) => Category(
                                        pathImage: item.pathImage,
                                        color1: item.color1,
                                        color2: item.color2,
                                        nameCategory: item.nameCategory,
                                        hasWaterMask: item.hasWatermask))
                                    .toList()),
                          ))
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      )),
    );
  }
}
