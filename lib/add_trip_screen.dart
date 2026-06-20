// ignore_for_file: unused_field

import 'package:daleel/api/location_service.dart';
import 'package:daleel/providers/app_provider.dart';
import 'package:daleel/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:daleel/api/api_service.dart';

class AddTripScreen extends StatefulWidget {
  final String userName;

  const AddTripScreen({
    super.key,
    required this.userName,
  });

  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Page Controller
  int _currentStep = 0;
  late PageController _pageController;
  late AnimationController _progressController;

  // Controllers للصفحة الأولى
  final TextEditingController _tripNameController = TextEditingController();
  final TextEditingController _placeNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // الفئات (من الـ API)
  List<Category> _availableCategories = [];
  String? _selectedCategoryId;

  // Dropdown values
  Governorate? _selectedGovernorate;
  City? _selectedCity;
  DateTime? _selectedDate;

  // Location
  String? _currentLocation;
  double? _latitude;
  double? _longitude;

  // Files
  final List<PlatformFile> _selectedFiles = [];

  // الخطوات (الصفحة الثانية)
  final List<TripStep> _tripSteps = [];

  // القوائم من API
  List<Governorate> _governorates = [];
  List<City> _cities = [];
  bool _isLoadingGovernorates = false;
  bool _isLoadingCities = false;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadCategories();
    _loadGovernorates();
    _checkLocationPermission();
  }

  // ========== التحقق من أذونات الموقع مسبقاً ==========
  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  // ========== تحميل الفئات ==========
  Future<void> _loadCategories() async {
    final provider = context.read<ServicesProvider>();
    if (provider.categoriesList.isEmpty) {
      final token = context.read<UserProvider>().user.token;
      await provider.fetchCategories(token: token);
    }
    if (mounted) {
      setState(() {
        _availableCategories = provider.categoriesList;
      });
    }
  }

  // ========== تحميل المحافظات (مع Fallback) ==========
  Future<void> _loadGovernorates() async {
    if (!mounted) return;
    setState(() => _isLoadingGovernorates = true);

    try {
      final governorates = await LocationService.getGovernorates();
      if (!mounted) return;
      setState(() {
        _governorates = governorates;
        _isLoadingGovernorates = false;
      });
      if (governorates.isEmpty && mounted) {
        _showSnackBar('تم تحميل المحافظات من القائمة الاحتياطية', isError: false);
      }
    } catch (e) {
      if (!mounted) return;
      final fallback = await LocationService.getGovernorates();
      if (mounted) {
        setState(() {
          _governorates = fallback;
          _isLoadingGovernorates = false;
        });
        _showSnackBar('تعذر الاتصال بالخادم، تم تحميل قائمة احتياطية', isError: true);
      }
    }
  }

  // ========== جلب المدن (مع Fallback) ==========
  Future<void> _loadCities(int governorateId) async {
    if (!mounted) return;

    setState(() {
      _isLoadingCities = true;
      _selectedCity = null;
      _cities = [];
    });

    try {
      final cities = await LocationService.getCities(governorateId);
      if (!mounted) return;
      
      if (cities.isEmpty) {
        setState(() {
          _cities = _getFallbackCities(governorateId);
          _isLoadingCities = false;
        });
        _showSnackBar('تم تحميل المدن من القائمة الاحتياطية', isError: false);
      } else {
        setState(() {
          _cities = cities;
          _isLoadingCities = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cities = _getFallbackCities(governorateId);
        _isLoadingCities = false;
      });
      _showSnackBar('فشل تحميل المدن، تم استخدام قائمة احتياطية', isError: true);
    }
  }

  // ========== قائمة مدن احتياطية ==========
  List<City> _getFallbackCities(int governorateId) {
    final Map<int, List<String>> fallbackCities = {
      1: ['القاهرة', 'العباسية', 'مدينة نصر', 'مصر الجديدة', 'المعادي', 'حلوان', 'الزمالك', 'جاردن سيتي'],
      2: ['الإسكندرية', 'المنتزه', 'سيدي جابر', 'محرم بك', 'الأنفوشي', 'العجمي', 'برج العرب'],
      3: ['بورسعيد', 'الشرق', 'الغرب', 'الضواحي'],
      4: ['السويس', 'الأربعين', 'عتاقة', 'فيصل'],
      5: ['دمياط', 'رأس البر', 'عزبة البرج', 'فارسكور'],
      6: ['الدقهلية', 'المنصورة', 'طلخا', 'ميت غمر', 'أجا', 'دكرنس', 'شربين'],
      7: ['الشرقية', 'الزقازيق', 'بلبيس', 'أبو كبير', 'ههيا', 'ديرب نجم', 'فاقوس', 'منيا القمح'],
      8: ['القليوبية', 'بنها', 'شبرا الخيمة', 'قليوب', 'الخانكة', 'القناطر الخيرية'],
      9: ['كفر الشيخ', 'بلطيم', 'مطوبس', 'سيدي سالم', 'دسوق'],
      10: ['الغربية', 'طنطا', 'المحلة الكبرى', 'زفتى', 'بسيون', 'كفر الزيات'],
      11: ['المنوفية', 'شبين الكوم', 'السادات', 'منوف', 'أشمون', 'الباجور'],
      12: ['البحيرة', 'دمنهور', 'كفر الدوار', 'رشيد', 'إدفينا', 'حوش عيسى'],
      13: ['الإسماعيلية', 'التل الكبير', 'القنطرة', 'فايد', 'أبو صوير'],
      14: ['الجيزة', 'الهرم', 'الدقي', 'المهندسين', 'أكتوبر', 'الشيخ زايد', 'البدرشين', 'الصف'],
      15: ['بني سويف', 'الواسطى', 'ناصر', 'إهناسيا', 'ببا', 'الفشن'],
      16: ['الفيوم', 'سنورس', 'إطسا', 'يوسف الصديق', 'طامية'],
      17: ['المنيا', 'مغاغة', 'بني مزار', 'مطاي', 'سمالوط', 'أبو قرقاص'],
      18: ['أسيوط', 'ديروط', 'البداري', 'منفلوط', 'القوصية', 'أبنوب'],
      19: ['سوهاج', 'أخميم', 'جرجا', 'المنشأة', 'طهطا', 'البلينا'],
      20: ['قنا', 'نقادة', 'فرشوط', 'قفط', 'الوقف', 'أبو تشت'],
      21: ['الأقصر', 'البياضية', 'الكرنك', 'إسنا', 'أرمنت', 'الطود'],
      22: ['أسوان', 'إدفو', 'السباعية', 'كوم أمبو', 'نصر النوبة'],
      23: ['البحر الأحمر', 'الغردقة', 'رأس غارب', 'سفاجا', 'القصير', 'مرسى علم'],
      24: ['الوادي الجديد', 'الخارجة', 'الداخلة', 'الفرافرة', 'بلاط'],
      25: ['مطروح', 'مرسى مطروح', 'الضبعة', 'العلمين', 'الحمام'],
      26: ['شمال سيناء', 'العريش', 'الشيخ زويد', 'رفح'],
      27: ['جنوب سيناء', 'الطور', 'نويبع', 'دهب', 'سانت كاترين', 'شرم الشيخ'],
    };

    final cities = fallbackCities[governorateId] ?? ['مدينة غير معروفة'];
    return cities.map((name) => City(
      id: cities.indexOf(name) + 1,
      name: name,
      governorateId: governorateId,
    )).toList();
  }

  @override
  void dispose() {
    _tripNameController.dispose();
    _placeNameController.dispose();
    _descriptionController.dispose();
    _pageController.dispose();
    _progressController.dispose();
    for (var step in _tripSteps) {
      step.titleController.dispose();
      step.descriptionController.dispose();
    }
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_currentStep == 1) {
      _previousStep();
      return false;
    }

    if (_tripNameController.text.isNotEmpty ||
        _placeNameController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty ||
        _selectedCategoryId != null ||
        _selectedFiles.isNotEmpty ||
        _tripSteps.isNotEmpty) {
      return await _showExitDialog();
    }
    return true;
  }

  Future<bool> _showExitDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => ScaleTransition(
            scale: CurvedAnimation(
              parent: ModalRoute.of(context)!.animation!,
              curve: Curves.easeOutBack,
            ),
            child: AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: EdgeInsets.zero,
              content: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).cardColor,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF379777).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFF379777),
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'تأكيد الخروج',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'هل أنت متأكد من الخروج؟\nسيتم فقدان جميع البيانات المدخلة.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'إلغاء',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'خروج',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ) ??
        false;
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_formKey.currentState!.validate()) return;

      if (_selectedCategoryId == null) {
        _showSnackBar('يرجى اختيار القسم', isError: true);
        return;
      }
      if (_selectedGovernorate == null) {
        _showSnackBar('يرجى اختيار المحافظة', isError: true);
        return;
      }
      if (_selectedCity == null) {
        _showSnackBar('يرجى اختيار المدينة', isError: true);
        return;
      }
      if (_selectedDate == null) {
        _showSnackBar('يرجى اختيار التاريخ', isError: true);
        return;
      }

      setState(() {
        _currentStep = 1;
      });
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      _progressController.animateTo(1.0);
    }
  }

  void _previousStep() {
    if (_currentStep == 1) {
      setState(() {
        _currentStep = 0;
      });
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      _progressController.animateTo(0.0);
    }
  }

  void _addStep() {
    if (_tripSteps.length >= 10) {
      _showSnackBar('لا يمكن إضافة أكثر من 10 خطوات', isError: true);
      return;
    }
    setState(() {
      _tripSteps.add(TripStep(
        titleController: TextEditingController(),
        descriptionController: TextEditingController(),
      ));
    });
  }

  void _removeStep(int index) {
    setState(() {
      _tripSteps[index].titleController.dispose();
      _tripSteps[index].descriptionController.dispose();
      _tripSteps.removeAt(index);
    });
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      );

      if (result != null) {
        for (var file in result.files) {
          if (file.size > 5 * 1024 * 1024) {
            _showSnackBar('حجم الملف ${file.name} أكبر من 5 ميجا', isError: true);
            return;
          }
        }
        setState(() {
          _selectedFiles.addAll(result.files);
        });
      }
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء اختيار الملفات', isError: true);
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  // ========== الحصول على الموقع الحالي ==========
  Future<void> _getCurrentLocation() async {
    if (_isGettingLocation) return;
    setState(() => _isGettingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('يرجى تشغيل خدمة الموقع من إعدادات الجهاز', isError: true);
        setState(() => _isGettingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('تم رفض إذن الموقع، يرجى منح الإذن من إعدادات الجهاز', isError: true);
          setState(() => _isGettingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('تم رفض إذن الموقع نهائياً، يرجى تعديل الإعدادات', isError: true);
        setState(() => _isGettingLocation = false);
        return;
      }

      _showSnackBar('جاري الحصول على الموقع...', isError: false);
      
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks[0];
        String address = '';
        List<String> parts = [];
        if (place.street != null && place.street!.isNotEmpty) parts.add(place.street!);
        if (place.subLocality != null && place.subLocality!.isNotEmpty) parts.add(place.subLocality!);
        if (place.locality != null && place.locality!.isNotEmpty) parts.add(place.locality!);
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) parts.add(place.administrativeArea!);
        if (parts.isNotEmpty) {
          address = parts.join(', ');
        } else {
          address = 'موقع حالي (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
        }

        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _currentLocation = address;
          _isGettingLocation = false;
        });
        
        _showSnackBar('تم الحصول على الموقع بنجاح ✅', isError: false);
      } else {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _currentLocation = 'موقع حالي (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
          _isGettingLocation = false;
        });
        _showSnackBar('تم الحصول على الإحداثيات ولكن لم يتم العثور على عنوان', isError: true);
      }
    } catch (e) {
      setState(() => _isGettingLocation = false);
      String errorMsg = 'حدث خطأ أثناء الحصول على الموقع';
      if (e.toString().contains('PERMISSION_DENIED')) {
        errorMsg = 'تم رفض إذن الموقع، يرجى منح الإذن من إعدادات الجهاز';
      } else if (e.toString().contains('LOCATION_SERVICE_DISABLED')) {
        errorMsg = 'خدمة الموقع غير مفعلة، يرجى تشغيلها من الإعدادات';
      } else if (e.toString().contains('TIMEOUT')) {
        errorMsg = 'انتهى وقت الانتظار، حاول مرة أخرى في مكان مكشوف';
      }
      _showSnackBar(errorMsg, isError: true);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF379777),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF379777),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : const Color(0xFF379777),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ========== حفظ المشوار (باستخدام ApiService.createService) ==========
  Future<void> _createService() async {
    if (_tripSteps.isEmpty) {
      _showSnackBar('يرجى إضافة خطوة واحدة على الأقل', isError: true);
      return;
    }

    final token = context.read<UserProvider>().user.token;
    print('🔑 Token in AddTripScreen: ${token != null ? token.substring(0, 20) : 'null'}...');

    if (token == null || token.isEmpty) {
      _showSnackBar('يرجى تسجيل الدخول أولاً', isError: true);
      return;
    }

    final stepsList = _tripSteps.map((step) {
      return {
        'title': step.titleController.text.trim(),
        'description': step.descriptionController.text.trim(),
      };
    }).toList();

    final Map<String, dynamic> serviceData = {
      'title': _tripNameController.text.trim(),
      'name': _tripNameController.text.trim(),
      'price': 0,
      'description': _descriptionController.text.trim(),
      'category_id': _selectedCategoryId,
      'author': widget.userName,
      'place_name': _placeNameController.text.trim(),
      'governorate_id': _selectedGovernorate?.id,
      'governorate_name': _selectedGovernorate?.name,
      'city_id': _selectedCity?.id,
      'city_name': _selectedCity?.name,
      'date': _selectedDate?.toIso8601String(),
      'location': _currentLocation,
      'latitude': _latitude,
      'longitude': _longitude,
      'steps': stepsList,
      'attachments': _selectedFiles.map((file) => file.name).toList(),
    };

    serviceData.removeWhere((key, value) =>
        key != 'price' && (value == null || (value is String && value.isEmpty)));

    try {
      // ✅ استخدام ApiService.createService الذي يتعامل مع الكوكي و Bearer معاً
      final newService = await ApiService.createService(
        data: serviceData,
        token: token,
      );

      if (!mounted) return;

      if (newService != null) {
        // إضافة إلى ServicesProvider
        context.read<ServicesProvider>().addServiceLocally(newService);
        
        // إضافة إلى TripsProvider
        final trip = Trip(
          id: newService.id,
          title: newService.title,
          date: _selectedDate != null
              ? '${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}'
              : '',
          category: newService.category,
          completedSteps: 0,
          totalSteps: _tripSteps.length,
          currentStep: _tripSteps.isNotEmpty ? _tripSteps[0].titleController.text : '',
          placeName: _placeNameController.text.trim(),
          description: _descriptionController.text.trim(),
          governorate: _selectedGovernorate?.name,
          city: _selectedCity?.name,
          steps: _tripSteps.map((step) => TripStepData(
            title: step.titleController.text.trim(),
            description: step.descriptionController.text.trim(),
          )).toList(),
        );
        context.read<TripsProvider>().addTrip(trip);

        _showSnackBar('تم إضافة المشوار بنجاح ✨');
        Navigator.pop(context);
      } else {
        _showSnackBar('فشل إضافة المشوار، حاول مرة أخرى', isError: true);
      }
    } catch (e) {
      _showSnackBar('حدث خطأ: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: const Color(0xFF379777),
          selectionColor: const Color(0xFF379777).withOpacity(0.3),
          selectionHandleColor: const Color(0xFF379777),
        ),
      ),
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppBar(),
          body: Column(
            children: [
              _buildProgressIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index;
                    });
                  },
                  children: [
                    _buildFirstPage(),
                    _buildSecondPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          _currentStep == 0 ? Icons.arrow_back_ios : Icons.arrow_back_ios,
          color: const Color(0xFF379777),
        ),
        onPressed: () async {
          if (_currentStep == 1) {
            _previousStep();
          } else {
            if (await _onWillPop()) {
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            }
          }
        },
      ),
      title: Text(
        'إضافة مشوار جديد',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProgressIndicator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStepIndicator(
              stepNumber: 1,
              title: 'المعلومات الأساسية',
              isActive: _currentStep == 0,
              isCompleted: _currentStep > 0,
            ),
          ),
          Expanded(
            flex: 0,
            child: AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return Container(
                  height: 2,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _currentStep > 0 ? const Color(0xFF379777) : Colors.grey.shade300,
                        _currentStep > 0 ? const Color(0xFF379777) : Colors.grey.shade300,
                      ],
                      stops: [_progressController.value, _progressController.value],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _buildStepIndicator(
              stepNumber: 2,
              title: 'الخطوات',
              isActive: _currentStep == 1,
              isCompleted: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator({
    required int stepNumber,
    required String title,
    required bool isActive,
    required bool isCompleted,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted || isActive
                ? const Color(0xFF379777)
                : (isDark ? Colors.grey.shade800 : Colors.white),
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted || isActive
                  ? const Color(0xFF379777)
                  : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
              width: 2,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF379777).withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: isCompleted
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  )
                : Text(
                    '$stepNumber',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? Colors.white
                          : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? const Color(0xFF379777) : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildFirstPage() {
    return Stack(
      children: [
        Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildCard(
                  title: 'المعلومات الأساسية',
                  icon: Icons.info_outline,
                  children: [
                    _buildSectionTitle('اسم المشوار'),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _tripNameController,
                      hintText: 'مثال: تجديد البطاقة الشخصية',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال اسم المشوار';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildSectionTitle('القسم'),
                    const SizedBox(height: 10),
                    _buildCategoryDropdown(),
                  ],
                ),
                const SizedBox(height: 20),
                _buildCard(
                  title: 'الموقع',
                  icon: Icons.location_on_outlined,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildSectionTitle('المدينة'),
                              const SizedBox(height: 10),
                              _isLoadingCities
                                  ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF379777),
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : _buildCityDropdown(
                                      value: _selectedCity,
                                      items: _cities,
                                      hint: 'اختر المدينة',
                                      enabled: _selectedGovernorate != null && _cities.isNotEmpty,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedCity = value;
                                        });
                                      },
                                    ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildSectionTitle('المحافظة'),
                              const SizedBox(height: 10),
                              _isLoadingGovernorates
                                  ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF379777),
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : _buildGovernorateDropdown(
                                      value: _selectedGovernorate,
                                      items: _governorates,
                                      hint: 'اختر المحافظة',
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedGovernorate = value;
                                        });
                                        if (value != null) {
                                          _loadCities(value.id);
                                        }
                                      },
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSectionTitle('اسم المكان'),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _placeNameController,
                      hintText: 'مثال: مكتب السجل المدني',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال اسم المكان';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildSectionTitle('الموقع الحالي (اختياري)'),
                    const SizedBox(height: 10),
                    _buildLocationField(),
                  ],
                ),
                const SizedBox(height: 20),
                _buildCard(
                  title: 'التفاصيل',
                  icon: Icons.description_outlined,
                  children: [
                    _buildSectionTitle('تاريخ الرحلة'),
                    const SizedBox(height: 10),
                    _buildDateField(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('وصف المشوار'),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _descriptionController,
                      hintText: 'اكتب تفاصيل المشوار... (اختياري)',
                      maxLines: 5,
                      required: false,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF379777).withOpacity(0.1),
                        const Color(0xFF379777).withOpacity(0.05),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF379777).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.userName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF379777),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'منشئ المشوار',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF379777),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildCard(
                  title: 'المرفقات',
                  icon: Icons.attach_file,
                  subtitle: 'اختياري - حد أقصى 5 ميجا',
                  children: [
                    _buildFilesSection(),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).scaffoldBackgroundColor.withOpacity(0),
                  Theme.of(context).scaffoldBackgroundColor,
                  Theme.of(context).scaffoldBackgroundColor,
                ],
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF379777),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: const Color(0xFF379777).withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'التالي',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_ios, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondPage() {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF379777),
                      const Color(0xFF379777).withOpacity(0.8),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF379777).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'خطوات المشوار',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'أضف الخطوات والأوراق المطلوبة',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.list_alt_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_tripSteps.isEmpty)
                _buildEmptyState()
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _tripSteps.length,
                  itemBuilder: (context, index) {
                    return _buildStepCard(index);
                  },
                ),
              const SizedBox(height: 16),
              _buildAddStepButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).scaffoldBackgroundColor.withOpacity(0),
                  Theme.of(context).scaffoldBackgroundColor,
                  Theme.of(context).scaffoldBackgroundColor,
                ],
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _createService,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF379777),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: const Color(0xFF379777).withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'حفظ المشوار',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF379777).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.format_list_numbered_rounded,
              size: 48,
              color: const Color(0xFF379777),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'لا توجد خطوات بعد',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ بإضافة الخطوات والأوراق المطلوبة',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(int index) {
    final step = _tripSteps[index];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF379777).withOpacity(isDark ? 0.15 : 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _removeStep(index),
                ),
                Row(
                  children: [
                    Text(
                      'الخطوة ${index + 1}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF379777),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFF379777),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildSectionTitle('عنوان الخطوة'),
                const SizedBox(height: 10),
                TextField(
                  controller: step.titleController,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  decoration: InputDecoration(
                    hintText: 'مثال: تقديم طلب للحصول على البطاقة',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey.shade900.withOpacity(0.3) : Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF379777), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('الوصف والأوراق المطلوبة'),
                const SizedBox(height: 10),
                TextField(
                  controller: step.descriptionController,
                  maxLines: 4,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'مثال: صورة من البطاقة القديمة - صورة شخصية - إثبات سكن',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF379777), width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddStepButton() {
    return InkWell(
      onTap: _addStep,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF379777),
            width: 2,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF379777).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF379777),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'إضافة خطوة جديدة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF379777),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== الفئات ==========
  Widget _buildCategoryDropdown() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_availableCategories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: CircularProgressIndicator(
            color: Color(0xFF379777),
            strokeWidth: 2,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            isDark ? Colors.grey.shade900.withOpacity(0.3) : Colors.grey.shade50,
            isDark ? Colors.grey.shade900.withOpacity(0.2) : const Color(0xFFF8F9FA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: _selectedCategoryId != null
              ? const Color(0xFF379777)
              : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
          width: _selectedCategoryId != null ? 1.5 : 1,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCategoryId,
        items: _availableCategories.map((category) {
          return DropdownMenuItem(
            value: category.id,
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    category.name,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF379777),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCategoryId = value;
          });
        },
        hint: Text(
          'اختر القسم',
          textAlign: TextAlign.right,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
          ),
        ),
        dropdownColor: Theme.of(context).cardColor,
        menuMaxHeight: 300,
        icon: Container(
          padding: const EdgeInsets.only(right: 12, left: 4),
          child: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF379777),
            size: 20,
          ),
        ),
        decoration: const InputDecoration(
          filled: false,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        isExpanded: true,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: 15,
          fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    String? subtitle,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(width: 12),
              Icon(
                icon,
                color: const Color(0xFF379777),
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool required = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      style: TextStyle(
        fontSize: 16,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 14,
        ),
        filled: true,
        fillColor: isDark ? Colors.grey.shade900.withOpacity(0.3) : Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF379777), width: 2),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildGovernorateDropdown({
    required Governorate? value,
    required List<Governorate> items,
    required String hint,
    required ValueChanged<Governorate?> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            isDark ? Colors.grey.shade900.withOpacity(0.3) : Colors.grey.shade50,
            isDark ? Colors.grey.shade900.withOpacity(0.2) : const Color(0xFFF8F9FA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: value != null ? const Color(0xFF379777) : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
          width: value != null ? 1.5 : 1,
        ),
      ),
      child: DropdownButtonFormField<Governorate>(
        value: value,
        items: items.map((governorate) {
          return DropdownMenuItem(
            value: governorate,
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    governorate.name,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF379777),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: onChanged,
        hint: Text(
          hint,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
          ),
        ),
        dropdownColor: Theme.of(context).cardColor,
        menuMaxHeight: 300,
        icon: _isLoadingGovernorates
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF379777)),
                ),
              )
            : const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF379777),
                size: 22,
              ),
        decoration: const InputDecoration(
          filled: false,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        isExpanded: true,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: 15,
          fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
        ),
      ),
    );
  }

  Widget _buildCityDropdown({
    required City? value,
    required List<City> items,
    required String hint,
    required ValueChanged<City?> onChanged,
    bool enabled = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            isDark
                ? Colors.grey.shade900.withOpacity(enabled ? 0.3 : 0.15)
                : (enabled ? Colors.grey.shade50 : Colors.grey.shade100),
            isDark
                ? Colors.grey.shade900.withOpacity(enabled ? 0.2 : 0.1)
                : (enabled ? const Color(0xFFF8F9FA) : Colors.grey.shade100),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: DropdownButtonFormField<City>(
        value: value,
        items: items.map((city) {
          return DropdownMenuItem(
            value: city,
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    city.name,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: enabled ? onChanged : null,
        hint: Text(
          hint,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: enabled ? Colors.grey.shade500 : Colors.grey.shade400,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
          ),
        ),
        dropdownColor: Theme.of(context).cardColor,
        menuMaxHeight: 300,
        icon: _isLoadingCities
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF379777)),
                ),
              )
            : Icon(
                Icons.keyboard_arrow_down_rounded,
                color: const Color(0xFF379777).withOpacity(enabled ? 1.0 : 0.5),
                size: 22,
              ),
        decoration: const InputDecoration(
          filled: false,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
        isExpanded: true,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: 15,
          fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
        ),
      ),
    );
  }

  Widget _buildDateField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900.withOpacity(0.3) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              _selectedDate != null
                  ? '${_selectedDate!.year}/${_selectedDate!.month}/${_selectedDate!.day}'
                  : 'اختر التاريخ',
              style: TextStyle(
                fontSize: 16,
                color: _selectedDate != null
                    ? Theme.of(context).textTheme.bodyLarge?.color
                    : Colors.grey.shade500,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.calendar_today, color: Color(0xFF379777), size: 20)
          ],
        ),
      ),
    );
  }

  // ========== حقل الموقع الحالي ==========
  Widget _buildLocationField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: _isGettingLocation ? null : _getCurrentLocation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900.withOpacity(0.3) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_isGettingLocation)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF379777),
                ),
              )
            else
              const Icon(
                Icons.location_on,
                color: Color(0xFF379777),
                size: 20,
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _currentLocation ?? 'اضغط للحصول على الموقع الحالي',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 14,
                  color: _currentLocation != null
                      ? Theme.of(context).textTheme.bodyLarge?.color
                      : Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilesSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_selectedFiles.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedFiles.length,
            itemBuilder: (context, index) {
              final file = _selectedFiles[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900.withOpacity(0.3) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => _removeFile(index),
                    ),
                    Expanded(
                      child: Text(
                        file.name,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.attach_file, size: 18, color: Color(0xFF379777)),
                  ],
                ),
              );
            },
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _pickFiles,
            icon: const Icon(Icons.add),
            label: const Text('إضافة ملفات'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF379777),
              side: const BorderSide(color: Color(0xFF379777)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

// Model للخطوة
class TripStep {
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  TripStep({
    required this.titleController,
    required this.descriptionController,
  });
}