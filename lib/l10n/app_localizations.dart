// lib/core/l10n/app_localizations.dart
//
// ملف الترجمة الرئيسي - يحتوي على كل نصوص التطبيق بالعربي والإنجليزي
// استخدامه: context.tr.home  أو  AppLocalizations.of(context).home
//
// لإضافة نص جديد:
//   1. أضفه في _AppLocalizationsAr و _AppLocalizationsEn
//   2. أضف getter في AppLocalizations الـ abstract class

import 'package:flutter/material.dart';

abstract class AppLocalizations {
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    _AppLocalizationsDelegate(),
  ];

  static const List<Locale> supportedLocales = [
    Locale('ar'),
    Locale('en'),
  ];

  // ==================== عام ====================
  String get appName;
  String get home;
  String get discover;
  String get myTrips;
  String get myProfile;
  String get settings;
  String get account;
  String get help;
  String get about;
  String get logout;
  String get darkMode;
  String get enableDarkMode;
  String get ok;
  String get cancel;
  String get save;
  String get delete;
  String get next;
  String get copy;

  // ==================== اللغة والإعدادات ====================
  String get language;
  String get appLanguage;
  String get chooseLanguage;
  String get arabic;
  String get english;
  String get appearance;
  String get notifications;
  String get receiveNotifications;
  String get sound;
  String get enableSound;
  String get vibration;
  String get enableVibration;
  String get storage;
  String get clearCache;
  String get saveDiskSpace;
  String get privacyAndSecurity;
  String get privacyPolicy;
  String get viewPrivacyPolicy;
  String get termsOfService;
  String get readTerms;
  String get clearCacheConfirm;
  String get clearCacheSuccess;
  String get contentComingSoon;

  // ==================== Auth ====================
  String get login;
  String get createAccount;
  String get email;
  String get enterEmail;
  String get enterEmailHint;
  String get password;
  String get enterPassword;
  String get confirmPassword;
  String get reenterPassword;
  String get forgotPassword;
  String get rememberMe;
  String get orLoginWith;
  String get username;
  String get enterUsername;
  String get phone;
  String get enterPhone;
  String get birthDate;
  String get dayMonthYear;
  String get passwordRequirements;
  String get minChars;
  String get upperCase;
  String get lowerCase;
  String get number;
  String get passwordWeak;
  String get passwordMismatch;
  String get passwordMatch;
  String get invalidEmail;
  String get enterName;
  String get nameRequired;
  String get emailRequired;
  String get phoneRequired;

  // ==================== الرئيسية ====================
  String get hello;
  String get addTrip;
  String get workDocs;
  String get showAll;
  String get mostPopular;
  String get discoverServices;
  String get discoverNewTrips;
  String get searchForService;
  String get searchResults;
  String get startSearch;
  String get noResults;
  String get cars;
  String get trustedSource;
  String get buyCarInstallment;

  // ==================== مشاويري ====================
  String get noSavedTrips;
  String get saveServicesHint;
  String get deleteTrip;
  String get confirmDeleteTrip;
  String get cannotRestore;
  String get tripDeleted;
  String get serviceSaved;
  String get notStarted;

  // ==================== الإشعارات ====================
  String get allNotifications;
  String get unread;
  String get noNotifications;
  String get noUnreadNotifications;
  String get markAllRead;

  // ==================== تفاصيل الخدمة ====================
  String get serviceDetails;
  String get requiredDocs;
  String get membersComments;
  String get addComment;
  String get agree;
  String get disagree;
  String get report;
  String get you;
  String get now;
  String get reportContent;
  String get reportUrgentNotice;
  String get bullyingOrHarassment;
  String get whoIsTarget;
  String get me;
  String get friend;
  String get unknown;
  String get fraudOrFalseInfo;
  String get fraud;
  String get falseInfo;
  String get impersonation;
  String get sendReport;

  // ==================== الحساب ====================
  String get accountInfo;
  String get editAccount;
  String get fullName;
  String get joinDate;
  String get saveChanges;
  String get changesSaved;
  String get warning;
  String get unsavedChanges;
  String get stay;
  String get leave;
  String get chooseImageSource;
  String get takePhoto;
  String get useCamera;
  String get chooseFromGallery;
  String get browsePhotos;
  String get imageSelectedSuccess;

  // ==================== Onboarding ====================
  String get onboardingTitle1;
  String get onboardingSubtitle1;
  String get onboardingBody1;
  String get onboardingTitle2;
  String get onboardingSubtitle2;
  String get onboardingBody2;
  String get onboardingTitle3;
  String get onboardingSubtitle3;
  String get onboardingBody3;
  String get start;
  String get skip;

  // ==================== المساعدة ====================
  String get helpTitle;
  String get helpBody;
  String get contactViaEmail;
  String get sendEmail;
  String get emailCopied;
  String get cannotOpenEmail;
  String get replyTime;
  String get docsAndHelp;
  String get docsBody;
  String get openDocs;
  String get copyLink;
  String get linkCopied;
  String get cannotOpenLink;
  String get appVersion;
  String get copyright;

  // ==================== الفئات ====================
  String get categorySoldiers;
  String get categoryGraduation;
  String get categoryMarriage;
  String get categoryUniversity;
  String get categoryCarLicense;
  String get categoryTravel;
  String get categoryTaxes;
  String get categorySchools;
  String get categoryNeighborhood;
  String get categoryHealth;
  String get categoryRealEstate;
  String get categoryHousing;
  String get categoryJobs;
  String get categoryTraffic;
  String get categoryCompanies;
  String get categoryInsurance;
  String get categoryCustoms;
  String get categoryImportExport;
  String get categoryEducation;
  String get categoryTransport;

  // ==================== الأشهر والأيام ====================
  String get monthJan;
  String get monthFeb;
  String get monthMar;
  String get monthApr;
  String get monthMay;
  String get monthJun;
  String get monthJul;
  String get monthAug;
  String get monthSep;
  String get monthOct;
  String get monthNov;
  String get monthDec;
  String get daySat;
  String get daySun;
  String get dayMon;
  String get dayTue;
  String get dayWed;
  String get dayThu;
  String get dayFri;

  // ==================== متفرقات ====================
  String get nationalId;
  String get civilRegistry;
  String get closestRecruitmentCenter;
}

