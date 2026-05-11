import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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
    this.isSaved = false,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      steps: json['steps']?.toString() ?? '(0 خطوات)',
      author: json['author'] ?? '',
      source: json['source'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: (json['reviewCount'] ?? 0).toInt(),
      views: (json['views'] ?? 0).toInt(),
    );
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

  TripStepData({
    required this.title,
    required this.description,
  });
}

// ==================== Services Provider ====================
class ServicesProvider with ChangeNotifier {
  final Map<String, List<ServiceItem>> _categories = {};
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, List<ServiceItem>> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchServices(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final url = Uri.parse('https://auth-login-for-daleel1.vercel.app/services');
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'] ?? json.decode(response.body);
        final services = data.map((item) => ServiceItem.fromJson(item)).toList();

        _categories.clear();
        for (var service in services) {
          _categories.putIfAbsent(service.category, () => []);
          _categories[service.category]!.add(service);
        }
        _errorMessage = null;
      } else {
        _errorMessage = 'فشل تحميل الخدمات';
      }
    } catch (e) {
      _errorMessage = 'خطأ في الاتصال';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  List<ServiceItem> getServicesForCategory(String category) {
    return _categories[category] ?? [];
  }

  void addServiceLocally(ServiceItem service) {
    _categories.putIfAbsent(service.category, () => []);
    _categories[service.category]!.insert(0, service);
    notifyListeners();
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
    final tripIndex = _trips.indexWhere((trip) => trip.id == tripId);
    if (tripIndex != -1) {
      notifyListeners();
    }
  }
}