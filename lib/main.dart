import 'dart:convert';
import 'package:daleel/core/themes/app_theme.dart';
import 'package:daleel/providers/app_provider.dart';
import 'package:daleel/providers/theme_provider.dart';
import 'package:daleel/providers/user_provider.dart';
import 'package:daleel/home_page.dart';
import 'package:daleel/screen/auth/auth_screen.dart';
import 'package:daleel/screen/slpashes/splash_1.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ServicesProvider()),
        ChangeNotifierProvider(create: (_) => TripsProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// ✅ تحويل MyApp إلى StatefulWidget لتخزين الـ future وتجنب إعادة استدعائه
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // ✅ تخزين الـ future لمنع إنشاء future جديد عند كل rebuild
  Future<Widget>? _navigationFuture;
  String? _cachedToken;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Daleel',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode:
              themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              if (userProvider.isLoading) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final token = userProvider.user.token;

              if (token != null && token.isNotEmpty) {
                // ✅ إنشاء future جديد فقط إذا تغير التوكن
                if (_cachedToken != token) {
                  _cachedToken = token;
                  _navigationFuture =
                      _checkTokenAndNavigate(context, token, userProvider);
                }

                return FutureBuilder<Widget>(
                  future: _navigationFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return snapshot.data ??
                        const AuthScreen(startWithLogin: true);
                  },
                );
              }

              // لا يوجد توكن => شاشة البداية (Splash1)
              // ✅ إعادة تعيين الـ cache عند تسجيل الخروج
              _cachedToken = null;
              _navigationFuture = null;
              return const Splash1();
            },
          ),
        );
      },
    );
  }

  /// دالة للتحقق من صحة التوكن مع الخادم
  /// - إذا كان صالحاً: يعيد HomePage
  /// - إذا كان غير صالح: يعيد AuthScreen
  Future<Widget> _checkTokenAndNavigate(
    BuildContext context,
    String token,
    UserProvider userProvider,
  ) async {
    try {
      final url =
          Uri.parse('https://auth-login-for-daleel1.vercel.app/auth/me');

      // بناء الهيدر حسب نوع التوكن
      final headers = <String, String>{};
      String? cookieValue;

      if (token.startsWith('cookie_')) {
        cookieValue = token.substring(7);
        headers['Cookie'] = 'connect.sid=$cookieValue';
        headers['Authorization'] = 'Bearer $cookieValue';
      } else {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userData = data['user'] ?? data;

        if (userData is Map<String, dynamic>) {
          final user = User(
            displayName: userData['username'] ??
                userData['name'] ??
                userData['email'],
            email: userData['email'],
            photoUrl: userData['photoUrl'],
            token: token,
            phone: userData['phone'],
            // ✅ الإصلاح الرئيسي: الحفاظ على الكوكي الموجودة
            // أولاً: نجرب الكوكي المخزنة في UserProvider
            // ثانياً: نستخرجها من التوكن إذا كان نوعه cookie_
            cookie: userProvider.user.cookie ?? cookieValue,
          );

          userProvider.updateUser(user);
          return const HomePage();
        }
      }

      // توكن غير صالح => شاشة تسجيل الدخول
      return const AuthScreen(startWithLogin: true);
    } catch (e) {
      // خطأ في الشبكة => شاشة تسجيل الدخول (مع الاحتفاظ بالتوكن)
      return const AuthScreen(startWithLogin: true);
    }
  }
}