import 'package:daleel/home_page.dart';
import 'package:daleel/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:daleel/screen/auth/otp_verification_screen.dart';
import 'package:daleel/screen/auth/widgets/auth_text_field.dart';
import 'package:provider/provider.dart';

// ------------------------------------------------------------
//                          AUTH SCREEN
// ------------------------------------------------------------
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

  // ✅ Classic, working way for google_sign_in 7.2.0
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

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

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) return; // User cancelled
      // Get the full info
      // ignore: unused_local_variable
      final GoogleSignInAuthentication auth = await account.authentication;
      final user = User(
        displayName: account.displayName,
        email: account.email,
        photoUrl: account.photoUrl,
      );

      if (mounted) {
        context.read<UserProvider>().updateUser(user);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تسجيل الدخول: $e'),
            backgroundColor: Colors.red,
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

  void _onTabChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
                    setState(() {
                      _currentPage = index;
                    });
                    if (index == 0) {
                      _animationController.reverse();
                    } else {
                      _animationController.forward();
                    }
                  },
                  children: [
                    _LoginContent(onGoogleSignIn: _handleGoogleSignIn),
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
}

// ------------------------------------------------------------
//                        LOGIN CONTENT
// ------------------------------------------------------------
class _LoginContent extends StatefulWidget {
  final VoidCallback onGoogleSignIn;
  const _LoginContent({required this.onGoogleSignIn});

  @override
  State<_LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<_LoginContent> {
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
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
                      onPressed: () {},
                      child: Text(
                        'هل نسيت كلمة المرور؟',
                        style: TextStyle(
                          color: Color(0xFF379777),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text('تذكرني', style: TextStyle(color: Colors.black87)),
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (v) =>
                              setState(() => _rememberMe = v ?? false),
                          activeColor: Color(0xFF379777),
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
                // Only Google button – Apple removed
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
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF379777),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'تسجيل دخول',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
  );
}

// ------------------------------------------------------------
//                       SIGNUP CONTENT
// ------------------------------------------------------------
class _SignupContent extends StatefulWidget {
  const _SignupContent();

  @override
  State<_SignupContent> createState() => _SignupContentState();
}

class _SignupContentState extends State<_SignupContent> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

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

  void _handleSignup() {
    if (!_isPasswordValid) {
      _showSnackBar('كلمة المرور لا تستوفي الشروط المطلوبة', isError: true);
      return;
    }
    if (!_passwordsMatch) {
      _showSnackBar('كلمة المرور غير متطابقة', isError: true);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            OtpVerificationScreen(email: _emailCtrl.text, userName: ''),
      ),
    );
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: isError ? Colors.red.shade600 : Color(0xFF379777),
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
          colorScheme: ColorScheme.light(
            primary: Color(0xFF379777),
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Color(0xFF379777)),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dateCtrl.text = "${picked.day}/${picked.month}/${picked.year}";
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
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(
        label,
        style: TextStyle(
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
      Text(
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
            suffixIcon: Icon(
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
      Text(
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
      Text(
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
            onPressed: _handleSignup,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF379777),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
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

// ------------------------------------------------------------
//                      ANIMATED TABS
// ------------------------------------------------------------
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

// ------------------------------------------------------------
//                    SOCIAL LOGIN BUTTON
// ------------------------------------------------------------
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
