class UrlSystem {
  static String api = "/api";
  static String auth = "$api/auth";
  static String singin = "$auth/signin";

  static String personal = "$api/person";
  static String trip = "/trip";
  static String getPrice = "$trip/getPrice";
  static String requestRide = "$trip/requestRide";
  static String location = "/location";
  static String history = '$trip/driver';
  static String updatePersonal = '$personal/update';
  static String cancelRide = "$trip/customerCancel";
  static String upload_image = "$api/upload-images";
  static String register = '$personal/register';
}
