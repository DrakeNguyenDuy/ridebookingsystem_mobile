import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ride_booking_system/application/common.config.dart';
import 'package:ride_booking_system/core/constants/url_system.dart';

class AuthenticationService {
  Future<http.Response> login(String username, String pasword) async {
    // var uri = Uri.https(
    //     await FlutterConfig.get("http://171.248.247.216:9092/auth/signin"));
    var uri = Uri.http(CommonConfig.ipAddress, UrlSystem.singin);
    final body = jsonEncode({'username': username, "password": pasword});
    return await http.post(uri, headers: CommonConfig.header, body: body);
  }

  Future<http.Response> logout(String username, String pasword) async {
    // var uri = Uri.https(
    //     await FlutterConfig.get("http://171.248.247.216:9092/auth/signin"));
    var uri = Uri.http(CommonConfig.ipAddress, UrlSystem.singin);
    final body = jsonEncode({'username': username, "password": pasword});
    return await http.post(uri, headers: CommonConfig.header, body: body);
  }

  Future<http.Response> register(String fullName, String citizenId, bool gender,
      String email, String phoneNumber, String address, String password) async {
    var uri = Uri.http(CommonConfig.ipAddress, UrlSystem.register);
    final body = jsonEncode({
      "name": fullName,
      "gender": gender,
      "phoneNumber": phoneNumber,
      "email": email,
      "address": address,
      "password": password,
      "citizenId ": citizenId
    });
    return await http.post(uri, headers: CommonConfig.header, body: body);
  }
}
