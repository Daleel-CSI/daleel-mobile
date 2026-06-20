// lib/utils/category_icons.dart
//
// ✅ السيرفر لا يرجع حقل "icon" ضمن استجابة GET /categories
// (الاستجابة الفعلية تحتوي فقط على category_id و category_name).
// لذلك تم بناء هذا الـ mapping محلياً لربط كل category_id
// بأيقونة SVG حقيقية موجودة فعلاً داخل assets/icons.
//
// أي category_id جديد يضيفه السيرفر ولم يُدرج هنا بعد
// سيستخدم الأيقونة الاحتياضية (fallback) تلقائياً، بدون أي كراش.

class CategoryIcons {
  CategoryIcons._();

  /// الأيقونة الاحتياطية (Fallback) لأي فئة غير معرّفة في الخريطة
  static const String fallback = 'assets/icons/file-02.svg';

  /// خريطة ثابتة: category_id -> مسار الأيقونة الفعلي
  static const Map<String, String> _map = {
    // ===== فئات لها أيقونة دلالية مطابقة بدقة =====
    'driving_licenses': 'assets/icons/car_license.svg',
    'higher_education': 'assets/icons/graduation.svg',
    'education': 'assets/icons/graduation.svg.svg',
    'al_azhar': 'assets/icons/graduation.svg',
    'civil_defense': 'assets/icons/army.svg',
    'police_security': 'assets/icons/army.svg',
    'public_prosecution': 'assets/icons/army.svg',
    'housing': 'assets/icons/home.svg',
    'local_administration': 'assets/icons/home.svg',
    'family_childhood': 'assets/icons/who.svg',
    'social_solidarity': 'assets/icons/who.svg',
    'consular_services': 'assets/icons/language-circle.svg',
    'egyptians_abroad': 'assets/icons/language-circle.svg',
    'religious_affairs': 'assets/icons/information-circle.svg',
    'notarization': 'assets/icons/file-02.svg',
    'advanced_court_services': 'assets/icons/file-02.svg',
    'justice': 'assets/icons/file-02.svg',
    'commercial_registry': 'assets/icons/file-02.svg',
    'banking_services': 'assets/icons/smart-phone-01.svg',
    'telecommunications': 'assets/icons/smart-phone-03.svg',

    // ===== فئات استُخدمت لها أيقونات Container كأرقام مميزة لكل فئة =====
    'civil_status': 'assets/icons/Container-2.svg',
    'supply_cards': 'assets/icons/Container-4.svg',
    'passports': 'assets/icons/Container-5.svg',
    'property_tax': 'assets/icons/Container-6.svg',
    'water_sanitation': 'assets/icons/Container-7.svg',
    'natural_gas': 'assets/icons/Container-8.svg',
    'electricity': 'assets/icons/Container-9.svg',
    'social_insurance': 'assets/icons/Container-10.svg',
    'labor_manpower': 'assets/icons/Container-11.svg',
    'agriculture': 'assets/icons/Container-12.svg',
    'health': 'assets/icons/Container-13.svg',
    'taxes': 'assets/icons/Container-14.svg',
    'customs': 'assets/icons/Container-15.svg',
    'youth_sports': 'assets/icons/Container-16.svg',
  };

  /// إرجاع مسار الأيقونة المناسب لـ category_id، أو الأيقونة الاحتياطية
  static String resolve(String categoryId) {
    return _map[categoryId] ?? fallback;
  }
}