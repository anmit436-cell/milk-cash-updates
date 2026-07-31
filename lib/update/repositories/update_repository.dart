import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/update_info.dart';

class UpdateRepository {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // The URL to your hosted update.json metadata file.
  // Example: 'https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/update.json'
  final String _updateApiUrl = 'https://raw.githubusercontent.com/anmit436-cell/milk-cash-updates/refs/heads/main/update.json';

  Future<UpdateInfo?> fetchUpdateInfo({required String channel}) async {
    try {
      final response = await _dio.get(_updateApiUrl);
      if (response.statusCode == 200) {
        // If the URL is raw github, the response is often a String that needs parsing
        final data = (response.data is String) ? response.data : response.data;
        // Sometimes dio automatically decodes json, let's handle both
        Map<String, dynamic> jsonMap;
        if (data is String) {
          jsonMap = Map<String, dynamic>.from(const JsonDecoder().convert(data));
        } else {
          jsonMap = Map<String, dynamic>.from(data);
        }
        
        return UpdateInfo.fromJson(jsonMap);
      }
      return null;
    } catch (e) {
      // Return null on network failure (which allows retry logic in UpdateService)
      return null;
    }
  }
}
