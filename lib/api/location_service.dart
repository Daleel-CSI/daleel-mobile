import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class LocationService {
  static const String baseUrl = 'https://daleel-eosin.vercel.app/api/locations';

  /// جلب جميع المحافظات مع fallback في حال فشل الـ API
  static Future<List<Governorate>> getGovernorates() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/governorate'),
      ).timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        print('📡 Status Code: ${response.statusCode}');
        print('📦 Response Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
      }

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        List<dynamic> items = [];

        if (data is List) {
          items = data;
        } else if (data is Map && data.containsKey('data')) {
          items = data['data'];
        } else {
          // إذا كان التنسيق غير متوقع، نستخدم fallback
          if (kDebugMode) {
            print('⚠️ Unexpected data format, using fallback list');
          }
          return _getFallbackGovernorates();
        }

        if (items.isEmpty) {
          return _getFallbackGovernorates();
        }

        return items.map((json) => Governorate.fromJson(json)).toList();
      } else {
        // إذا فشل الـ API، نستخدم fallback
        if (kDebugMode) {
          print('⚠️ API returned ${response.statusCode}, using fallback');
        }
        return _getFallbackGovernorates();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading governorates: $e');
      }
      // في حالة أي خطأ (اتصال، timeout، إلخ) نستخدم fallback
      return _getFallbackGovernorates();
    }
  }

  /// جلب المدن الخاصة بمحافظة معينة
  static Future<List<City>> getCities(int governorateId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cities/$governorateId'),
      ).timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        print('📡 Cities Status Code: ${response.statusCode}');
        print('📦 Cities Response: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
      }

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        List<dynamic> items = [];

        if (data is List) {
          items = data;
        } else if (data is Map && data.containsKey('data')) {
          items = data['data'];
        } else {
          return [];
        }

        return items.map((json) => City.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Cities Error: $e');
      }
      return [];
    }
  }

  // ========== قائمة احتياطية للمحافظات (في حال فشل الـ API) ==========
  static List<Governorate> _getFallbackGovernorates() {
    return [
      Governorate(id: 1, name: 'القاهرة'),
      Governorate(id: 2, name: 'الإسكندرية'),
      Governorate(id: 3, name: 'بورسعيد'),
      Governorate(id: 4, name: 'السويس'),
      Governorate(id: 5, name: 'دمياط'),
      Governorate(id: 6, name: 'الدقهلية'),
      Governorate(id: 7, name: 'الشرقية'),
      Governorate(id: 8, name: 'القليوبية'),
      Governorate(id: 9, name: 'كفر الشيخ'),
      Governorate(id: 10, name: 'الغربية'),
      Governorate(id: 11, name: 'المنوفية'),
      Governorate(id: 12, name: 'البحيرة'),
      Governorate(id: 13, name: 'الإسماعيلية'),
      Governorate(id: 14, name: 'الجيزة'),
      Governorate(id: 15, name: 'بنى سويف'),
      Governorate(id: 16, name: 'الفيوم'),
      Governorate(id: 17, name: 'المنيا'),
      Governorate(id: 18, name: 'أسيوط'),
      Governorate(id: 19, name: 'سوهاج'),
      Governorate(id: 20, name: 'قنا'),
      Governorate(id: 21, name: 'الأقصر'),
      Governorate(id: 22, name: 'أسوان'),
      Governorate(id: 23, name: 'البحر الأحمر'),
      Governorate(id: 24, name: 'الوادي الجديد'),
      Governorate(id: 25, name: 'مطروح'),
      Governorate(id: 26, name: 'شمال سيناء'),
      Governorate(id: 27, name: 'جنوب سيناء'),
    ];
  }
}

// ============================================================
//                      Models
// ============================================================

/// Model للمحافظة
class Governorate {
  final int id;
  final String name;

  Governorate({
    required this.id,
    required this.name,
  });

  factory Governorate.fromJson(Map<String, dynamic> json) {
    try {
      // محاولة استخراج الاسم من عدة حقول محتملة
      final name = json['governorate_name_ar']?.toString() ??
          json['name']?.toString() ??
          json['governorate_name_en']?.toString() ??
          '';

      final id = json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0;

      return Governorate(id: id, name: name);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error parsing Governorate: $e');
      }
      // في حالة خطأ في التحليل، نرجع كيان افتراضي
      return Governorate(id: 0, name: 'غير معروف');
    }
  }

  @override
  String toString() => name;
}

/// Model للمدينة
class City {
  final int id;
  final String name;
  final int governorateId;

  City({
    required this.id,
    required this.name,
    required this.governorateId,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    try {
      final name = json['city_name_ar']?.toString() ??
          json['name']?.toString() ??
          json['city_name_en']?.toString() ??
          '';

      final id = json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0;

      final governorateId = json['governorate_id'] is int
          ? json['governorate_id']
          : int.tryParse(json['governorate_id'].toString()) ?? 0;

      return City(id: id, name: name, governorateId: governorateId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error parsing City: $e');
      }
      return City(id: 0, name: 'غير معروف', governorateId: 0);
    }
  }

  @override
  String toString() => name;
}