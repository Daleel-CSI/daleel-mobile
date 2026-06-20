// ============================================================
//                      settings_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:daleel/api/api_service.dart';
import 'package:daleel/providers/theme_provider.dart';
import 'package:daleel/providers/user_provider.dart';
import 'package:daleel/screen/auth/auth_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoadingSettings = true;
  bool _isSavingTheme = false;
  bool _isSavingNotifications = false;
  // ignore: unused_field
  bool _isClearingCache = false;
  bool _notificationsEnabled = true;

  static const String _privacyUrl = 'https://daleel-csi.netlify.app/privacy';
  static const String _termsUrl = 'https://daleel-csi.netlify.app/terms';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final userProvider = context.read<UserProvider>();
    final token = userProvider.token;

    final settings = await ApiService.getSettings(token: token);
    if (!mounted) return;

    if (settings != null) {
      final notifEnabled = settings['notificationsEnabled'];
      if (notifEnabled != null && notifEnabled is bool) {
        _notificationsEnabled = notifEnabled;
      }
      final theme = settings['theme'];
      final isDark = (theme == 'dark');
      final themeProvider = context.read<ThemeProvider>();
      if (isDark != themeProvider.isDarkMode) {
        themeProvider.toggleTheme();
      }
    }

    setState(() {
      _isLoadingSettings = false;
    });
  }

  void _showSessionExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'انتهت الجلسة',
          textAlign: TextAlign.right,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى للمتابعة.',
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen(startWithLogin: true)),
              );
            },
            child: const Text('تسجيل الدخول'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleThemeToggle(bool value) async {
    context.read<ThemeProvider>().toggleTheme();
    setState(() => _isSavingTheme = true);
    final userProvider = context.read<UserProvider>();
    final token = userProvider.token;

    final ok = await ApiService.updateThemeSetting(
      darkMode: value,
      token: token,
    );

    setState(() => _isSavingTheme = false);

    if (!mounted) return;
    if (!ok) {
      context.read<ThemeProvider>().toggleTheme();

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
          ),
        );
        _showSessionExpiredDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('فشل حفظ التفضيل، حاول مرة أخرى.'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _handleNotificationToggle(bool value) async {
    setState(() {
      _notificationsEnabled = value;
      _isSavingNotifications = true;
    });

    final userProvider = context.read<UserProvider>();
    final token = userProvider.token;

    final ok = await ApiService.updateNotificationSetting(
      enabled: value,
      token: token,
    );

    setState(() => _isSavingNotifications = false);

    if (!mounted) return;
    if (!ok) {
      setState(() => _notificationsEnabled = !value);

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
          ),
        );
        _showSessionExpiredDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('فشل حفظ الإشعارات، حاول مرة أخرى.'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoadingSettings
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF379777)))
            : Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildSectionTitle('المظهر'),
                          const SizedBox(height: 12),
                          _buildThemeToggleCard(
                            isDark: isDark,
                            value: context.watch<ThemeProvider>().isDarkMode,
                            onChanged: _handleThemeToggle,
                            loading: _isSavingTheme,
                          ),
                          const SizedBox(height: 24),

                          _buildSectionTitle('الإشعارات'),
                          const SizedBox(height: 12),
                          _buildNotificationToggleCard(
                            isDark: isDark,
                            value: _notificationsEnabled,
                            onChanged: _handleNotificationToggle,
                            loading: _isSavingNotifications,
                          ),
                          const SizedBox(height: 24),

                          _buildSectionTitle('التخزين'),
                          const SizedBox(height: 12),
                          _buildActionCard(
                            isDark: isDark,
                            title: 'مسح ذاكرة التخزين المؤقت',
                            subtitle: 'توفير مساحة على الجهاز',
                            icon: 'assets/icons/trash.svg',
                            onTap: () => _showClearCacheDialog(),
                          ),
                          const SizedBox(height: 24),

                          _buildSectionTitle('الخصوصية والأمان'),
                          const SizedBox(height: 12),
                          _buildActionCard(
                            isDark: isDark,
                            title: 'سياسة الخصوصية',
                            subtitle: 'اطلع على سياسة الخصوصية',
                            icon: 'assets/icons/user-shield-02.svg',
                            onTap: () => _launchUrl(_privacyUrl),
                          ),
                          const SizedBox(height: 12),
                          _buildActionCard(
                            isDark: isDark,
                            title: 'شروط الاستخدام',
                            subtitle: 'اقرأ شروط استخدام التطبيق',
                            icon: 'assets/icons/file-02.svg',
                            onTap: () => _launchUrl(_termsUrl),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
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
          const Expanded(
            child: Text(
              'الإعدادات',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF379777)),
    );
  }

  Widget _buildThemeToggleCard({
    required bool isDark,
    required bool value,
    required Function(bool) onChanged,
    required bool loading,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          loading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF379777)))
              : Switch(
                  value: value,
                  onChanged: loading ? null : onChanged,
                  activeColor: const Color(0xFF379777),
                  activeTrackColor: const Color(0xFFB2E4D0),
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('الوضع الليلي', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('تفعيل المظهر الداكن', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF379777).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SvgPicture.asset(
              'assets/icons/moon-eclipse.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Color(0xFF379777), BlendMode.srcIn),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationToggleCard({
    required bool isDark,
    required bool value,
    required Function(bool) onChanged,
    required bool loading,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          loading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF379777)))
              : Switch(
                  value: value,
                  onChanged: loading ? null : onChanged,
                  activeColor: const Color(0xFF379777),
                  activeTrackColor: const Color(0xFFB2E4D0),
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('الإشعارات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('تلقي الإشعارات والتنبيهات', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF379777).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SvgPicture.asset(
              'assets/icons/notification.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Color(0xFF379777), BlendMode.srcIn),
            ),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
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
              decoration: BoxDecoration(
                color: const Color(0xFF379777).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SvgPicture.asset(
                icon,
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(Color(0xFF379777), BlendMode.srcIn),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'مسح ذاكرة التخزين المؤقت',
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل تريد مسح ذاكرة التخزين المؤقت؟ سيتم حذف الملفات المؤقتة لتوفير مساحة.',
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearCache();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF379777),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCache() async {
    setState(() => _isClearingCache = true);
    final userProvider = context.read<UserProvider>();
    final token = userProvider.token;

    await ApiService.clearServerCache(token: token);

    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    setState(() => _isClearingCache = false);
    _showSnackBar('تم مسح ذاكرة التخزين المؤقت بنجاح');
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) _showSnackBar('تعذر فتح الرابط');
      }
    } catch (e) {
      if (mounted) _showSnackBar('حدث خطأ أثناء فتح الرابط');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFF379777),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}