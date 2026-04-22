import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  static const String baseUrl = 'https://daleel-eosin.vercel.app/api/locations';

  /// جلب جميع المحافظات
  static Future<List<Governorate>> getGovernorates() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/governorate'),
      );

      print('📡 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body.substring(0, 200)}...');

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        
        print('📊 Data Type: ${data.runtimeType}');
        
        // التحقق من نوع البيانات
        if (data is List) {
          print('✅ Data is a List with ${data.length} items');
          return data.map((json) => Governorate.fromJson(json)).toList();
        } else if (data is Map && data.containsKey('data')) {
          print('✅ Data is a Map with key "data"');
          final List<dynamic> items = data['data'];
          print('📊 Items count: ${items.length}');
          return items.map((json) => Governorate.fromJson(json)).toList();
        } else {
          print('❌ Unexpected data format');
          throw Exception('تنسيق البيانات غير متوقع');
        }
      } else {
        throw Exception('فشل في تحميل المحافظات: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
  }

  /// جلب المدن الخاصة بمحافظة معينة
  static Future<List<City>> getCities(int governorateId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cities/$governorateId'),
      );

      print('📡 Cities Status Code: ${response.statusCode}');
      print('📦 Cities Response: ${response.body.substring(0, min(200, response.body.length))}...');

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        
        print('📊 Cities Data Type: ${data.runtimeType}');
        
        if (data is List) {
          print('✅ Cities data is a List with ${data.length} items');
          return data.map((json) => City.fromJson(json)).toList();
        } else if (data is Map && data.containsKey('data')) {
          print('✅ Cities data is a Map with key "data"');
          final List<dynamic> items = data['data'];
          print('📊 Cities count: ${items.length}');
          return items.map((json) => City.fromJson(json)).toList();
        } else {
          print('❌ Unexpected cities data format');
          throw Exception('تنسيق البيانات غير متوقع');
        }
      } else {
        throw Exception('فشل في تحميل المدن: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Cities Error: $e');
      rethrow;
    }
  }
}

int min(int a, int b) => a < b ? a : b;

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
      print('🔄 Parsing Governorate: $json');
      final gov = Governorate(
        id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
        name: json['governorate_name_ar']?.toString() ?? 
              json['name']?.toString() ?? 
              json['governorate_name_en']?.toString() ?? '',
      );
      print('✅ Parsed: id=${gov.id}, name="${gov.name}"');
      return gov;
    } catch (e) {
      print('❌ Error parsing Governorate: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
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
      print('🔄 Parsing City: $json');
      final city = City(
        id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
        name: json['city_name_ar']?.toString() ?? 
              json['name']?.toString() ?? 
              json['city_name_en']?.toString() ?? '',
        governorateId: json['governorate_id'] is int 
            ? json['governorate_id'] 
            : int.parse(json['governorate_id'].toString()),
      );
      print('✅ Parsed City: id=${city.id}, name="${city.name}", govId=${city.governorateId}');
      return city;
    } catch (e) {
      print('❌ Error parsing City: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'governorate_id': governorateId,
    };
  }
  
  @override
  String toString() => name;
}