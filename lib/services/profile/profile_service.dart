import 'dart:convert';
import 'dart:io';

import 'package:iscte_spots/pages/profile/profile_screen.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() {
    return _instance;
  }
  ProfileService._internal() {
    // initialization logic
  }

  Map? storedProfile;

  Future<Map> fetchProfile() async {
    try {
      String? apiToken = await secureStorage.read(key: "backend_api_key");

      HttpClient client = HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
      final request =
          await client.getUrl(Uri.parse('$API_ADDRESS/api/users/profile'));
      request.headers.add("Authorization", "Token $apiToken");

      final response = await request.close();

      if (response.statusCode == 200) {
        var userProfile =
            jsonDecode(await response.transform(utf8.decoder).join());
        storedProfile = userProfile;
        return userProfile;
      }
    } catch (e) {
      print(e);
    }
    throw Exception("Failed to load profile");
  }
}
