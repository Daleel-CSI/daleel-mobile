import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://auth-login-for-daleel1.vercel.app';

  // ---------- خدمات ----------
  static Future<bool> updateService({
    required String serviceId,
    required Map<String, dynamic> data,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/services/$serviceId');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final response = await http.put(uri, headers: headers, body: json.encode(data));
      debugPrint('🔹 PUT /services/$serviceId -> ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('❌ Update service error: $e');
      return false;
    }
  }

  static Future<bool> deleteService({
    required String serviceId,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/services/$serviceId');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final response = await http.delete(uri, headers: headers);
      debugPrint('🔹 DELETE /services/$serviceId -> ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('❌ Delete service error: $e');
      return false;
    }
  }

  static Future<bool> approveService({
    required String serviceId,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/services/$serviceId/approve');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final response = await http.put(uri, headers: headers);
      debugPrint('🔹 PUT /services/$serviceId/approve -> ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('❌ Approve service error: $e');
      return false;
    }
  }

  static Future<bool> rejectService({
    required String serviceId,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/services/$serviceId/reject');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final response = await http.put(uri, headers: headers);
      debugPrint('🔹 PUT /services/$serviceId/reject -> ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('❌ Reject service error: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>?> getServices({
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/services');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final response = await http.get(uri, headers: headers);
      debugPrint('🔹 GET /services -> ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data['services'] != null) {
          return (data['services'] as List).cast<Map<String, dynamic>>();
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Get services error: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>?> getPendingServices({
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/services/pending');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final response = await http.get(uri, headers: headers);
      debugPrint('🔹 GET /services/pending -> ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data['services'] != null) {
          return (data['services'] as List).cast<Map<String, dynamic>>();
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Get pending services error: $e');
      return null;
    }
  }

  // ---------- تصويتات ----------
  static Future<List<Map<String, dynamic>>?> getVotes({
    required String serviceId,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/votes/$serviceId');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final response = await http.get(uri, headers: headers);
      debugPrint('🔹 GET /votes/$serviceId -> ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data['votes'] != null) {
          return (data['votes'] as List).cast<Map<String, dynamic>>();
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Get votes error: $e');
      return null;
    }
  }

  static Future<bool> postVote({
    required String serviceId,
    required String type,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/votes/$serviceId');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final body = json.encode({'type': type});
      final response = await http.post(uri, headers: headers, body: body);
      debugPrint('🔹 POST /votes/$serviceId -> ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('❌ Post vote error: $e');
      return false;
    }
  }

  // ---------- إعدادات ----------
  static Future<Map<String, dynamic>?> getSettings({
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/settings');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final response = await http.get(uri, headers: headers);
      debugPrint('🔹 GET /settings -> ${response.statusCode}');
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Get settings error: $e');
      return null;
    }
  }

  static Future<bool> updateThemeSetting({
    required bool darkMode,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/settings/theme');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final body = json.encode({'theme': darkMode ? 'dark' : 'light'});
      final response = await http.put(uri, headers: headers, body: body);
      debugPrint('🔹 PUT /settings/theme -> ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('❌ Update theme error: $e');
      return false;
    }
  }

  static Future<bool> updateNotificationSetting({
    required bool enabled,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/settings/notifications');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final body = json.encode({'enabled': enabled});
      final response = await http.put(uri, headers: headers, body: body);
      debugPrint('🔹 PUT /settings/notifications -> ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('❌ Update notifications error: $e');
      return false;
    }
  }

  static Future<bool> clearServerCache({
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/settings/clear-cache');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final response = await http.post(uri, headers: headers);
      debugPrint('🔹 POST /settings/clear-cache -> ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('❌ Clear server cache error: $e');
      return false;
    }
  }

  // ---------- فئات ----------
  static Future<List<Map<String, dynamic>>?> getCategories({
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/categories');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final response = await http.get(uri, headers: headers);
      debugPrint('🔹 GET /categories -> ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data['categories'] != null) {
          return (data['categories'] as List).cast<Map<String, dynamic>>();
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Get categories error: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>?> getServicesByCategory({
    required String categoryId,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/categories/$categoryId/services');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final response = await http.get(uri, headers: headers);
      debugPrint('🔹 GET /categories/$categoryId/services -> ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data['services'] != null) {
          return (data['services'] as List).cast<Map<String, dynamic>>();
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Get services by category error: $e');
      return null;
    }
  }
}