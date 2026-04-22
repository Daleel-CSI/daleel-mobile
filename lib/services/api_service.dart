// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://morefaat69-gov.hf.space';

  /// جلب رد الذكاء الاصطناعي (يرجع Map مباشرة)
  Future<Map<String, dynamic>> getAiResponse(String userQuery) async {
    final url = Uri.parse(
      '$baseUrl/service?query=${Uri.encodeComponent(userQuery)}',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));

      // لو الـ API رجع Map → نرجعه
      if (data is Map<String, dynamic>) {
        return data;
      }

      // لو رجع String أو حاجة تانية → نحوله لـ Map
      return {
        'response': data.toString(),
        'service': 'رد الذكاء الاصطناعي',
      };
    } else {
      throw Exception('فشل الاتصال بالـ AI (كود ${response.statusCode})');
    }
  }
}