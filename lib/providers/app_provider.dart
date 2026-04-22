import 'package:flutter/foundation.dart';

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
  final Map<String, List<ServiceItem>> _categories = {
    'الجيش': [
      ServiceItem(
        id: 'army_1',
        title: 'استخراج شهادة الموقف من التجنيد',
        description: 'احصل على شهادة موقفك من التجنيد بسهولة',
        category: 'الجيش',
        steps: '(4 خطوات)',
        author: 'عمر وحيد',
        source: 'مصدر موثوق',
        rating: 4.7,
        reviewCount: 8500,
        views: 12500,
      ),
      ServiceItem(
        id: 'army_2',
        title: 'تأجيل التجنيد للدراسة',
        description: 'تقديم طلب تأجيل التجنيد لاستكمال الدراسة',
        category: 'الجيش',
        steps: '(6 خطوات)',
        author: 'عمر وحيد',
        source: 'مصدر موثوق',
        rating: 4.5,
        reviewCount: 6200,
        views: 8900,
      ),
      ServiceItem(
        id: 'army_3',
        title: 'الإعفاء من التجنيد',
        description: 'معرفة شروط وإجراءات الإعفاء من الخدمة العسكرية',
        category: 'الجيش',
        steps: '(5 خطوات)',
        author: 'عمر وحيد',
        source: 'مصدر موثوق',
        rating: 4.3,
        reviewCount: 4800,
        views: 6700,
      ),
      ServiceItem(
        id: 'army_4',
        title: 'التطوع في القوات المسلحة',
        description: 'خطوات وشروط التقديم للتطوع في الجيش',
        category: 'الجيش',
        steps: '(8 خطوات)',
        author: 'عمر وحيد',
        source: 'مصدر موثوق',
        rating: 4.6,
        reviewCount: 3900,
        views: 5400,
      ),
    ],
    'التخرج الجامعي': [
      ServiceItem(
        id: 'grad_1',
        title: 'استخراج شهادة التخرج',
        description: 'الحصول على شهادة التخرج الجامعية',
        category: 'التخرج الجامعي',
        steps: '(5 خطوات)',
        author: 'عمر وحيد',
        source: 'مصدر موثوق',
        rating: 4.8,
        reviewCount: 11000,
        views: 15200,
      ),
      ServiceItem(
        id: 'grad_2',
        title: 'توثيق الشهادة من الخارجية',
        description: 'توثيق شهادتك الجامعية للعمل بالخارج',
        category: 'التخرج الجامعي',
        steps: '(7 خطوات)',
        author: 'عمر وحيد',
        source: 'مصدر موثوق',
        rating: 4.6,
        reviewCount: 7100,
        views: 9800,
      ),
      ServiceItem(
        id: 'grad_3',
        title: 'استخراج كارنيه الخريجين',
        description: 'الحصول على بطاقة خريجي الجامعات',
        category: 'التخرج الجامعي',
        steps: '(4 خطوات)',
        author: 'عمر وحيد',
        source: 'مصدر موثوق',
        rating: 4.4,
        reviewCount: 5200,
        views: 7300,
      ),
      ServiceItem(
        id: 'grad_4',
        title: 'معادلة الشهادة',
        description: 'معادلة الشهادات الجامعية من الخارج',
        category: 'التخرج الجامعي',
        steps: '(9 خطوات)',
        author: 'عمر وحيد',
        source: 'مصدر موثوق',
        rating: 4.5,
        reviewCount: 4400,
        views: 6100,
      ),
    ],
    'الزواج': [
      ServiceItem(
        id: 'marriage_1',
        title: 'استخراج شهادة ميلاد للزواج',
        description: 'الحصول على شهادة ميلاد مميكنة للزواج',
        category: 'الزواج',
        steps: '(3 خطوات)',
        author: 'عمر وحيد',
        source: 'مصدر موثوق',
        rating: 4.9,
        reviewCount: 13500,
        views: 18700,
      ),
      ServiceItem(
        id: 'marriage_2',
        title: 'عقد القران',
        description: 'خطوات إتمام عقد القران رسمياً',
        category: 'الزواج',
        steps: '(10 خطوات)',
        author: 'عمر وحيد',
        source: 'مصدر موثوق',
        rating: 4.8,
        reviewCount: 11700,
        views: 16200,
      ),
      ServiceItem(
        id: 'marriage_3',
        title: 'توثيق عقد الزواج',
        description: 'توثيق عقد الزواج في الشهر العقاري',
        category: 'الزواج',
        steps: '(6 خطوات)',
        author: 'عمر وحيد',
        source: 'مصدر موثوق',
        rating: 4.7,
        reviewCount: 9800,
        views: 13500,
      ),
      ServiceItem(
        id: 'marriage_4',
        title: 'استخراج كتاب تحديد سن للزواج',
        description: 'الحصول على كتاب تحديد السن من المحكمة',
        category: 'الزواج',
        steps: '(5 خطوات)',
        author: 'عمر وحيد',
        source: 'مصدر موثوق',
        rating: 4.6,
        reviewCount: 6800,
        views: 9400,
      ),
    ],
    'ترخيص السيارات': [
      ServiceItem(
        id: 'car_1',
        title: 'تجديد رخصة السيارة',
        description: 'تجديد رخصة تسيير السيارة السنوية',
        category: 'ترخيص السيارات',
        steps: '(5 خطوات)',
        author: 'عمر وحيد',
        source: 'مصدر موثوق',
        rating: 4.7,
        reviewCount: 16000,
        views: 22100,
      ),
      ServiceItem(
        id: 'car_2',
        title: 'نقل ملكية السيارة',
        description: 'إجراءات نقل ملكية المركبة',
        category: 'ترخيص السيارات',
        steps: '(8 خطوات)',
        author: 'عمر وحيد',
        source: 'مصدر موثوق',
        rating: 4.5,
        reviewCount: 10700,
        views: 14800,
      ),
      ServiceItem(
        id: 'car_3',
        title: 'استخراج رخصة قيادة',
        description: 'الحصول على رخصة قيادة جديدة',
        category: 'ترخيص السيارات',
        steps: '(12 خطوة)',
        author: 'عمر وحيد',
        source: 'مصدر موثوق',
        rating: 4.8,
        reviewCount: 14100,
        views: 19500,
      ),
      ServiceItem(
        id: 'car_4',
        title: 'فحص السيارة الدوري',
        description: 'حجز موعد فحص السيارة السنوي',
        category: 'ترخيص السيارات',
        steps: '(4 خطوات)',
        author: 'عمر وحيد',
        source: 'مصدر موثوق',
        rating: 4.6,
        reviewCount: 8100,
        views: 11200,
      ),
    ],
    'السفر للخارج': [
      ServiceItem(
        id: 'travel_1',
        title: 'استخراج جواز سفر جديد',
        description: 'الحصول على جواز سفر مصري',
        category: 'السفر للخارج',
        steps: '(7 خطوات)',
        author: 'عمر وحيد',
        source: 'مصدر موثوق',
        rating: 4.8,
        reviewCount: 18500,
        views: 25600,
      ),
      ServiceItem(
        id: 'travel_2',
        title: 'تجديد جواز السفر',
        description: 'تجديد جواز السفر المنتهي',
        category: 'السفر للخارج',
        steps: '(6 خطوات)',
        author: 'عمر وحيد',
        source: 'مصدر موثوق',
        rating: 4.7,
        reviewCount: 13700,
        views: 18900,
      ),
      ServiceItem(
        id: 'travel_3',
        title: 'استخراج فيزا شنغن',
        description: 'خطوات الحصول على فيزا دول شنغن',
        category: 'السفر للخارج',
        steps: '(15 خطوة)',
        author: 'عمر وحيد',
        source: 'مصدر موثوق',
        rating: 4.5,
        reviewCount: 12100,
        views: 16700,
      ),
      ServiceItem(
        id: 'travel_4',
        title: 'تصريح السفر للخارج',
        description: 'استخراج تصريح السفر للخارج',
        category: 'السفر للخارج',
        steps: '(5 خطوات)',
        author: 'عمر وحيد',
        source: 'مصدر موثوق',
        rating: 4.6,
        reviewCount: 8900,
        views: 12300,
      ),
    ],
  };

  Map<String, List<ServiceItem>> get categories => _categories;

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

  void addUserService(ServiceItem service) {
    if (_categories.containsKey(service.category)) {
      _categories[service.category]!.insert(0, service);
    } else {
      _categories[service.category] = [service];
    }
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