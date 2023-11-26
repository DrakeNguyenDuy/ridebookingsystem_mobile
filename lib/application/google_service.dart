import 'package:http/http.dart' as http;
import 'package:ride_booking_system/application/common.config.dart';

class GoogleService {
  Future<http.Response> getDistance(double latitudePick, double longtidudePick,
      double latitudeDes, double longtidudeDes) async {
    String path = "https://maps.googleapis.com/maps/api/distancematrix/"
        "json?destinations=$latitudePick%2C$longtidudePick&"
        "origins=$latitudeDes%2C$longtidudeDes&key=${CommonConfig.API_GOOGLE_KEY}";
    var uri = Uri.parse(path);
    return await http.get(uri);
  }

  Future<http.Response> searchLocation(String name) async {
    String path =
        "https://maps.googleapis.com/maps/api/place/queryautocomplete/json?input=$name&key=${CommonConfig.API_GOOGLE_KEY}";
    var uri = Uri.parse(path);
    return await http.get(uri);
  }

  Future<http.Response> getDetailLocation(String placeId) async {
    String path =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=${CommonConfig.API_GOOGLE_KEY}";
    var uri = Uri.parse(path);
    return await http.get(uri);
  }
}
