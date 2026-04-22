// lib/screens/profile_screen.dart
import 'dart:io';
// ignore: unnecessary_import
import 'dart:ui';
import 'package:daleel/account_screen.dart';
import 'package:daleel/ai_chat_screen.dart';
import 'package:daleel/help_about_bottom_sheets.dart';
import 'package:daleel/providers/theme_provider.dart';
import 'package:daleel/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart'; // ← هذا السطر المهم
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  bool _notificationsEnabled = true;
  // ignore: unused_field
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeDateFormatting(); // ← تهيئة التاريخ بالعربي
  }

  Future<void> _initializeDateFormatting() async {
    await initializeDateFormatting('ar'); // تهيئة اللغة العربية
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // التاريخ بالعربي (بعد التهيئة)
    final currentDate = DateFormat('EEEE d MMMM', 'ar').format(DateTime.now());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildProfileHeader(currentDate),
              const SizedBox(height: 30),
              _buildMenuSection(isDark),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== باقي الكود (نفس اللي كان قبل كده) ====================
  Widget _buildProfileHeader(String currentDate) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          GestureDetector(
            onTap: _showImagePickerDialog,
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF379777),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF379777).withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _profileImage != null
                        ? Image.file(_profileImage!, fit: BoxFit.cover)
                        : const CircleAvatar(
                            radius: 48,
                            backgroundColor: Color(0xFFB2E4D0),
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Color(0xFF379777),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF379777),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'عماد',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            currentDate,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildMenuItem(
            title: 'الحساب',
            iconPath: 'assets/icons/user.svg',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AccountScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            title: 'الإعدادات',
            iconPath: 'assets/icons/setting-02.svg',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          const SizedBox(height: 12),

          // داخل _buildMenuSection
          _buildMenuItem(
            title: 'دليل الذكاء الاصطناعي',
            iconPath:
                'assets/icons/smart-phone-03.svg', // ← موجود بالفعل في البروجكت
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AiChatScreen()),
            ),
          ),
          const SizedBox(height: 12),

          _buildToggleMenuItem(
            title: 'الإشعارات',
            iconPath: 'assets/icons/notification.svg',
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
          ),
          const SizedBox(height: 12),

          _buildToggleMenuItem(
            title: 'الوضع الليلي',
            iconPath: 'assets/icons/moon-eclipse.svg',
            value: context.watch<ThemeProvider>().isDarkMode,
            onChanged: (v) => context.read<ThemeProvider>().toggleTheme(),
          ),
          const SizedBox(height: 12),

          _buildMenuItem(
            title: 'المساعدة',
            iconPath: 'assets/icons/help-circle.svg',
            onTap: () => showHelpBottomSheet(context),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            title: 'الوصف',
            iconPath: 'assets/icons/information-circle.svg',
            onTap: () => showAboutBottomSheet(context),
          ),
          const SizedBox(height: 12),

          _buildMenuItem(
            title: 'تسجيل خروج',
            iconPath: 'assets/icons/logout-05.svg',
            onTap: _showLogoutDialog,
            isLogout: true,
          ),
        ],
      ),
    );
  }

  // ==================== باقي الدوال (نفسها) ====================
  Widget _buildMenuItem({
    required String title,
    required String iconPath,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return _AnimatedCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.arrow_back_ios,
              size: 18,
              color: isLogout ? Colors.red.shade400 : Colors.grey.shade600,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isLogout ? Colors.red.shade600 : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SvgPicture.asset(
                    iconPath,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      isLogout ? Colors.red.shade600 : const Color(0xFF379777),
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleMenuItem({
    required String title,
    required String iconPath,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return _AnimatedCard(
      onTap: null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF379777),
              activeTrackColor: const Color(0xFFB2E4D0),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SvgPicture.asset(
                    iconPath,
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF379777),
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePickerDialog() {
    /* ... نفس الكود السابق ... */
  }
  void _showLogoutDialog() {
    /* ... نفس الكود السابق ... */
  }
}

// ==================== AnimatedCard & AnimatedDialogButton (نفس الكود) ====================
class _AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _AnimatedCard({required this.child, this.onTap});
  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _isPressed = false);
              widget.onTap!();
            }
          : null,
      onTapCancel: widget.onTap != null
          ? () => setState(() => _isPressed = false)
          : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? const Color(0xFF379777).withOpacity(0.2)
                    : Colors.black.withOpacity(0.06),
                blurRadius: _isPressed ? 16 : 12,
                offset: Offset(0, _isPressed ? 6 : 4),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _AnimatedDialogButton extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDanger;
  final bool isSecondary;
  const _AnimatedDialogButton({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDanger = false,
    this.isSecondary = false,
  });
  @override
  State<_AnimatedDialogButton> createState() => _AnimatedDialogButtonState();
}

class _AnimatedDialogButtonState extends State<_AnimatedDialogButton> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    Color getColor() => widget.isDanger
        ? Colors.red.shade600
        : (widget.isSecondary ? Colors.grey.shade700 : const Color(0xFF379777));
    Color getBgColor() => _isPressed
        ? getColor()
        : (widget.isDanger
              ? Colors.red.shade50
              : (widget.isSecondary
                    ? Colors.grey.shade100
                    : const Color(0xFFB2E4D0)));

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: getBgColor(),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: _isPressed ? Colors.white : getColor(),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              widget.icon,
              size: 20,
              color: _isPressed ? Colors.white : getColor(),
            ),
          ],
        ),
      ),
    );
  }
}
