import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:daleel/providers/user_provider.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<UserProvider>().user;

    final userName = user.displayName ?? 'مستخدم';
    final userPhone = user.phone ?? 'غير مضاف';
    final userEmail = user.email ?? 'غير مضاف';

    // تحديد ما إذا كانت الصورة رابط (http) أم ملف محلي
    final String? photoUrl = user.photoUrl;
    final bool isNetworkImage = photoUrl != null && photoUrl.startsWith('http');
    final bool isFileImage = photoUrl != null && !photoUrl.startsWith('http') && File(photoUrl).existsSync();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // صورة البروفايل
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
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
                          child: isNetworkImage
                              ? Image.network(
                                  photoUrl,
                                  fit: BoxFit.cover,
                                  width: 120,
                                  height: 120,
                                  // ignore: unnecessary_underscores
                                  errorBuilder: (_, __, ___) =>
                                      _defaultAvatar(),
                                )
                              : isFileImage
                                  ? Image.file(
                                      File(photoUrl),
                                      fit: BoxFit.cover,
                                      width: 120,
                                      height: 120,
                                      // ignore: unnecessary_underscores
                                      errorBuilder: (_, __, ___) =>
                                          _defaultAvatar(),
                                    )
                                  : _defaultAvatar(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // الاسم الكامل
                    _buildInfoCard(
                      isDark: isDark,
                      label: 'الاسم الكامل',
                      value: userName,
                      icon: 'assets/icons/user.svg',
                    ),

                    const SizedBox(height: 16),

                    // رقم الهاتف
                    _buildInfoCard(
                      isDark: isDark,
                      label: 'رقم الهاتف',
                      value: userPhone,
                      icon: 'assets/icons/smart-phone-01.svg',
                    ),

                    const SizedBox(height: 16),

                    // البريد الإلكتروني
                    _buildInfoCard(
                      isDark: isDark,
                      label: 'البريد الإلكتروني',
                      value: userEmail,
                      icon: 'assets/icons/mail-01.svg',
                    ),

                    const SizedBox(height: 16),

                    // تاريخ الانضمام (مثال ثابت)
                    _buildInfoCard(
                      isDark: isDark,
                      label: 'تاريخ الانضمام',
                      value: '15 يناير 2024',
                      icon: 'assets/icons/calendar-02.svg',
                    ),

                    const SizedBox(height: 30),

                    // زر تعديل الحساب
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          final currentUser = context.read<UserProvider>().user;
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditAccountScreen(
                                initialName: currentUser.displayName ?? '',
                                initialPhone: currentUser.phone ?? '',
                                initialEmail: currentUser.email ?? '',
                                initialImage: (currentUser.photoUrl != null &&
                                        !currentUser.photoUrl!.startsWith('http') &&
                                        File(currentUser.photoUrl!).existsSync())
                                    ? File(currentUser.photoUrl!)
                                    : null,
                              ),
                            ),
                          );
                          // بعد العودة، يتم إعادة بناء الشاشة من UserProvider
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF379777),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: const Color(0xFF379777).withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'تعديل الحساب',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SvgPicture.asset(
                              'assets/icons/user-edit-01.svg',
                              width: 24,
                              height: 24,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _defaultAvatar() {
    return const CircleAvatar(
      radius: 58,
      backgroundColor: Color(0xFFB2E4D0),
      child: Icon(
        Icons.person,
        size: 60,
        color: Color(0xFF379777),
      ),
    );
  }

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
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF379777),
              size: 20,
            ),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF379777).withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'معلومات الحساب',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required bool isDark,
    required String label,
    required String value,
    required String icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1.5,
        ),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
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
              colorFilter: const ColorFilter.mode(
                Color(0xFF379777),
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// صفحة تعديل الحساب (مع الحفاظ على الوظائف)
// ==========================================

class EditAccountScreen extends StatefulWidget {
  final String initialName;
  final String initialPhone;
  final String initialEmail;
  final File? initialImage;

  const EditAccountScreen({
    super.key,
    required this.initialName,
    required this.initialPhone,
    required this.initialEmail,
    this.initialImage,
  });

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  final ImagePicker _imagePicker = ImagePicker();
  File? _profileImage;

  late String _originalName;
  late String _originalPhone;
  late String _originalEmail;

  @override
  void initState() {
    super.initState();
    _originalName = widget.initialName;
    _originalPhone = widget.initialPhone;
    _originalEmail = widget.initialEmail;

    _nameController = TextEditingController(text: widget.initialName);
    _phoneController = TextEditingController(text: widget.initialPhone);
    _emailController = TextEditingController(text: widget.initialEmail);
    _profileImage = widget.initialImage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool _hasChanges() {
    return _nameController.text != _originalName ||
        _phoneController.text != _originalPhone ||
        _emailController.text != _originalEmail ||
        _profileImage != null;
  }

  Future<bool> _onWillPop() async {
    if (_hasChanges()) {
      final result = await _showExitDialog();
      return result ?? false;
    }
    return true;
  }

  Future<bool?> _showExitDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                const Color(0xFF379777).withOpacity(0.02),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'تحذير',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'لديك تعديلات غير محفوظة!\nهل تريد المغادرة دون حفظ التغييرات؟',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: const Text(
                        'البقاء',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF379777),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'المغادرة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'اختر مصدر الصورة',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildImageSourceOption(
              icon: Icons.camera_alt,
              title: 'التقاط صورة',
              subtitle: 'استخدام الكاميرا',
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 12),
            _buildImageSourceOption(
              icon: Icons.photo_library,
              title: 'اختيار من المعرض',
              subtitle: 'تصفح الصور المحفوظة',
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'إلغاء',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF379777).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF379777),
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
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
                  Expanded(
                    child: Text(
                      'تم تحديد الصورة بنجاح',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF379777),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'حدث خطأ أثناء اختيار الصورة: $e',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final userProvider = context.read<UserProvider>();
      userProvider.updateUserInfo(
        displayName: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        photoUrl: _profileImage?.path,
      );

      Navigator.pop(context);

      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'تم حفظ التغييرات بنجاح',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF379777),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
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
                                      ? Image.file(
                                          _profileImage!,
                                          fit: BoxFit.cover,
                                          width: 120,
                                          height: 120,
                                        )
                                      : const CircleAvatar(
                                          radius: 58,
                                          backgroundColor: Color(0xFFB2E4D0),
                                          child: Icon(
                                            Icons.person,
                                            size: 60,
                                            color: Color(0xFF379777),
                                          ),
                                        ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _showImageSourceDialog,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF379777),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF379777).withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        const Text(
                          'الاسم الكامل',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: _nameController,
                          hintText: 'أدخل اسمك الكامل',
                          icon: 'assets/icons/user.svg',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال الاسم';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'رقم الهاتف',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: _phoneController,
                          hintText: 'أدخل رقم الهاتف',
                          icon: 'assets/icons/smart-phone-01.svg',
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال رقم الهاتف';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'البريد الإلكتروني',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: _emailController,
                          hintText: 'أدخل البريد الإلكتروني',
                          icon: 'assets/icons/mail-01.svg',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال البريد الإلكتروني';
                            }
                            if (!value.contains('@')) {
                              return 'البريد الإلكتروني غير صحيح';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _saveChanges,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF379777),
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shadowColor: const Color(0xFF379777).withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'حفظ التغييرات',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.check_circle_outline, size: 24),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
            onPressed: () async {
              if (await _onWillPop()) {
                // ignore: use_build_context_synchronously
                if (mounted) Navigator.pop(context);
              }
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF379777),
              size: 20,
            ),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF379777).withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'تعديل الحساب',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      textAlign: TextAlign.right,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 16),
      validator: validator,
      cursorColor: const Color(0xFF379777),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: SvgPicture.asset(
            icon,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              Color(0xFF379777),
              BlendMode.srcIn,
            ),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF379777), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}