// ==================== Delegate ====================
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    if (locale.languageCode == 'en') return _AppLocalizationsEn();
    return _AppLocalizationsAr();
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// ==================== Extension للاستخدام السريع ====================
extension AppLocalizationsX on BuildContext {
  AppLocalizations get tr => AppLocalizations.of(this);
}

// ==================== العربية ====================
class _AppLocalizationsAr extends AppLocalizations {
  @override String get appName => 'دليل';
  @override String get home => 'الرئيسية';
  @override String get discover => 'اكتشف';
  @override String get myTrips => 'مشاويري';
  @override String get myProfile => 'ملفي';
  @override String get settings => 'الإعدادات';
  @override String get account => 'الحساب';
  @override String get help => 'المساعدة';
  @override String get about => 'الوصف';
  @override String get logout => 'تسجيل خروج';
  @override String get darkMode => 'الوضع الليلي';
  @override String get enableDarkMode => 'تفعيل المظهر الداكن';
  @override String get ok => 'حسناً';
  @override String get cancel => 'إلغاء';
  @override String get save => 'مسح';
  @override String get delete => 'حذف';
  @override String get next => 'التالي';
  @override String get copy => 'نسخ';

  @override String get language => 'اللغة';
  @override String get appLanguage => 'لغة التطبيق';
  @override String get chooseLanguage => 'اختر اللغة';
  @override String get arabic => 'العربية';
  @override String get english => 'English';
  @override String get appearance => 'المظهر';
  @override String get notifications => 'الإشعارات';
  @override String get receiveNotifications => 'تلقي الإشعارات والتنبيهات';
  @override String get sound => 'الصوت';
  @override String get enableSound => 'تشغيل الصوت للإشعارات';
  @override String get vibration => 'الاهتزاز';
  @override String get enableVibration => 'اهتزاز الهاتف عند التنبيه';
  @override String get storage => 'التخزين';
  @override String get clearCache => 'مسح ذاكرة التخزين المؤقت';
  @override String get saveDiskSpace => 'توفير مساحة على الجهاز';
  @override String get privacyAndSecurity => 'الخصوصية والأمان';
  @override String get privacyPolicy => 'سياسة الخصوصية';
  @override String get viewPrivacyPolicy => 'اطلع على سياسة الخصوصية';
  @override String get termsOfService => 'شروط الاستخدام';
  @override String get readTerms => 'اقرأ شروط استخدام التطبيق';
  @override String get clearCacheConfirm => 'هل تريد مسح ذاكرة التخزين المؤقت؟\nسيتم حذف جميع البيانات المخزنة محلياً.';
  @override String get clearCacheSuccess => 'تم مسح ذاكرة التخزين المؤقت بنجاح';
  @override String get contentComingSoon => 'سيتم إضافة المحتوى الكامل قريباً.\nشكراً لاستخدامك Daleel!';

