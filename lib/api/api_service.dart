import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://auth-login-for-daleel1.vercel.app';

  /// تحديث خدمة (مثلاً إرسال الخطوات المكتملة)
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

  /// حذف خدمة (مشوار) من الخادم
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

  /// الموافقة على خدمة
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

  /// رفض خدمة
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

  /// جلب كل الخدمات من السيرفر
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

  /// جلب الخدمات المعلقة (قيد المراجعة)
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

  /// جلب التعليقات / التصويتات لخدمة معينة
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

  /// إرسال تصويت (upvote/downvote) لخدمة
  static Future<bool> postVote({
    required String serviceId,
    required String type, // "up" أو "down"
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
}