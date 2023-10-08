import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthenticationService {
  Future<http.Response> login(String username, String pasword) async {
    // var uri = Uri.https(
    //     await FlutterConfig.get("http://171.248.247.216:9092/auth/signin"));
    var uri = Uri.http("116.100.28.215:9092", "/api/auth/signin");
    final body = jsonEncode({'username': username, "password": pasword});
    return await http.post(uri,
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
        },
        body: body);
  }
}
