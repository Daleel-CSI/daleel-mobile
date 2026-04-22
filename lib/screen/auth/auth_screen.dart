import 'package:daleel/screen/auth/otp_verification_screen.dart';
import 'package:daleel/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:daleel/screen/auth/widgets/auth_text_field.dart';

class AuthScreen extends StatefulWidget {
  final bool startWithLogin;
  
  const AuthScreen({
    super.key,
    this.startWithLogin = true,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentPage = 0;

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
              // الجزء الثابت - اللوجو والتابات
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 70),

                    // اللوجو
                    SvgPicture.asset(
                      'assets/images/logo.svg',
                    ),

                    const SizedBox(height: 40),

                    // التابات المخصصة مع Animation
                    _AnimatedAuthTabs(
                      currentIndex: _currentPage,
                      animation: _animationController,
                      onTabChanged: _onTabChanged,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),

              // الجزء المتحرك - PageView
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
                  children: const [
                    _LoginContent(),
                    _SignupContent(),
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

// Widget للتابات المتحركة
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
          // المؤشر المتحرك (أبيض بحجم كامل)
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final screenWidth = MediaQuery.of(context).size.width - 48;
              final tabWidth = screenWidth / 2;
              
              return Positioned(
                left: animation.value * tabWidth, // غيرنا من right لـ left
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
          // الأزرار
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onTabChanged(0),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      'تسجيل دخول',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: currentIndex == 0 ? Colors.black : Colors.grey.shade600,
                            fontWeight: currentIndex == 0 ? FontWeight.bold : FontWeight.normal,
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: currentIndex == 1 ? Colors.black : Colors.grey.shade600,
                            fontWeight: currentIndex == 1 ? FontWeight.bold : FontWeight.normal,
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

// محتوى صفحة تسجيل الدخول
class _LoginContent extends StatefulWidget {
  const _LoginContent();

  @override
  State<_LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<_LoginContent> {
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                // البريد الإلكتروني
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'البريد الإلكتروني',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(height: 10),
                AuthTextField(
                  hintText: 'أدخل بريدك الإلكتروني',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 20),

                // كلمة المرور
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'كلمة المرور',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(height: 10),
                AuthTextField(
                  hintText: 'أدخل كلمة المرور',
                  isPassword: !_isPasswordVisible,
                  controller: _passwordController,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // تذكرني + نسيت كلمة المرور
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'هل نسيت كلمة المرور؟',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF379777),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'تذكرني',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.black87,
                              ),
                        ),
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
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

                // أو تسجيل الدخول بإستخدام
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.grey.shade300, thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'أو تسجيل الدخول بإستخدام',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Colors.grey.shade300, thickness: 1),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // أزرار Google و Apple
                Row(
                  children: [
                    Expanded(
                      child: _SocialLoginButton(
                        imagePath: 'assets/icons/app.svg',
                        isSvg: true,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _SocialLoginButton(
                        imagePath: 'assets/icons/icons8-google 2.svg',
                        isSvg: true,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // زر تسجيل الدخول
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF379777),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'تسجيل دخول',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
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
}

// محتوى صفحة إنشاء الحساب
class _SignupContent extends StatefulWidget {
  const _SignupContent();

  @override
  State<_SignupContent> createState() => _SignupContentState();
}

class _SignupContentState extends State<_SignupContent> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _hasMinLength = false;
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _passwordsMatch = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_checkPasswordsMatch);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      _hasLowerCase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
    _checkPasswordsMatch();
  }

  void _checkPasswordsMatch() {
    setState(() {
      _passwordsMatch = _passwordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  bool get _isPasswordValid =>
      _hasMinLength && _hasUpperCase && _hasLowerCase && _hasNumber && _hasSpecialChar;

  void _handleSignup() {
    if (!_isPasswordValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'كلمة المرور لا تستوفي الشروط المطلوبة',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    if (!_passwordsMatch) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'كلمة المرور غير متطابقة',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    // الانتقال لصفحة التحقق بالكود
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpVerificationScreen(email: _emailController.text, userName: _usernameController.text,),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
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
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                // البريد الإلكتروني
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'البريد الإلكتروني',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(height: 10),
                AuthTextField(
                  hintText: 'أدخل بريدك الإلكتروني',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 20),

                // رقم الهاتف
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'رقم الهاتف',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(height: 10),
                AuthTextField(
                  hintText: '+201000000000',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'اسم المستخدم',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(height: 10),
                AuthTextField(
                  hintText: 'أدخل اسم المستخدم',
                  controller: _usernameController,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 20),

                // تاريخ الميلاد
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'تاريخ الميلاد',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _selectDate,
                  child: AbsorbPointer(
                    child: AuthTextField(
                      hintText: 'يوم/شهر/سنة',
                      controller: _dateController,
                      suffixIcon: const Icon(
                        Icons.calendar_today_outlined,
                        color: Color(0xFF379777),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // كلمة المرور
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'كلمة المرور',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(height: 10),
                AuthTextField(
                  hintText: 'أدخل كلمة المرور',
                  isPassword: !_isPasswordVisible,
                  controller: _passwordController,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),

                // تعليمات كلمة المرور
                if (_passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        _PasswordRequirement(text: '8 أحرف على الأقل', isMet: _hasMinLength),
                        _PasswordRequirement(text: 'حرف كبير (A-Z)', isMet: _hasUpperCase),
                        _PasswordRequirement(text: 'حرف صغير (a-z)', isMet: _hasLowerCase),
                        _PasswordRequirement(text: 'رقم (0-9)', isMet: _hasNumber),
                        _PasswordRequirement(text: 'رمز خاص (!@#\$%)', isMet: _hasSpecialChar),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // تأكيد كلمة المرور
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'تأكيد كلمة المرور',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(height: 10),
                AuthTextField(
                  hintText: 'أعد إدخال كلمة المرور',
                  isPassword: !_isConfirmPasswordVisible,
                  controller: _confirmPasswordController,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),

                // تطابق كلمة المرور
                if (_confirmPasswordController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        _passwordsMatch ? Icons.check_circle : Icons.cancel,
                        size: 16,
                        color: _passwordsMatch ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _passwordsMatch ? 'كلمة المرور متطابقة' : 'كلمة المرور غير متطابقة',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _passwordsMatch ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // زر التالي
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF379777),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'التالي',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
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
}

class _PasswordRequirement extends StatelessWidget {
  final String text;
  final bool isMet;

  const _PasswordRequirement({
    required this.text,
    required this.isMet,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isMet ? Colors.green : Colors.grey.shade400,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isMet ? Colors.green : Colors.grey.shade600,
                  fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
                ),
          ),
        ],
      ),
    );
  }
}

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