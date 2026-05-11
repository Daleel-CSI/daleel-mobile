import 'dart:convert';
import 'package:daleel/core/themes/app_theme.dart';
import 'package:daleel/providers/app_provider.dart';
import 'package:daleel/providers/theme_provider.dart';
import 'package:daleel/providers/user_provider.dart';
import 'package:daleel/home_page.dart';
import 'package:daleel/screen/slpashes/splash_1.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // محاولة تسجيل الدخول التلقائي
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ServicesProvider()),
        ChangeNotifierProvider(create: (_) => TripsProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MyApp(initialToken: token),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? initialToken;
  const MyApp({super.key, required this.initialToken});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Daleel',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          // إذا كان هناك Token، استدعاء /me ثم الانتقال للرئيسية أو الشاشة الأولى
          home: initialToken != null
              ? FutureBuilder<Widget>(
                  future: _checkTokenAndNavigate(context, initialToken!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Scaffold(body: Center(child: CircularProgressIndicator()));
                    }
                    return snapshot.data ?? const Splash1();
                  },
                )
              : const Splash1(),
        );
      },
    );
  }

  Future<Widget> _checkTokenAndNavigate(BuildContext context, String token) async {
    final userProvider = context.read<UserProvider>();
    try {
      final url = Uri.parse('https://auth-login-for-daleel1.vercel.app/auth/me');
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userData = data['user'] ?? data;
        if (userData is Map<String, dynamic>) {
          final user = User(
            displayName: userData['username'] ?? userData['name'] ?? userData['email'],
            email: userData['email'],
            photoUrl: userData['photoUrl'],
            token: token,
          );
          userProvider.updateUser(user);
          return const HomePage();
        }
      }
    } catch (_) {}
    // فشل التلقائي – حذف الـ token المخزّن والعودة لشاشة البداية
    await userProvider.removeToken();
    return const Splash1();
  }
}