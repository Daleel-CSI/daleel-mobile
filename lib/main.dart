import 'package:daleel/core/l10n/app_localizations.dart';
import 'package:daleel/core/themes/app_theme.dart';
import 'package:daleel/providers/app_provider.dart';
import 'package:daleel/providers/locale_provider.dart';
import 'package:daleel/providers/theme_provider.dart';
import 'package:daleel/screen/slpashes/splash_1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localeProvider = LocaleProvider();
  await localeProvider.loadLocale();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ServicesProvider()),
        ChangeNotifierProvider(create: (_) => TripsProvider()),
        ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, child) {
        final isArabic = localeProvider.locale.languageCode == 'ar';

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Daleel',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode:
              themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

          // اللغة الديناميكية - لما تتغير هنا بتتغير في كل التطبيق
          locale: localeProvider.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // الحل الصح للـ RTL/LTR
          // عربي = يمين لشمال | إنجليزي = شمال ليمين
          builder: (context, child) {
            return Directionality(
              textDirection:
                  isArabic ? TextDirection.rtl : TextDirection.ltr,
              child: child!,
            );
          },

          home: const Splash1(),
        );
      },
    );
  }
}
