import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:daleel/providers/app_provider.dart';

/// ✅ شكل الرد الفعلي من GET /votes/{id} هو {upvotes, downvotes}
/// (مش List زي ما كانت getVotes القديمة بتفترض)
class VoteCounts {
  final int upVotes;
  final int downVotes;

  VoteCounts({this.upVotes = 0, this.downVotes = 0});

  factory VoteCounts.fromJson(Map<String, dynamic> json) {
    final up = json['upvotes'] ?? json['upVotes'];
    final down = json['downvotes'] ?? json['downVotes'];
    return VoteCounts(
      upVotes: (up as num?)?.toInt() ?? 0,
      downVotes: (down as num?)?.toInt() ?? 0,
    );
  }
}

class ApiService {
  static const String baseUrl = 'https://auth-login-for-daleel1.vercel.app';

  /// دالة مساعدة لبناء الهيدر مع التوكن
  /// - إذا كان التوكن يبدأ بـ "cookie_"، نرسل الكوكي ونستخدم نفس القيمة في Bearer
  /// - وإلا نرسل Bearer token كما هو
  static Map<String, String> _buildHeaders(String? token, {bool withContentType = true}) {
    final headers = <String, String>{};
    if (withContentType) {
      headers['Content-Type'] = 'application/json';
    }
    if (token != null && token.isNotEmpty) {
      if (token.startsWith('cookie_')) {
        final cookieValue = token.substring(7);
        // ✅ نرسل الكوكي بس - السيرفر بيستخدم session auth للكوكي
        // لا نبعت Authorization: Bearer هنا لأن السيرفر بيحاول يتحقق منها
        // كـ JWT حقيقي في الـ routes المحمية (زي POST /services) فبترفض
        // بـ "Invalid token" حتى لو الكوكي نفسها صحيحة
        headers['Cookie'] = 'connect.sid=$cookieValue';
      } else {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // ============================================================
  //                      الخدمات (SERVICES)
  // ============================================================

  static Future<List<Map<String, dynamic>>?> getServices({String? token}) async {
    try {
      final uri = Uri.parse('$baseUrl/services');
      final headers = _buildHeaders(token);
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

  static Future<List<Map<String, dynamic>>?> getPopularServices({String? token}) async {
    try {
      final uri = Uri.parse('$baseUrl/services/popular');
      final headers = _buildHeaders(token);
      final response = await http.get(uri, headers: headers);
      debugPrint('🔹 GET /services/popular -> ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data['data'] is List) {
          return (data['data'] as List).cast<Map<String, dynamic>>();
        } else if (data is Map && data['services'] != null) {
          return (data['services'] as List).cast<Map<String, dynamic>>();
        } else if (data is Map && data['popular'] != null) {
          return (data['popular'] as List).cast<Map<String, dynamic>>();
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Get popular services error: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>?> getPendingServices({String? token}) async {
    try {
      final uri = Uri.parse('$baseUrl/services/pending');
      final headers = _buildHeaders(token);
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

  static Future<ServiceItem?> createService({
    required Map<String, dynamic> data,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/services');
      final headers = _buildHeaders(token);
      debugPrint('🔑 Headers for createService: $headers');
      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(data),
      );
      debugPrint('🔹 POST /services -> ${response.statusCode}');
      debugPrint('📦 Response: ${response.body}');
      if (response.statusCode == 201 || response.statusCode == 200) {
        final dynamic body = json.decode(response.body);
        final serviceData = body['data'] ?? body;
        return ServiceItem.fromJson(serviceData as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Create service error: $e');
      return null;
    }
  }

  static Future<bool> updateService({
    required String serviceId,
    required Map<String, dynamic> data,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/services/$serviceId');
      final headers = _buildHeaders(token);
      final response = await http.put(
        uri,
        headers: headers,
        body: json.encode(data),
      );
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
      final headers = _buildHeaders(token);
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
      final headers = _buildHeaders(token);
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
      final headers = _buildHeaders(token);
      final response = await http.put(uri, headers: headers);
      debugPrint('🔹 PUT /services/$serviceId/reject -> ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('❌ Reject service error: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>?> getServicesByCategoryId({
    required String categoryId,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/categories/$categoryId/services');
      final headers = _buildHeaders(token);
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
      debugPrint('❌ Get services by category ID error: $e');
      return null;
    }
  }

  // ============================================================
  //                      التصويتات (VOTES)
  // ============================================================

  static Future<List<Map<String, dynamic>>?> getVotes({
    required String serviceId,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/votes/$serviceId');
      final headers = _buildHeaders(token);
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

  /// ✅ يقرأ شكل الرد الفعلي {upvotes, downvotes} من GET /votes/{id}
  /// بدل getVotes القديمة اللي كانت بتفترض إن الرد List من التعليقات
  static Future<VoteCounts?> getVoteCounts({
    required String serviceId,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/votes/$serviceId');
      final headers = _buildHeaders(token);
      final response = await http.get(uri, headers: headers);
      debugPrint('🔹 GET /votes/$serviceId (counts) -> ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          final inner = data['data'] is Map<String, dynamic> ? data['data'] as Map<String, dynamic> : data;
          return VoteCounts.fromJson(inner);
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Get vote counts error: $e');
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
      final headers = _buildHeaders(token);
      final body = json.encode({'vote_type': type});
      final response = await http.post(uri, headers: headers, body: body);
      debugPrint('🔹 POST /votes/$serviceId -> ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('❌ Post vote error: $e');
      return false;
    }
  }

  // ============================================================
  //                      الإعدادات (SETTINGS)
  // ============================================================

  static Future<Map<String, dynamic>?> getSettings({String? token}) async {
    try {
      final uri = Uri.parse('$baseUrl/settings');
      final headers = _buildHeaders(token);
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
      final headers = _buildHeaders(token);
      final body = json.encode({'dark_mode': darkMode});
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
      final headers = _buildHeaders(token);
      final body = json.encode({
        'notifications': enabled,
        'sound': true,
        'vibration': false,
      });
      final response = await http.put(uri, headers: headers, body: body);
      debugPrint('🔹 PUT /settings/notifications -> ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('❌ Update notifications error: $e');
      return false;
    }
  }

  static Future<bool> clearServerCache({String? token}) async {
    try {
      final uri = Uri.parse('$baseUrl/settings/clear-cache');
      final headers = _buildHeaders(token);
      final response = await http.post(uri, headers: headers);
      debugPrint('🔹 POST /settings/clear-cache -> ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('❌ Clear server cache error: $e');
      return false;
    }
  }

  // ============================================================
  //                      الفئات (CATEGORIES)
  // ============================================================

  static Future<List<Map<String, dynamic>>?> getCategories({String? token}) async {
    try {
      final uri = Uri.parse('$baseUrl/categories');
      final headers = _buildHeaders(token);
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

  // ============================================================
  //                      الدردشة الذكية (CHAT)
  // ============================================================

  static Future<Map<String, dynamic>?> sendChatMessage({
    required String message,
    String? sessionId,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/chat/message');
      final headers = _buildHeaders(token);
      final body = json.encode({
        'message': message,
        if (sessionId != null) 'sessionId': sessionId,
      });
      final response = await http.post(uri, headers: headers, body: body);
      debugPrint('🔹 POST /chat/message -> ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) return data;
        if (data is Map) return Map<String, dynamic>.from(data);
        return {'message': data.toString()};
      }
      return null;
    } catch (e) {
      debugPrint('❌ Send chat message error: $e');
      return null;
    }
  }
}