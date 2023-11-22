import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ride_booking_system/application/common.config.dart';
import 'package:ride_booking_system/core/constants/url_system.dart';

class PersonService {
  Future<http.Response> getInfo(String id) async {
    var uri = Uri.http(CommonConfig.ipAddress, '$UrlSystem.personal/$id');
    Map<String, String> header =
        CommonConfig.headerWithToken() as Map<String, String>;
    return await http.get(
      uri,
      headers: header,
    );
  }

  Future<http.Response> getHistory(int driverId) async {
    var uri =
        Uri.http(CommonConfig.ipAddress, "${UrlSystem.history}/$driverId");
    Map<String, String> header =
        await CommonConfig.headerWithToken().then((value) => value);
    return await http.get(uri, headers: header);
  }

  Future<http.Response> editPersonal(String name, String gender,
      String phoneNumber, String address, int userId) async {
    var uri = Uri.http(CommonConfig.ipAddress, UrlSystem.updatePersonal);
    Map<String, String> header =
        await CommonConfig.headerWithToken().then((value) => value);
    final body = jsonEncode({
      "address": address,
      "gender": gender,
      "name": name,
      "userId": userId,
      "phoneNumber": phoneNumber,
      "userModel": {"userId": userId}
    });
    return await http.post(uri, headers: header, body: body);
  }

  Future<http.StreamedResponse> uploadImage(String path, int userId) async {
    Map<String, String> header =
        await CommonConfig.headerWithToken().then((value) => value);
    var request = http.MultipartRequest('POST',
        Uri.parse('http://ridebookingsystem.ddns.net:9090/api/upload-images'));
    request.fields.addAll({'userId': userId.toString()});
    request.files.add(await http.MultipartFile.fromPath('image', path));
    request.headers.addAll(header);
    return await request.send();
  }
}
