// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  static const String _key = 'isDarkMode';

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  // تحميل الثيم المحفوظ
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_key) ?? false;
    notifyListeners();
  }

  // تغيير الثيم
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, _isDarkMode);
    notifyListeners();
  }

  // الثيم الفاتح
  ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF379777),
        scaffoldBackgroundColor: Colors.white,
        brightness: Brightness.light,
        
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF379777),
          secondary: Color(0xFFB2E4D0),
          surface: Colors.white,
          surfaceContainerHighest: Color(0xFFF5F5F5),
        ),
        
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF379777), width: 2),
          ),
        ),
        
        // Scrollbar Theme
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(const Color(0xFF379777).withOpacity(0.7)),
          trackColor: WidgetStateProperty.all(Colors.grey.shade200),
          radius: const Radius.circular(10),
          thickness: WidgetStateProperty.all(6),
          thumbVisibility: WidgetStateProperty.all(false),
        ),
      );

  // الثيم الداكن
  ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF379777),
        scaffoldBackgroundColor: const Color(0xFF0A0A0A), // أغمق
        brightness: Brightness.dark,
        
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF379777),
          secondary: Color(0xFFB2E4D0),
          
          // الخلفيات
          surface: Color(0xFF252525), // الكروت - أفتح بوضوح
          surfaceContainerHighest: Color(0xFF353535), // العناصر المرتفعة
          surfaceContainer: Color(0xFF252525),
          surfaceContainerLow: Color(0xFF1A1A1A),
          surfaceContainerLowest: Color(0xFF0F0F0F),
          
          // النصوص
          onSurface: Color(0xFFE0E0E0), // النصوص على السطوح
          onSurfaceVariant: Color(0xFFAAAAAA), // النصوص الثانوية
          onPrimary: Colors.white,
          
          // الحدود
          outline: Color(0xFF404040),
          outlineVariant: Color(0xFF2A2A2A),
        ),
        
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF252525),
          foregroundColor: Color(0xFFE0E0E0),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        
        cardTheme: CardThemeData(
          color: const Color(0xFF252525), 
          surfaceTintColor: Colors.transparent,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: const Color(0xFF404040).withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        
        // الأزرار
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF379777),
            foregroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
        ),
        
        // حقول الإدخال
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF353535), // أفتح من الكروت
          hoverColor: const Color(0xFF3A3A3A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF505050)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF505050)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF379777), width: 2),
          ),
        ),
        
        // الـ Dividers
        dividerTheme: const DividerThemeData(
          color: Color(0xFF404040),
          thickness: 1,
          space: 1,
        ),
        
        // Bottom Navigation Bar
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF252525),
          selectedItemColor: Color(0xFF379777),
          unselectedItemColor: Color(0xFF808080),
          elevation: 8,
        ),
        
        // Navigation Bar (Material 3)
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF252525),
          indicatorColor: const Color(0xFF379777).withOpacity(0.3),
          surfaceTintColor: Colors.transparent,
        ),
        
        // Dialog
        dialogTheme: DialogThemeData(
          backgroundColor: const Color(0xFF252525),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        
        // Bottom Sheet
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Color(0xFF252525),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
        ),
        
        // Drawer
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color(0xFF252525),
          surfaceTintColor: Colors.transparent,
        ),
        
        // List Tiles
        listTileTheme: const ListTileThemeData(
          tileColor: Color(0xFF252525),
        ),
        
        // Popup Menu
        popupMenuTheme: PopupMenuThemeData(
          color: const Color(0xFF252525),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        
        // Chip
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFF353535),
          selectedColor: const Color(0xFF379777),
          disabledColor: const Color(0xFF1A1A1A),
          labelStyle: const TextStyle(color: Color(0xFFE0E0E0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        
        // Switch
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF379777);
            }
            return const Color(0xFF808080);
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF379777).withOpacity(0.5);
            }
            return const Color(0xFF404040);
          }),
        ),
        
        // Text Selection
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: const Color(0xFF379777),
          selectionColor: const Color(0xFF379777).withOpacity(0.3),
          selectionHandleColor: const Color(0xFF379777),
        ),
        
        // Scrollbar Theme للـ Dark Mode
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(const Color(0xFF379777).withOpacity(0.7)),
          trackColor: WidgetStateProperty.all(const Color(0xFF404040)),
          radius: const Radius.circular(10),
          thickness: WidgetStateProperty.all(6),
          thumbVisibility: WidgetStateProperty.all(false),
        ),
        
        // Text Theme
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
          bodyMedium: TextStyle(color: Color(0xFFE0E0E0)),
          bodySmall: TextStyle(color: Color(0xFFAAAAAA)),
          titleLarge: TextStyle(color: Color(0xFFE0E0E0)),
          titleMedium: TextStyle(color: Color(0xFFE0E0E0)),
          titleSmall: TextStyle(color: Color(0xFFAAAAAA)),
        ),
      );
}