  @override String get login => 'تسجيل دخول';
  @override String get createAccount => 'إنشاء حساب';
  @override String get email => 'البريد الإلكتروني';
  @override String get enterEmail => 'أدخل بريدك الإلكتروني';
  @override String get enterEmailHint => 'أدخل البريد الإلكتروني';
  @override String get password => 'كلمة المرور';
  @override String get enterPassword => 'أدخل كلمة المرور';
  @override String get confirmPassword => 'تأكيد كلمة المرور';
  @override String get reenterPassword => 'أعد إدخال كلمة المرور';
  @override String get forgotPassword => 'هل نسيت كلمة المرور؟';
  @override String get rememberMe => 'تذكرني';
  @override String get orLoginWith => 'أو تسجيل الدخول بإستخدام';
  @override String get username => 'اسم المستخدم';
  @override String get enterUsername => 'أدخل اسم المستخدم';
  @override String get phone => 'رقم الهاتف';
  @override String get enterPhone => 'أدخل رقم الهاتف';
  @override String get birthDate => 'تاريخ الميلاد';
  @override String get dayMonthYear => 'يوم/شهر/سنة';
  @override String get passwordRequirements => 'يجب أن تحتوي كلمة المرور على:';
  @override String get minChars => '8 أحرف على الأقل';
  @override String get upperCase => 'حرف كبير (A-Z)';
  @override String get lowerCase => 'حرف صغير (a-z)';
  @override String get number => 'رقم (0-9)';
  @override String get passwordWeak => 'كلمة المرور لا تستوفي الشروط المطلوبة';
  @override String get passwordMismatch => 'كلمة المرور غير متطابقة';
  @override String get passwordMatch => 'كلمة المرور متطابقة';
  @override String get invalidEmail => 'البريد الإلكتروني غير صحيح';
  @override String get enterName => 'أدخل اسمك الكامل';
  @override String get nameRequired => 'يرجى إدخال الاسم';
  @override String get emailRequired => 'يرجى إدخال البريد الإلكتروني';
  @override String get phoneRequired => 'يرجى إدخال رقم الهاتف';

  @override String get hello => 'مرحبا';
  @override String get addTrip => 'اضافة مشوار';
  @override String get workDocs => 'مسوغات العمل';
  @override String get showAll => 'اظهار الكل';
  @override String get mostPopular => 'الأكثر شيوعاً';
  @override String get discoverServices => 'اكتشف الخدمات';
  @override String get discoverNewTrips => 'اكتشف مشاوير جديدة';
  @override String get searchForService => 'ابحث عن خدمة...';
  @override String get searchResults => 'نتائج البحث';
  @override String get startSearch => 'ابدأ البحث عن الخدمة';
  @override String get noResults => 'لا توجد نتائج';
  @override String get cars => 'سيارات';
  @override String get trustedSource => 'مصدر موثوق';
  @override String get buyCarInstallment => 'شراء سيارة جديدة بالتقسيط';

  @override String get noSavedTrips => 'لا توجد مشاوير محفوظة';
  @override String get saveServicesHint => 'ابحث عن الخدمات واحفظها هنا';
  @override String get deleteTrip => 'حذف المشوار';
  @override String get confirmDeleteTrip => 'هل أنت متأكد من حذف هذا المشوار؟';
  @override String get cannotRestore => 'لن تتمكن من استرجاعه مرة أخرى';
  @override String get tripDeleted => 'تم حذف المشوار';
  @override String get serviceSaved => 'تم حفظ الخدمة في مشاويري';
  @override String get notStarted => 'لم يتم البدء';

  @override String get allNotifications => 'الكل';
  @override String get unread => 'غير مقروءة';
  @override String get noNotifications => 'لا توجد إشعارات';
  @override String get noUnreadNotifications => 'لا توجد إشعارات غير مقروءة';
  @override String get markAllRead => 'تحديد الكل كمقروء';

