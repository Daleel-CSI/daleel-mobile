// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:daleel/home_page.dart';
import 'package:daleel/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:daleel/screen/auth/widgets/auth_text_field.dart';
import 'package:daleel/screen/auth/otp_verification_screen.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

// ============================================================
//                          AUTH SCREEN
// ============================================================
class AuthScreen extends StatefulWidget {
  final bool startWithLogin;
  const AuthScreen({super.key, this.startWithLogin = true});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentPage = 0;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  @override
  void initState() {
    super.initState();
    _currentPage = widget.startWithLogin ? 0 : 1;
    _pageController = PageController(initialPage: _currentPage);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    if (_currentPage == 1) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<User?> _fetchUserFromToken(String token) async {
    try {
      final url = Uri.parse(
        'https://auth-login-for-daleel1.vercel.app/auth/me',
      );
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userData = data['user'] ?? data;
        if (userData is Map<String, dynamic>) {
          return User(
            displayName:
                userData['username'] ??
                userData['name'] ??
                userData['fullName'] ??
                userData['displayName'],
            email: userData['email'],
            photoUrl: userData['photoUrl'],
            token: token,
            phone: userData['phone'],
          );
        }
      }
    } catch (_) {}
    return null;
  }

  String _fallbackDisplayName(String? email) {
    if (email == null || email.isEmpty) return 'مستخدم';
    return email.split('@').first;
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) return;

      final user = User(
        displayName: account.displayName,
        email: account.email,
        photoUrl: account.photoUrl,
      );

