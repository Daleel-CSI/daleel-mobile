import 'package:daleel/categorie_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:daleel/api/api_service.dart';

// ==================== Models ====================

class ServiceItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final String steps;
  final String author;
  final String source;
  final double rating;
  final int reviewCount;
  final int views;
  final double? price;
  final List<String> requiredDocuments;
  bool isSaved;

  ServiceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.steps,
    required this.author,
    required this.source,
    required this.rating,
    required this.reviewCount,
    required this.views,
    this.price,
    this.requiredDocuments = const [],
    this.isSaved = false,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final requiredDocumentsRaw = data is Map ? data['required_documents'] : null;
    final docsSource = json['steps'] ?? requiredDocumentsRaw;

    return ServiceItem(
      id: (json['_id'] ?? json['id'] ?? json['service_id'])?.toString() ?? '',
      title: json['title'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      category:
          json['category'] ??
          json['category_name'] ??
          json['category_id'] ??
          'أخرى',
      steps: json['steps'] is String
          ? json['steps']
          : _parseSteps(docsSource),
      author: json['author'] ?? 'دليل',
      source: json['source'] ?? json['category_name'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      views: (json['views'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble(),
      // ✅ المستندات المطلوبة الحقيقية القادمة من السيرفر (إن وُجدت)
      // تُستخدم لاحقاً في شاشة تفاصيل الخدمة بدل البيانات الوهمية
      requiredDocuments: docsSource is List
          ? docsSource.map((e) => e.toString()).toList()
          : const [],
      isSaved: json['isSaved'] == true,
    );
  }

  static String _parseSteps(dynamic steps) {
    if (steps is int) {
      return '($steps ${steps == 1 ? 'خطوة' : 'خطوات'})';
    } else if (steps is List) {
      return '(${steps.length} ${steps.length == 1 ? 'خطوة' : 'خطوات'})';
    }
    return '(0 خطوات)';
  }
}

class Trip {
  final String id;
  final String title;
  final String date;
  final String category;
  final int completedSteps;
  final int totalSteps;
  final String currentStep;
  final String placeName;
  final String? description;
  final String? governorate;
  final String? city;
  final List<TripStepData> steps;

  Trip({
    required this.id,
    required this.title,
    required this.date,
    required this.category,
    required this.completedSteps,
    required this.totalSteps,
    required this.currentStep,
    required this.placeName,
    this.description,
    this.governorate,
    this.city,
    required this.steps,
  });
}

class TripStepData {
  final String title;
  final String description;

  TripStepData({required this.title, required this.description});
}

class Category {
  final String id;
  final String name;
  final String iconPath;

  Category({required this.id, required this.name, required this.iconPath});

  factory Category.fromJson(Map<String, dynamic> json) {
    final id =
        (json['_id'] ?? json['category_id'] ?? json['id'])?.toString() ?? '';
    return Category(
      id: id,
      name: json['name'] ?? json['category_name'] ?? id,
      // ✅ السيرفر لا يرجع حقل icon فعلياً (تأكدنا من الاستجابة الحقيقية)
      // لذلك نستخدم mapping محلي ثابت بناءً على category_id
      // مع fallback تلقائي لأي فئة غير معرّفة في الخريطة
      iconPath: CategoryIcons.resolve(id),
    );
  }
}

// ==================== Services Provider ====================

class ServicesProvider with ChangeNotifier {
  final Map<String, List<ServiceItem>> _categories = {};
  bool _isLoading = false;

  Map<String, List<ServiceItem>> get categories => _categories;
  bool get isLoading => _isLoading;

  // قائمة الفئات الديناميكية (من GET /categories)
  List<Category> _categoriesList = [];
  List<Category> get categoriesList => _categoriesList;

  /// تحميل الخدمات من السيرفر (GET /services)
  Future<void> fetchAndSetServices({String? token}) async {
    _isLoading = true;
    notifyListeners();

    final servicesJson = await ApiService.getServices(token: token);
    if (servicesJson == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    final Map<String, List<ServiceItem>> newCategories = {};
    for (final json in servicesJson) {
      final service = ServiceItem.fromJson(json);
      newCategories.putIfAbsent(service.category, () => []).add(service);
    }

    _categories.clear();
    _categories.addAll(newCategories);

    _isLoading = false;
    notifyListeners();
  }

  /// تحميل الفئات من الخادم (GET /categories)
  Future<void> fetchCategories({String? token}) async {
    final catsJson = await ApiService.getCategories(token: token);
    if (catsJson == null) return;
    _categoriesList = catsJson.map((json) => Category.fromJson(json)).toList();
    notifyListeners();
  }

  List<ServiceItem> getServicesForCategory(String category) {
    return _categories[category] ?? [];
  }

  void toggleSaveService(String serviceId) {
    for (var category in _categories.values) {
      for (var service in category) {
        if (service.id == serviceId) {
          service.isSaved = !service.isSaved;
          notifyListeners();
          return;
        }
      }
    }
  }

  List<ServiceItem> get allServices {
    List<ServiceItem> all = [];
    for (var category in _categories.values) {
      all.addAll(category);
    }
    return all;
  }

  void addServiceLocally(ServiceItem service) {
    if (_categories.containsKey(service.category)) {
      _categories[service.category]!.insert(0, service);
    } else {
      _categories[service.category] = [service];
    }
    notifyListeners();
  }

  void addUserService(ServiceItem service) {
    addServiceLocally(service);
  }
}

// ==================== Trips Provider ====================

class TripsProvider with ChangeNotifier {
  final List<Trip> _trips = [];

  List<Trip> get trips => _trips;
  List<Trip> get savedTrips => _trips;

  void addTrip(Trip trip) {
    _trips.insert(0, trip);
    notifyListeners();
  }

  void removeTrip(String tripId) {
    _trips.removeWhere((trip) => trip.id == tripId);
    notifyListeners();
  }

  void updateTripProgress(String tripId, int completedSteps) {
    notifyListeners();
  }
}