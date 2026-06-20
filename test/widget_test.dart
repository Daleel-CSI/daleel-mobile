import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:daleel/main.dart';
import 'package:daleel/providers/theme_provider.dart';
import 'package:daleel/providers/app_provider.dart';
import 'package:daleel/providers/user_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
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

    // التأكد إن التطبيق شغال
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}