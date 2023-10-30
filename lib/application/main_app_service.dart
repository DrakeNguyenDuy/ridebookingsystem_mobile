import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ride_booking_system/application/common.config.dart';
import 'package:ride_booking_system/core/constants/url_system.dart';

class MainAppService {
  Future<http.Response> getPrice(double distance) async {
    final queryParameters = {
      'distance': distance.toString(),
    };
    var uri =
        Uri.http(CommonConfig.ipAddress, UrlSystem.getPrice, queryParameters);
    Map<String, String> header =
        await CommonConfig.headerWithToken().then((value) => value);
    return await http.get(
      uri,
      headers: header,
    );
  }

  Future<http.Response> requestRide(
      double pickLatitude,
      double pickLongtidude,
      double desLatitude,
      double desLongtitude,
      double price,
      String note,
      int customerId,
      String firebaseTokenClient) async {
    final body = jsonEncode({
      "pickupLocation": {"latitude": pickLatitude, "longitude": pickLongtidude},
      "destinationLocation": {
        "latitude": desLatitude,
        "longitude": desLongtitude
      },
      "price": price,
      "notes": note,
      "customerId": customerId,
      "customerToken": firebaseTokenClient
    });
    var uri = Uri.http(CommonConfig.ipAddress, UrlSystem.requestRide);
    Map<String, String> header =
        await CommonConfig.headerWithToken().then((value) => value);
    return await http.post(uri, headers: header, body: body);
  }
}
