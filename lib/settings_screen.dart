import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:daleel/providers/theme_provider.dart';
import 'package:daleel/providers/user_provider.dart';
import 'package:http/http.dart' as http;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _privacyUrl = 'https://daleel-csi.netlify.app/privacy';
  static const String _termsUrl = 'https://daleel-csi.netlify.app/terms';

  bool _notificationsEnabled = false;
  bool _soundEnabled = false;
  bool _vibrationEnabled = false;
  bool _isLoadingSettings = true;

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  // ────────────────────────────────────────────────────────────
  // جلب جميع الإعدادات من الخادم
  // ────────────────────────────────────────────────────────────
  Future<void> _fetchSettings() async {
    final token = context.read<UserProvider>().user.token;
    if (token == null || token.isEmpty) {
      setState(() => _isLoadingSettings = false);
      return;
    }

    try {
      final url = Uri.parse('https://auth-login-for-daleel1.vercel.app/settings');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _notificationsEnabled = data['notifications'] ?? false;
          _soundEnabled = data['sound'] ?? false;
          _vibrationEnabled = data['vibration'] ?? false;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoadingSettings = false);
    }
  }

  // ────────────────────────────────────────────────────────────
  // تحديث إعداد معين (PUT لأي إندبوينت)
  // ────────────────────────────────────────────────────────────
  Future<void> _updateSetting(String path, Map<String, dynamic> body) async {
    final token = context.read<UserProvider>().user.token;
    if (token == null || token.isEmpty) return;

    try {
      final url = Uri.parse('https://auth-login-for-daleel1.vercel.app/$path');
      await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );
    } catch (_) {}
  }

  // ────────────────────────────────────────────────────────────
  // زر مسح ذاكرة التخزين المؤقت – مع استدعاء API
  // ────────────────────────────────────────────────────────────
  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('مسح ذاكرة التخزين المؤقت',
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: Text(
          'هل تريد مسح ذاكرة التخزين المؤقت؟ سيتم حذف الملفات المؤقتة لتوفير مساحة.',
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _clearCache();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF379777),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCache() async {
    // 1) إعلام الخادم بمسح الكاش (اختياري لكن بنربطه)
    await _updateSetting('settings/clear-cache', {}); // body فاضي أو حسب ما يطلبه الباك إند

    // 2) مسح الكاش المحلي
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    _showSnackBar('تم مسح ذاكرة التخزين المؤقت بنجاح');
  }

  // ────────────────────────────────────────────────────────────
  // بناء الواجهة
  // ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _isLoadingSettings
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF379777)),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // المظهر
                          _buildSectionTitle('المظهر'),
                          const SizedBox(height: 12),
                          _buildToggleCard(
                            isDark: isDark,
                            title: 'الوضع الليلي',
                            subtitle: 'تفعيل المظهر الداكن',
                            icon: 'assets/icons/moon-eclipse.svg',
                            value: context.watch<ThemeProvider>().isDarkMode,
                            onChanged: (value) {
                              context.read<ThemeProvider>().toggleTheme();
                              _updateSetting('settings/theme', {'darkMode': value});
                            },
                          ),

                          const SizedBox(height: 24),

                          // الإشعارات
                          _buildSectionTitle('الإشعارات'),
                          const SizedBox(height: 12),
                          _buildToggleCard(
                            isDark: isDark,
                            title: 'الإشعارات',
                            subtitle: 'تلقي الإشعارات والتنبيهات',
                            icon: 'assets/icons/notification.svg',
                            value: _notificationsEnabled,
                            onChanged: (value) {
                              setState(() => _notificationsEnabled = value);
                              _updateSetting('settings/notifications', {'enabled': value});
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildToggleCard(
                            isDark: isDark,
                            title: 'الصوت',
                            subtitle: 'تشغيل الصوت للإشعارات',
                            icon: 'assets/icons/volume-high.svg',
                            value: _soundEnabled,
                            onChanged: (value) {
                              setState(() => _soundEnabled = value);
                              _updateSetting('settings', {'sound': value});
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildToggleCard(
                            isDark: isDark,
                            title: 'الاهتزاز',
                            subtitle: 'اهتزاز الهاتف عند التنبيه',
                            icon: 'assets/icons/smart-phone-03.svg',
                            value: _vibrationEnabled,
                            onChanged: (value) {
                              setState(() => _vibrationEnabled = value);
                              _updateSetting('settings', {'vibration': value});
                            },
                          ),

                          const SizedBox(height: 24),

                          // التخزين
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

                          // الخصوصية
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

  // ────────────────────────────────────────────────────────────
  // الأدوات المساعدة (Headers, Cards, Dialogs, SnackBar…)
  // ────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF379777), size: 20),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF379777).withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const Expanded(
            child: Text('الإعدادات',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF379777)));
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
        border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF379777),
              activeTrackColor: const Color(0xFFB2E4D0)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            ]),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFF379777).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: SvgPicture.asset(icon,
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(Color(0xFF379777), BlendMode.srcIn)),
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
          border: Border.all(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, width: 1.5),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.arrow_back_ios, size: 16, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              ]),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: const Color(0xFF379777).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: SvgPicture.asset(icon,
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(Color(0xFF379777), BlendMode.srcIn)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 12),
          Text(message),
        ]),
        backgroundColor: const Color(0xFF379777),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
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
}