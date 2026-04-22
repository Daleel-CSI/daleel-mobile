// ============================================================
// HOW TO USE AppLocalizations IN YOUR SCREENS
// كيفية استخدام الترجمة في الـ screens
// ============================================================
//
// بدلاً من كتابة النص مباشرة:
//   Text('الإعدادات')
//
// اكتب كده:
//   Text(context.tr.settings)
//
// أو:
//   Text(AppLocalizations.of(context).settings)
//
// ============================================================

// مثال عملي على settings_screen.dart بعد التحويل:

import 'package:daleel/core/l10n/app_localizations.dart';  // ← أضف الـ import ده
import 'package:daleel/providers/locale_provider.dart';
import 'package:daleel/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'ar';
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('app_language') ?? 'ar';
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _soundEnabled = prefs.getBool('sound') ?? true;
      _vibrationEnabled = prefs.getBool('vibration') ?? true;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) await prefs.setBool(key, value);
    if (value is String) await prefs.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tr = context.tr; // ← الـ shortcut للترجمة

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, tr),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildSectionTitle(tr.language),       // ← كان: 'اللغة'
                    const SizedBox(height: 12),
                    _buildLanguageCard(isDark, tr),

                    const SizedBox(height: 24),

                    _buildSectionTitle(tr.appearance),     // ← كان: 'المظهر'
                    const SizedBox(height: 12),
                    _buildToggleCard(
                      isDark: isDark,
                      title: tr.darkMode,                 // ← كان: 'الوضع الليلي'
                      subtitle: tr.enableDarkMode,        // ← كان: 'تفعيل المظهر الداكن'
                      icon: 'assets/icons/moon-eclipse.svg',
                      value: context.watch<ThemeProvider>().isDarkMode,
                      onChanged: (value) {
                        context.read<ThemeProvider>().toggleTheme();
                      },
                    ),

                    const SizedBox(height: 24),

                    _buildSectionTitle(tr.notifications),  // ← كان: 'الإشعارات'
                    const SizedBox(height: 12),
                    _buildToggleCard(
                      isDark: isDark,
                      title: tr.notifications,
                      subtitle: tr.receiveNotifications,
                      icon: 'assets/icons/notification.svg',
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() => _notificationsEnabled = value);
                        _saveSetting('notifications', value);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildToggleCard(
                      isDark: isDark,
                      title: tr.sound,
                      subtitle: tr.enableSound,
                      icon: 'assets/icons/volume-high.svg',
                      value: _soundEnabled,
                      onChanged: (value) {
                        setState(() => _soundEnabled = value);
                        _saveSetting('sound', value);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildToggleCard(
                      isDark: isDark,
                      title: tr.vibration,
                      subtitle: tr.enableVibration,
                      icon: 'assets/icons/smart-phone-03.svg',
                      value: _vibrationEnabled,
                      onChanged: (value) {
                        setState(() => _vibrationEnabled = value);
                        _saveSetting('vibration', value);
                      },
                    ),

                    const SizedBox(height: 24),

                    _buildSectionTitle(tr.storage),
                    const SizedBox(height: 12),
                    _buildActionCard(
                      isDark: isDark,
                      title: tr.clearCache,
                      subtitle: tr.saveDiskSpace,
                      icon: 'assets/icons/trash.svg',
                      onTap: _showClearCacheDialog,
                    ),

                    const SizedBox(height: 24),

                    _buildSectionTitle(tr.privacyAndSecurity),
                    const SizedBox(height: 12),
                    _buildActionCard(
                      isDark: isDark,
                      title: tr.privacyPolicy,
                      subtitle: tr.viewPrivacyPolicy,
                      icon: 'assets/icons/user-shield-02.svg',
                      onTap: () => _showPolicyDialog(tr.privacyPolicy),
                    ),
                    const SizedBox(height: 12),
                    _buildActionCard(
                      isDark: isDark,
                      title: tr.termsOfService,
                      subtitle: tr.readTerms,
                      icon: 'assets/icons/file-02.svg',
                      onTap: () => _showPolicyDialog(tr.termsOfService),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations tr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF379777), size: 20),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF379777).withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          Expanded(
            child: Text(
              tr.settings, // ← كان: 'الإعدادات'
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF379777)));
  }

  Widget _buildLanguageCard(bool isDark, AppLocalizations tr) {
    final currentLangName = _selectedLanguage == 'ar' ? tr.arabic : tr.english;

    return GestureDetector(
      onTap: () => _showLanguageBottomSheet(tr),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.04), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            const Icon(Icons.arrow_back_ios, size: 16, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(tr.appLanguage, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(currentLangName, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF379777).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: SvgPicture.asset('assets/icons/language-circle.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF379777), BlendMode.srcIn)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleCard({
    required bool isDark,
    required String title,
    required String subtitle,
    required String icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF379777), activeTrackColor: const Color(0xFFB2E4D0)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF379777).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: SvgPicture.asset(icon, width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF379777), BlendMode.srcIn)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required bool isDark,
    required String title,
    required String subtitle,
    required String icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.04), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            const Icon(Icons.arrow_back_ios, size: 16, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF379777).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: SvgPicture.asset(icon, width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF379777), BlendMode.srcIn)),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(AppLocalizations tr) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text(tr.chooseLanguage, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildLanguageOption(
              language: tr.arabic,
              flag: '🇪🇬',
              langCode: 'ar',
              isSelected: _selectedLanguage == 'ar',
            ),
            const SizedBox(height: 12),
            _buildLanguageOption(
              language: tr.english,
              flag: '🇺🇸',
              langCode: 'en',
              isSelected: _selectedLanguage == 'en',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required String language,
    required String flag,
    required String langCode,
    required bool isSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () async {
        // ✅ غير اللغة في الـ provider - هيحدث كل التطبيق فوراً
        await context.read<LocaleProvider>().changeLanguage(langCode);
        setState(() => _selectedLanguage = langCode);
        _saveSetting('app_language', langCode);
        if (mounted) Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF379777).withOpacity(0.1) : (isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFF379777) : (isDark ? Colors.grey.shade800 : Colors.grey.shade200), width: 1.5),
        ),
        child: Row(
          children: [
            if (isSelected) ...[
              const Icon(Icons.check_circle, color: Color(0xFF379777), size: 24),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                language,
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? const Color(0xFF379777) : null),
              ),
            ),
            const SizedBox(width: 12),
            Text(flag, style: const TextStyle(fontSize: 32)),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    final tr = context.tr;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(tr.clearCache, textAlign: TextAlign.right, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: Text(tr.clearCacheConfirm, textAlign: TextAlign.right),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(tr.cancel, style: const TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(children: [const Icon(Icons.check_circle, color: Colors.white), const SizedBox(width: 12), Text(tr.clearCacheSuccess)]),
                    backgroundColor: const Color(0xFF379777),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF379777), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(tr.save),
          ),
        ],
      ),
    );
  }

  void _showPolicyDialog(String title) {
    final tr = context.tr;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(tr.contentComingSoon, textAlign: TextAlign.center),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(tr.ok, style: const TextStyle(color: Color(0xFF379777)))),
        ],
      ),
    );
  }
}