      if (user.displayName == null || user.displayName!.isEmpty) {
        final updatedUser = User(
          displayName: _fallbackDisplayName(user.email),
          email: user.email,
          photoUrl: user.photoUrl,
        );
        // ignore: duplicate_ignore
        // ignore: use_build_context_synchronously
        context.read<UserProvider>().updateUser(updatedUser);
      } else {
        context.read<UserProvider>().updateUser(user);
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) _showSnackBar('فشل تسجيل الدخول: $e', isError: true);
    }
  }

  void _onTabChanged(int index) {
    setState(() => _currentPage = index);
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    if (index == 0) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: const Color(0xFF379777),
          selectionColor: const Color(0xFF379777).withOpacity(0.3),
          selectionHandleColor: const Color(0xFF379777),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 70),
                    SvgPicture.asset('assets/images/logo.svg'),
                    const SizedBox(height: 40),
                    _AnimatedAuthTabs(
                      currentIndex: _currentPage,
                      animation: _animationController,
                      onTabChanged: _onTabChanged,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                    if (index == 0) {
                      _animationController.reverse();
                    } else {
                      _animationController.forward();
                    }
                  },
                  children: [
                    _LoginContent(
                      onGoogleSignIn: _handleGoogleSignIn,
                      fetchUserFromToken: _fetchUserFromToken,
                      fallbackDisplayName: _fallbackDisplayName,
                    ),
                    const _SignupContent(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isError ? Colors.red.shade600 : const Color(0xFF379777),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

// ============================================================
//                     شاشة تسجيل الدخول (Login)
// ============================================================
class _LoginContent extends StatefulWidget {
  final VoidCallback onGoogleSignIn;
  final Future<User?> Function(String) fetchUserFromToken;
  final String Function(String?) fallbackDisplayName;
  const _LoginContent({
    required this.onGoogleSignIn,
    required this.fetchUserFromToken,
    required this.fallbackDisplayName,
  });

  @override
  State<_LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<_LoginContent> {
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ========== تسجيل الدخول باستخدام Dio (بدون CookieManager) ==========
  Future<void> _handleLogin() async {
    print('🟢 _handleLogin called');

    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;
    if (email.isEmpty || password.isEmpty) {
      _showLocalSnackBar('يرجى ملء جميع الحقول', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final dio = Dio(BaseOptions(
        baseUrl: 'https://auth-login-for-daleel1.vercel.app',
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 30),
      ));

      print('🟡 Sending login request...');
      final response = await dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (!mounted) return;

      print('📡 Login Response Status: ${response.statusCode}');
      print('📦 Login Response Headers: ${response.headers}');
      print('📦 Login Response Body: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        // ✅ الإصلاح الجذري: الباك إند Supabase Auth حقيقي، والتوكن الصحيح
        // (JWT access_token) بيرجع جوه data['session']['access_token']
        // مش في data['token'] (مش موجود) ومش في الكوكي (connect.sid مالوش
        // علاقة بالـ Supabase auth، وده سبب الـ 401 "Invalid token" اللي
        // كنا بنواجهه في POST /services وأي route تاني بيتحقق من JWT حقيقي)
        String? token = data['session']?['access_token'] ??
            data['access_token'] ??
            data['token'] ??
            data['data']?['token'];

        String? cookie;
        final setCookieList = response.headers['set-cookie'];
        if (setCookieList != null && setCookieList.isNotEmpty) {
          final setCookie = setCookieList.first;
          final match = RegExp(r'connect\.sid=([^;]+)').firstMatch(setCookie);
          if (match != null) {
            cookie = match.group(1);
          }
        }

        // fallback أخير فقط لو مفيش access_token خالص (حالة غير متوقعة)
        if (token == null && cookie != null) {
          token = 'cookie_$cookie';
        }

        if (token == null || token.isEmpty) {
          _showLocalSnackBar('لم يتم استلام جلسة صالحة من الخادم', isError: true);
          setState(() => _isLoading = false);
          return;
        }

        final userData = data['user'] ?? data['data'] ?? data;
        String? displayName = userData['user_metadata']?['username'] ??
            userData['username'] ??
            userData['name'] ??
            userData['fullName'] ??
            userData['displayName'];
        String? emailUser = userData['email'];
        String? photoUrl = userData['user_metadata']?['avatar_url'] ??
            userData['photoUrl'] ??
            userData['picture'];
        String? phone = userData['user_metadata']?['phone'] ??
            userData['phone'];

        if (displayName == null || displayName.isEmpty) {
          displayName = widget.fallbackDisplayName(emailUser);
        }

        final user = User(
          displayName: displayName,
          email: emailUser ?? email,
          photoUrl: photoUrl,
          token: token,
          phone: phone,
          cookie: cookie,
        );

        context.read<UserProvider>().updateUser(user);
        print('✅ User updated with token: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        String errorMsg = 'فشل تسجيل الدخول';
        try {
          errorMsg = response.data['message'] ?? response.data['error'] ?? errorMsg;
        } catch (_) {}
        _showLocalSnackBar(errorMsg, isError: true);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('❌ Login Error: $e');
      if (e is DioException) {
        print('❌ Dio Error Type: ${e.type}');
        print('❌ Dio Error Message: ${e.message}');
        print('❌ Dio Error Response: ${e.response?.data}');
      }
      if (mounted) _showLocalSnackBar('حدث خطأ في الاتصال: $e', isError: true);
      setState(() => _isLoading = false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showLocalSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isError ? Colors.red.shade600 : const Color(0xFF379777),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showForgotPasswordSheet() {
    final TextEditingController emailCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'استعادة كلمة المرور',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'أدخل بريدك الإلكتروني وسنرسل لك رابطاً لإعادة تعيين كلمة المرور.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 20),
                AuthTextField(
                  hintText: 'البريد الإلكتروني',
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF379777),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final email = emailCtrl.text.trim();
                      if (email.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text('يرجى إدخال البريد الإلكتروني'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      try {
                        final url = Uri.parse(
                          'https://auth-login-for-daleel1.vercel.app/auth/forgot-password',
                        );
                        final response = await http.post(
                          url,
                          headers: {'Content-Type': 'application/json'},
                          body: json.encode({'email': email}),
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (response.statusCode == 200 ||
                            response.statusCode == 201) {
                          _showLocalSnackBar(
                            'تم إرسال رابط إعادة التعيين إلى بريدك الإلكتروني',
                          );
                        } else {
                          String errorMsg = 'فشل إرسال الطلب';
                          try {
                            errorMsg = json.decode(response.body)['message'];
                          } catch (_) {}
                          _showLocalSnackBar(errorMsg, isError: true);
                        }
                      } catch (e) {
                        if (ctx.mounted) Navigator.pop(ctx);
                        _showLocalSnackBar(
                          'حدث خطأ في الاتصال: $e',
                          isError: true,
                        );
                      }
                    },
                    child: const Text(
                      'إرسال',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildLabel('البريد الإلكتروني'),
                const SizedBox(height: 10),
                AuthTextField(
                  hintText: 'أدخل بريدك الإلكتروني',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                _buildLabel('كلمة المرور'),
                const SizedBox(height: 10),
                AuthTextField(
                  hintText: 'أدخل كلمة المرور',
                  isPassword: !_isPasswordVisible,
                  controller: _passCtrl,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () => setState(
                      () => _isPasswordVisible = !_isPasswordVisible,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _showForgotPasswordSheet,
                      child: Text(
                        'هل نسيت كلمة المرور؟',
                        style: const TextStyle(
                          color: Color(0xFF379777),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Text(
                          'تذكرني',
                          style: TextStyle(color: Colors.black87),
                        ),
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (v) =>
                              setState(() => _rememberMe = v ?? false),
                          activeColor: const Color(0xFF379777),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'أو تسجيل الدخول بإستخدام',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _SocialLoginButton(
                        imagePath: 'assets/icons/icons8-google 2.svg',
                        isSvg: true,
                        onTap: widget.onGoogleSignIn,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          print('🟢 Login button pressed!');
                          _handleLogin();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF379777),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'تسجيل دخول',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) => Align(
        alignment: Alignment.centerRight,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      );
}

// ============================================================
//                     شاشة إنشاء الحساب (Signup)
// ============================================================
class _SignupContent extends StatefulWidget {
  const _SignupContent();
  @override
  State<_SignupContent> createState() => _SignupContentState();
}

class _SignupContentState extends State<_SignupContent> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  final _emailCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _hasMinLength = false;
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _passwordsMatch = false;

  @override
  void initState() {
    super.initState();
    _passCtrl.addListener(_validatePassword);
    _confirmPassCtrl.addListener(_checkPasswordsMatch);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    _phoneCtrl.dispose();
    _dateCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final pass = _passCtrl.text;
    setState(() {
      _hasMinLength = pass.length >= 8;
      _hasUpperCase = pass.contains(RegExp(r'[A-Z]'));
      _hasLowerCase = pass.contains(RegExp(r'[a-z]'));
      _hasNumber = pass.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = pass.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
    _checkPasswordsMatch();
  }

  void _checkPasswordsMatch() {
    setState(() {
      _passwordsMatch =
          _passCtrl.text.isNotEmpty && _passCtrl.text == _confirmPassCtrl.text;
    });
  }

  bool get _isPasswordValid =>
      _hasMinLength &&
      _hasUpperCase &&
      _hasLowerCase &&
      _hasNumber &&
      _hasSpecialChar;

  Future<void> _handleSignup() async {
    final email = _emailCtrl.text.trim();
    final username = _usernameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final dateOfBirth = _dateCtrl.text.trim();
    final password = _passCtrl.text;

    if (email.isEmpty ||
        username.isEmpty ||
        phone.isEmpty ||
        password.isEmpty) {
      _showLocalSnackBar('يرجى ملء جميع الحقول', isError: true);
      return;
    }
    if (!_isPasswordValid) {
      _showLocalSnackBar(
        'كلمة المرور لا تستوفي الشروط المطلوبة',
        isError: true,
      );
      return;
    }
    if (!_passwordsMatch) {
      _showLocalSnackBar('كلمة المرور غير متطابقة', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse(
        'https://auth-login-for-daleel1.vercel.app/auth/register',
      );
      final body = {
        'email': email,
        'username': username,
        'phone': phone,
        'dateOfBirth': dateOfBirth,
        'password': password,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final otpUrl = Uri.parse(
          'https://auth-login-for-daleel1.vercel.app/auth/resend-otp',
        );
        await http.post(
          otpUrl,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'email': email}),
        );
        _showLocalSnackBar('تم إنشاء الحساب وإرسال رمز التحقق إلى بريدك');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(email: email),
          ),
        );
      } else {
        String errorMsg = 'فشل إنشاء الحساب';
        try {
          final errorData = json.decode(response.body);
          errorMsg = errorData['message'] ?? errorData['error'] ?? errorMsg;
        } catch (_) {}
        _showLocalSnackBar(errorMsg, isError: true);
      }
    } catch (e) {
      if (mounted) _showLocalSnackBar('حدث خطأ في الاتصال: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showLocalSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isError ? Colors.red.shade600 : const Color(0xFF379777),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF379777),
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF379777),
            ),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dateCtrl.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _buildField(
                  'البريد الإلكتروني',
                  _emailCtrl,
                  hint: 'أدخل بريدك الإلكتروني',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                _buildField(
                  'رقم الهاتف',
                  _phoneCtrl,
                  hint: '+201000000000',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                _buildField(
                  'اسم المستخدم',
                  _usernameCtrl,
                  hint: 'أدخل اسم المستخدم',
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 20),
                _buildDateField(),
                const SizedBox(height: 20),
                _buildPasswordField(),
                if (_passCtrl.text.isNotEmpty) _passwordRequirements(),
                const SizedBox(height: 20),
                _buildConfirmPasswordField(),
                if (_confirmPassCtrl.text.isNotEmpty) _buildMatchIndicator(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        _buildBottomButton(),
      ],
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    required String hint,
    TextInputType? keyboardType,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          AuthTextField(
            hintText: hint,
            controller: ctrl,
            keyboardType: keyboardType,
          ),
        ],
      );

  Widget _buildDateField() => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'تاريخ الميلاد',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _selectDate,
            child: AbsorbPointer(
              child: AuthTextField(
                hintText: 'يوم/شهر/سنة',
                controller: _dateCtrl,
                suffixIcon: const Icon(
                  Icons.calendar_today_outlined,
                  color: Color(0xFF379777),
                ),
              ),
            ),
          ),
        ],
      );

  Widget _buildPasswordField() => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'كلمة المرور',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          AuthTextField(
            hintText: 'أدخل كلمة المرور',
            isPassword: !_isPasswordVisible,
            controller: _passCtrl,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.grey.shade600,
              ),
              onPressed: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
          ),
        ],
      );

  Widget _passwordRequirements() => Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'يجب أن تحتوي كلمة المرور على:',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            _ReqWidget(text: '8 أحرف على الأقل', met: _hasMinLength),
            _ReqWidget(text: 'حرف كبير (A-Z)', met: _hasUpperCase),
            _ReqWidget(text: 'حرف صغير (a-z)', met: _hasLowerCase),
            _ReqWidget(text: 'رقم (0-9)', met: _hasNumber),
            _ReqWidget(text: 'رمز خاص (!@#\$%)', met: _hasSpecialChar),
          ],
        ),
      );

  Widget _buildConfirmPasswordField() => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'تأكيد كلمة المرور',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          AuthTextField(
            hintText: 'أعد إدخال كلمة المرور',
            isPassword: !_isConfirmPasswordVisible,
            controller: _confirmPassCtrl,
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.grey.shade600,
              ),
              onPressed: () => setState(
                () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
              ),
            ),
          ),
        ],
      );

  Widget _buildMatchIndicator() => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            Icon(
              _passwordsMatch ? Icons.check_circle : Icons.cancel,
              size: 16,
              color: _passwordsMatch ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              _passwordsMatch ? 'كلمة المرور متطابقة' : 'كلمة المرور غير متطابقة',
              style: TextStyle(
                color: _passwordsMatch ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );

  Widget _buildBottomButton() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSignup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF379777),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'التالي',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      );
}

class _ReqWidget extends StatelessWidget {
  final String text;
  final bool met;
  const _ReqWidget({required this.text, required this.met});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              met ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 16,
              color: met ? Colors.green : Colors.grey.shade400,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: met ? Colors.green : Colors.grey.shade600,
                fontWeight: met ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
}

// ============================================================
//                      التابات المتحركة
// ============================================================
class _AnimatedAuthTabs extends StatelessWidget {
  final int currentIndex;
  final AnimationController animation;
  final Function(int) onTabChanged;
  const _AnimatedAuthTabs({
    required this.currentIndex,
    required this.animation,
    required this.onTabChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final screenWidth = MediaQuery.of(context).size.width - 48;
              final tabWidth = screenWidth / 2;
              return Positioned(
                left: animation.value * tabWidth,
                width: tabWidth,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onTabChanged(0),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      'تسجيل دخول',
                      style: TextStyle(
                        fontSize: 16,
                        color: currentIndex == 0
                            ? Colors.black
                            : Colors.grey.shade600,
                        fontWeight: currentIndex == 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onTabChanged(1),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      'إنشاء حساب',
                      style: TextStyle(
                        fontSize: 16,
                        color: currentIndex == 1
                            ? Colors.black
                            : Colors.grey.shade600,
                        fontWeight: currentIndex == 1
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
//                    زر تسجيل الدخول الاجتماعي
// ============================================================
class _SocialLoginButton extends StatelessWidget {
  final String? imagePath;
  final bool isSvg;
  final VoidCallback onTap;
  const _SocialLoginButton({
    this.imagePath,
    this.isSvg = false,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: const Color(0xFF379777).withOpacity(0.1),
        highlightColor: const Color(0xFF379777).withOpacity(0.05),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
          ),
          child: Container(
            height: 56,
            alignment: Alignment.center,
            child: imagePath != null && isSvg
                ? SvgPicture.asset(imagePath!, width: 28, height: 28)
                : const Icon(Icons.login, size: 28),
          ),
        ),
      ),
    );
  }
}