  @override String get serviceDetails => 'تفاصيل الخدمة';
  @override String get requiredDocs => 'المستندات المطلوبة';
  @override String get membersComments => 'مشاركات الأعضاء';
  @override String get addComment => 'اضافة مشاركة';
  @override String get agree => 'أوافق';
  @override String get disagree => 'لا أوافق';
  @override String get report => 'ابلاغ';
  @override String get you => 'أنت';
  @override String get now => 'الآن';
  @override String get reportContent => 'لماذا تقوم بالابلاغ عن هذا المحتوى؟';
  @override String get reportUrgentNotice => 'اذا كان شخص ما في خطر مباشر , فاطلب المساعدة قبل الإبلاغ الى دليل , لا تنتظر';
  @override String get bullyingOrHarassment => 'التنمر أو المضايقة ؟';
  @override String get whoIsTarget => 'من يتعرض لها؟';
  @override String get me => 'أنا';
  @override String get friend => 'صديق';
  @override String get unknown => 'لا أعرفه';
  @override String get fraudOrFalseInfo => 'الاحتيال أو النصب أو المعلومات الكاذبة ؟';
  @override String get fraud => 'أحتيال أو النصب';
  @override String get falseInfo => 'مشاركة معلومات خاطئة';
  @override String get impersonation => 'أنتحال صفة شركة أو شخص';
  @override String get sendReport => 'إرسال الابلاغ';

  @override String get accountInfo => 'معلومات الحساب';
  @override String get editAccount => 'تعديل الحساب';
  @override String get fullName => 'الاسم الكامل';
  @override String get joinDate => 'تاريخ الانضمام';
  @override String get saveChanges => 'حفظ التغييرات';
  @override String get changesSaved => 'تم حفظ التغييرات بنجاح';
  @override String get warning => 'تحذير';
  @override String get unsavedChanges => 'لديك تعديلات غير محفوظة!\nهل تريد المغادرة دون حفظ التغييرات؟';
  @override String get stay => 'البقاء';
  @override String get leave => 'المغادرة';
  @override String get chooseImageSource => 'اختر مصدر الصورة';
  @override String get takePhoto => 'التقاط صورة';
  @override String get useCamera => 'استخدام الكاميرا';
  @override String get chooseFromGallery => 'اختيار من المعرض';
  @override String get browsePhotos => 'تصفح الصور المحفوظة';
  @override String get imageSelectedSuccess => 'تم تحديد الصورة بنجاح';

  @override String get onboardingTitle1 => 'ابحث عن أي إجراء حكومي';
  @override String get onboardingSubtitle1 => 'بسهولة';
  @override String get onboardingBody1 => 'ابحث عن الأوراق المطلوبة في ثواني\nكل الإجراءات والأوراق في مكان واحد';
  @override String get onboardingTitle2 => 'تأكد من صحة الأوراق';
  @override String get onboardingSubtitle2 => 'قبل ما تروح';
  @override String get onboardingBody2 => 'راجع كل المستندات المطلوبة وتأكد إنها كاملة وصحيحة\nعشان توفر وقتك وجهدك';
  @override String get onboardingTitle3 => 'تحديثات رسمية';
  @override String get onboardingSubtitle3 => 'وموثوقة';
  @override String get onboardingBody3 => 'احصل على تحديثات مستمرة لأي تغييرات في الإجراءات أو الأوراق المطلوبة من المصادر الرسمية';
  @override String get start => 'ابدأ';
  @override String get skip => 'تخطي';

  @override String get helpTitle => 'كيف يمكننا مساعدتك؟';
  @override String get helpBody => 'نحن هنا لمساعدتك! إذا كان لديك أي استفسار أو تحتاج إلى دعم فني، لا تتردد في التواصل معنا';
  @override String get contactViaEmail => 'تواصل عبر البريد الإلكتروني';
  @override String get sendEmail => 'إرسال بريد إلكتروني';
  @override String get emailCopied => 'تم نسخ البريد الإلكتروني';
  @override String get cannotOpenEmail => 'لا يمكن فتح تطبيق البريد الإلكتروني';
  @override String get replyTime => 'عادة ما نرد خلال 24 ساعة';
  @override String get docsAndHelp => 'التوثيق والمساعدة';
  @override String get docsBody => 'للمزيد من المعلومات حول كيفية استخدام التطبيق والميزات المتاحة';
  @override String get openDocs => 'فتح التوثيق';
  @override String get copyLink => 'نسخ الرابط';
  @override String get linkCopied => 'تم نسخ الرابط';
  @override String get cannotOpenLink => 'مش قادر أفتح الرابط - جرب تنسخه وتفتحه بنفسك';
  @override String get appVersion => 'الإصدار 1.0.0';
  @override String get copyright => '© 2024 Daleel. جميع الحقوق محفوظة';

