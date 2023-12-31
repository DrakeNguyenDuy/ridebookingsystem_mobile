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
      String firebaseTokenClient,
      String pick,
      String des) async {
    final body = jsonEncode({
      "pickupLocation": {"latitude": pickLatitude, "longitude": pickLongtidude},
      "destinationLocation": {
        "latitude": desLatitude,
        "longitude": desLongtitude
      },
      "price": price,
      "notes": note,
      "customerId": customerId,
      "customerToken": firebaseTokenClient,
      "namePickUpLocation": pick,
      "nameDestination": des
    });
    var uri = Uri.http(CommonConfig.ipAddress, UrlSystem.requestRide);
    Map<String, String> header =
        await CommonConfig.headerWithToken().then((value) => value);
    return await http.post(uri, headers: header, body: body);
  }

  Future<http.Response> getAllLocation() async {
    var uri = Uri.http(CommonConfig.ipAddress, UrlSystem.location);
    Map<String, String> header =
        await CommonConfig.headerWithToken().then((value) => value);
    return await http.get(
      uri,
      headers: header,
    );
  }

  Future<http.Response> cancelRide(int tripId, String reason) async {
    var uri = Uri.http(CommonConfig.ipAddress, UrlSystem.cancelRide);
    Map<String, String> header =
        await CommonConfig.headerWithToken().then((value) => value);
    final body = jsonEncode({"tripId": tripId, "reason": reason});
    return await http.post(uri, headers: header, body: body);
  }

  Future<http.Response> rating(int tripId, double rating) async {
    var uri = Uri.http(CommonConfig.ipAddress, UrlSystem.rating);
    Map<String, String> header =
        await CommonConfig.headerWithToken().then((value) => value);
    final body = jsonEncode({"tripId": tripId, "rating": rating});
    return await http.post(uri, headers: header, body: body);
  }
}
