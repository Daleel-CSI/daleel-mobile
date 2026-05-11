import 'dart:io';
import 'dart:ui';
import 'package:daleel/account_screen.dart';
import 'package:daleel/help_about_bottom_sheets.dart';
import 'package:daleel/providers/user_provider.dart';
import 'package:daleel/settings_screen.dart';
import 'package:daleel/screen/auth/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildProfileHeader(user),
              const SizedBox(height: 30),
              _buildMenuSection(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
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
                        : user.photoUrl != null && user.photoUrl!.isNotEmpty
                            ? Image.network(user.photoUrl!, fit: BoxFit.cover)
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
          Text(
            user.displayName ?? user.email ?? 'مستخدم',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 4),
          if (user.email != null)
            Text(
              user.email!,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            )
          else
            Text(
              'اليوم الأربعاء 5 مايو',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // الحساب
          _buildMenuItem(
            title: 'الحساب',
            iconPath: 'assets/icons/user.svg',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          // الإعدادات
          _buildMenuItem(
            title: 'الإعدادات',
            iconPath: 'assets/icons/setting-02.svg',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          // المساعدة
          _buildMenuItem(
            title: 'المساعدة',
            iconPath: 'assets/icons/help-circle.svg',
            onTap: () => showHelpBottomSheet(context),
          ),
          const SizedBox(height: 12),
          // الوصف
          _buildMenuItem(
            title: 'الوصف',
            iconPath: 'assets/icons/information-circle.svg',
            onTap: () => showAboutBottomSheet(context),
          ),
          const SizedBox(height: 12),
          // تسجيل خروج
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
            Icon(Icons.arrow_back_ios,
                size: 18,
                color: isLogout ? Colors.red.shade400 : Colors.grey.shade600),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isLogout
                              ? Colors.red.shade600
                              : Theme.of(context).textTheme.bodyLarge?.color)),
                  const SizedBox(width: 12),
                  SvgPicture.asset(iconPath,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                          isLogout ? Colors.red.shade600 : const Color(0xFF379777),
                          BlendMode.srcIn)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePickerDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 24),
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                      color: Color(0xFFB2E4D0), shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt,
                      size: 28, color: Color(0xFF379777)),
                ),
                const SizedBox(height: 16),
                Text('تغيير صورة الحساب',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color)),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text('اختر مصدر الصورة',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey.shade600)),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _AnimatedDialogButton(
                        icon: Icons.camera_alt_outlined,
                        title: 'التقاط صورة',
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera);
                        },
                      ),
                      const SizedBox(height: 12),
                      _AnimatedDialogButton(
                        icon: Icons.photo_library_outlined,
                        title: 'اختيار من المعرض',
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Text('إلغاء',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('تم تحديث الصورة بنجاح'),
                ],
              ),
              backgroundColor: const Color(0xFF379777),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 24),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      color: Colors.red.shade50, shape: BoxShape.circle),
                  child: Icon(Icons.logout,
                      size: 28, color: Colors.red.shade600),
                ),
                const SizedBox(height: 16),
                Text('تسجيل الخروج',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color)),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text('هل أنت متأكد من رغبتك في تسجيل الخروج من حسابك؟',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.5)),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _AnimatedDialogButton(
                          icon: Icons.close,
                          title: 'إلغاء',
                          onTap: () => Navigator.pop(context),
                          isSecondary: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _AnimatedDialogButton(
                          icon: Icons.logout,
                          title: 'تسجيل خروج',
                          onTap: () {
                            Navigator.pop(context);
                            _logout();
                          },
                          isDanger: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final user = context.read<UserProvider>().user;
    if (user.token != null && user.token!.isNotEmpty) {
      try {
        final url = Uri.parse('https://auth-login-for-daleel1.vercel.app/auth/logout');
        await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${user.token}',
          },
          body: json.encode({'token': user.token}),
        );
      } catch (_) {}
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) context.read<UserProvider>().clearUser();
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (route) => false,
      );
    }
  }
}

// ========== AnimatedCard + AnimatedDialogButton (كما هي) ==========
class _AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  const _AnimatedCard({required this.child, this.onTap, this.margin});
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
          margin: widget.margin,
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
    Color getColor() {
      if (widget.isDanger) return Colors.red.shade600;
      if (widget.isSecondary) return Colors.grey.shade700;
      return const Color(0xFF379777);
    }
    Color getBgColor() {
      if (_isPressed) return getColor();
      if (widget.isDanger) return Colors.red.shade50;
      if (widget.isSecondary) return Colors.grey.shade100;
      return const Color(0xFFB2E4D0);
    }
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
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: getColor().withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
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