  @override String get categorySoldiers => 'الجيش';
  @override String get categoryGraduation => 'التخرج الجامعي';
  @override String get categoryMarriage => 'الزواج';
  @override String get categoryUniversity => 'التقديم الجامعي';
  @override String get categoryCarLicense => 'ترخيص السيارات';
  @override String get categoryTravel => 'السفر للخارج';
  @override String get categoryTaxes => 'الضرائب';
  @override String get categorySchools => 'المدارس';
  @override String get categoryNeighborhood => 'الحي';
  @override String get categoryHealth => 'الصحة';
  @override String get categoryRealEstate => 'الشهر العقاري';
  @override String get categoryHousing => 'الإسكان';
  @override String get categoryJobs => 'الوظائف';
  @override String get categoryTraffic => 'المرور';
  @override String get categoryCompanies => 'شركات';
  @override String get categoryInsurance => 'التأمينات';
  @override String get categoryCustoms => 'الجمارك';
  @override String get categoryImportExport => 'الاستيراد و التصدير';
  @override String get categoryEducation => 'التعليم';
  @override String get categoryTransport => 'النقل';

  @override String get monthJan => 'يناير';
  @override String get monthFeb => 'فبراير';
  @override String get monthMar => 'مارس';
  @override String get monthApr => 'أبريل';
  @override String get monthMay => 'مايو';
  @override String get monthJun => 'يونيو';
  @override String get monthJul => 'يوليو';
  @override String get monthAug => 'أغسطس';
  @override String get monthSep => 'سبتمبر';
  @override String get monthOct => 'أكتوبر';
  @override String get monthNov => 'نوفمبر';
  @override String get monthDec => 'ديسمبر';
  @override String get daySat => 'السبت';
  @override String get daySun => 'الأحد';
  @override String get dayMon => 'الإثنين';
  @override String get dayTue => 'الثلاثاء';
  @override String get dayWed => 'الأربعاء';
  @override String get dayThu => 'الخميس';
  @override String get dayFri => 'الجمعة';

  @override String get nationalId => 'البطاقة الوطنية';
  @override String get civilRegistry => 'السجل المدني';
  @override String get closestRecruitmentCenter => 'أقرب مركز تجنيد';
}

// ==================== الإنجليزية ====================
class _AppLocalizationsEn extends AppLocalizations {
  @override String get appName => 'Daleel';
  @override String get home => 'Home';
  @override String get discover => 'Discover';
  @override String get myTrips => 'My Trips';
  @override String get myProfile => 'Profile';
  @override String get settings => 'Settings';
  @override String get account => 'Account';
  @override String get help => 'Help';
  @override String get about => 'About';
  @override String get logout => 'Logout';
  @override String get darkMode => 'Dark Mode';
  @override String get enableDarkMode => 'Enable dark theme';
  @override String get ok => 'OK';
  @override String get cancel => 'Cancel';
  @override String get save => 'Clear';
  @override String get delete => 'Delete';
  @override String get next => 'Next';
  @override String get copy => 'Copy';

  @override String get language => 'Language';
  @override String get appLanguage => 'App Language';
  @override String get chooseLanguage => 'Choose Language';
  @override String get arabic => 'العربية';
  @override String get english => 'English';
  @override String get appearance => 'Appearance';
  @override String get notifications => 'Notifications';
  @override String get receiveNotifications => 'Receive notifications and alerts';
  @override String get sound => 'Sound';
  @override String get enableSound => 'Enable notification sounds';
  @override String get vibration => 'Vibration';
  @override String get enableVibration => 'Vibrate on notification';
  @override String get storage => 'Storage';
  @override String get clearCache => 'Clear Cache';
  @override String get saveDiskSpace => 'Free up device storage';
  @override String get privacyAndSecurity => 'Privacy & Security';
  @override String get privacyPolicy => 'Privacy Policy';
  @override String get viewPrivacyPolicy => 'View our privacy policy';
  @override String get termsOfService => 'Terms of Service';
  @override String get readTerms => 'Read the app terms of service';
  @override String get clearCacheConfirm => 'Do you want to clear the cache?\nAll locally stored data will be deleted.';
  @override String get clearCacheSuccess => 'Cache cleared successfully';
  @override String get contentComingSoon => 'Full content will be added soon.\nThank you for using Daleel!';

  @override String get login => 'Login';
  @override String get createAccount => 'Create Account';
  @override String get email => 'Email';
  @override String get enterEmail => 'Enter your email';
  @override String get enterEmailHint => 'Enter email address';
  @override String get password => 'Password';
  @override String get enterPassword => 'Enter your password';
  @override String get confirmPassword => 'Confirm Password';
  @override String get reenterPassword => 'Re-enter your password';
  @override String get forgotPassword => 'Forgot your password?';
  @override String get rememberMe => 'Remember me';
  @override String get orLoginWith => 'Or login with';
  @override String get username => 'Username';
  @override String get enterUsername => 'Enter your username';
  @override String get phone => 'Phone Number';
  @override String get enterPhone => 'Enter your phone number';
  @override String get birthDate => 'Date of Birth';
  @override String get dayMonthYear => 'DD/MM/YYYY';
  @override String get passwordRequirements => 'Password must contain:';
  @override String get minChars => 'At least 8 characters';
  @override String get upperCase => 'Uppercase letter (A-Z)';
  @override String get lowerCase => 'Lowercase letter (a-z)';
  @override String get number => 'Number (0-9)';
  @override String get passwordWeak => 'Password does not meet requirements';
  @override String get passwordMismatch => 'Passwords do not match';
  @override String get passwordMatch => 'Passwords match';
  @override String get invalidEmail => 'Invalid email address';
  @override String get enterName => 'Enter your full name';
  @override String get nameRequired => 'Please enter your name';
  @override String get emailRequired => 'Please enter your email';
  @override String get phoneRequired => 'Please enter your phone number';

  @override String get hello => 'Hello';
  @override String get addTrip => 'Add Trip';
  @override String get workDocs => 'Work Documents';
  @override String get showAll => 'Show All';
  @override String get mostPopular => 'Most Popular';
  @override String get discoverServices => 'Discover Services';
  @override String get discoverNewTrips => 'Discover New Trips';
  @override String get searchForService => 'Search for a service...';
  @override String get searchResults => 'Search Results';
  @override String get startSearch => 'Start searching for a service';
  @override String get noResults => 'No results found';
  @override String get cars => 'Cars';
  @override String get trustedSource => 'Trusted Source';
  @override String get buyCarInstallment => 'Buy a New Car on Installments';

  @override String get noSavedTrips => 'No saved trips';
  @override String get saveServicesHint => 'Search for services and save them here';
  @override String get deleteTrip => 'Delete Trip';
  @override String get confirmDeleteTrip => 'Are you sure you want to delete this trip?';
  @override String get cannotRestore => 'You will not be able to restore it';
  @override String get tripDeleted => 'Trip deleted';
  @override String get serviceSaved => 'Service saved to My Trips';
  @override String get notStarted => 'Not Started';

  @override String get allNotifications => 'All';
  @override String get unread => 'Unread';
  @override String get noNotifications => 'No notifications';
  @override String get noUnreadNotifications => 'No unread notifications';
  @override String get markAllRead => 'Mark all as read';

  @override String get serviceDetails => 'Service Details';
  @override String get requiredDocs => 'Required Documents';
  @override String get membersComments => 'Member Comments';
  @override String get addComment => 'Add Comment';
  @override String get agree => 'Agree';
  @override String get disagree => 'Disagree';
  @override String get report => 'Report';
  @override String get you => 'You';
  @override String get now => 'Now';
  @override String get reportContent => 'Why are you reporting this content?';
  @override String get reportUrgentNotice => 'If someone is in immediate danger, seek help before reporting to Daleel, don\'t wait';
  @override String get bullyingOrHarassment => 'Bullying or harassment?';
  @override String get whoIsTarget => 'Who is being targeted?';
  @override String get me => 'Me';
  @override String get friend => 'Friend';
  @override String get unknown => 'I don\'t know them';
  @override String get fraudOrFalseInfo => 'Fraud, scam, or false information?';
  @override String get fraud => 'Fraud or scam';
  @override String get falseInfo => 'Sharing false information';
  @override String get impersonation => 'Impersonating a company or person';
  @override String get sendReport => 'Submit Report';

  @override String get accountInfo => 'Account Information';
  @override String get editAccount => 'Edit Account';
  @override String get fullName => 'Full Name';
  @override String get joinDate => 'Join Date';
  @override String get saveChanges => 'Save Changes';
  @override String get changesSaved => 'Changes saved successfully';
  @override String get warning => 'Warning';
  @override String get unsavedChanges => 'You have unsaved changes!\nDo you want to leave without saving?';
  @override String get stay => 'Stay';
  @override String get leave => 'Leave';
  @override String get chooseImageSource => 'Choose Image Source';
  @override String get takePhoto => 'Take Photo';
  @override String get useCamera => 'Use Camera';
  @override String get chooseFromGallery => 'Choose from Gallery';
  @override String get browsePhotos => 'Browse saved photos';
  @override String get imageSelectedSuccess => 'Image selected successfully';

  @override String get onboardingTitle1 => 'Find any government procedure';
  @override String get onboardingSubtitle1 => 'Easily';
  @override String get onboardingBody1 => 'Find required documents in seconds\nAll procedures and documents in one place';
  @override String get onboardingTitle2 => 'Verify your documents';
  @override String get onboardingSubtitle2 => 'Before you go';
  @override String get onboardingBody2 => 'Review all required documents and make sure they are complete\nTo save your time and effort';
  @override String get onboardingTitle3 => 'Official updates';
  @override String get onboardingSubtitle3 => 'And trusted';
  @override String get onboardingBody3 => 'Get continuous updates on any changes in procedures or required documents from official sources';
  @override String get start => 'Start';
  @override String get skip => 'Skip';

  @override String get helpTitle => 'How can we help you?';
  @override String get helpBody => 'We are here to help! If you have any questions or need technical support, don\'t hesitate to contact us';
  @override String get contactViaEmail => 'Contact via Email';
  @override String get sendEmail => 'Send Email';
  @override String get emailCopied => 'Email copied';
  @override String get cannotOpenEmail => 'Cannot open email app';
  @override String get replyTime => 'We usually reply within 24 hours';
  @override String get docsAndHelp => 'Documentation & Help';
  @override String get docsBody => 'For more information on how to use the app and available features';
  @override String get openDocs => 'Open Documentation';
  @override String get copyLink => 'Copy Link';
  @override String get linkCopied => 'Link copied';
  @override String get cannotOpenLink => 'Cannot open link - try copying and opening it yourself';
  @override String get appVersion => 'Version 1.0.0';
  @override String get copyright => '© 2024 Daleel. All rights reserved.';

  @override String get categorySoldiers => 'Military';
  @override String get categoryGraduation => 'Graduation';
  @override String get categoryMarriage => 'Marriage';
  @override String get categoryUniversity => 'University Application';
  @override String get categoryCarLicense => 'Car License';
  @override String get categoryTravel => 'Travel Abroad';
  @override String get categoryTaxes => 'Taxes';
  @override String get categorySchools => 'Schools';
  @override String get categoryNeighborhood => 'Neighborhood';
  @override String get categoryHealth => 'Health';
  @override String get categoryRealEstate => 'Real Estate Registry';
  @override String get categoryHousing => 'Housing';
  @override String get categoryJobs => 'Jobs';
  @override String get categoryTraffic => 'Traffic';
  @override String get categoryCompanies => 'Companies';
  @override String get categoryInsurance => 'Insurance';
  @override String get categoryCustoms => 'Customs';
  @override String get categoryImportExport => 'Import & Export';
  @override String get categoryEducation => 'Education';
  @override String get categoryTransport => 'Transport';

  @override String get monthJan => 'January';
  @override String get monthFeb => 'February';
  @override String get monthMar => 'March';
  @override String get monthApr => 'April';
  @override String get monthMay => 'May';
  @override String get monthJun => 'June';
  @override String get monthJul => 'July';
  @override String get monthAug => 'August';
  @override String get monthSep => 'September';
  @override String get monthOct => 'October';
  @override String get monthNov => 'November';
  @override String get monthDec => 'December';
  @override String get daySat => 'Saturday';
  @override String get daySun => 'Sunday';
  @override String get dayMon => 'Monday';
  @override String get dayTue => 'Tuesday';
  @override String get dayWed => 'Wednesday';
  @override String get dayThu => 'Thursday';
  @override String get dayFri => 'Friday';

  @override String get nationalId => 'National ID';
  @override String get civilRegistry => 'Civil Registry';
  @override String get closestRecruitmentCenter => 'Nearest Recruitment Center';
}