import 'dart:async';
import 'dart:convert';
import 'package:daleel/home_page.dart';
import 'package:daleel/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  int _secondsRemaining = 60;
  Timer? _timer;
  bool _canResend = false;
  int _resendCount = 0;
  static const int _maxResendAttempts = 5;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) { c.dispose(); }
    for (var f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  void _startTimer() {
    _canResend = false;
    _secondsRemaining = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _canResend = _resendCount < _maxResendAttempts;
          timer.cancel();
        }
      });
    });
  }

  // ========== إعادة إرسال OTP (باستخدام الإندبوينت الجديد) ==========
  Future<void> _resendCode() async {
    if (!_canResend || _resendCount >= _maxResendAttempts) {
      if (_resendCount >= _maxResendAttempts) {
        _showSnackBar('لقد تجاوزت الحد الأقصى لإعادة الإرسال', isError: true);
      }
      return;
    }

    setState(() => _resendCount++);

    try {
      // ✅ تغيير الإندبوينت إلى /auth/resend-otp
      final url = Uri.parse('https://auth-login-for-daleel1.vercel.app/auth/resend-otp');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': widget.email}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar('تم إعادة إرسال رمز التحقق إلى بريدك الإلكتروني');
        _startTimer();
      } else {
        String errorMsg = 'فشل إعادة الإرسال';
        try {
          final errorData = json.decode(response.body);
          errorMsg = errorData['message'] ?? errorData['error'] ?? errorMsg;
        } catch (_) {}
        _showSnackBar(errorMsg, isError: true);
      }
    } catch (e) {
      _showSnackBar('حدث خطأ في الاتصال: $e', isError: true);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: isError ? Colors.red.shade600 : const Color(0xFF379777),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String get _timerText {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    if (_controllers.every((c) => c.text.isNotEmpty)) {
      _verifyOtp();
    }
  }

  void _onKeyPressed(RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  // ========== التحقق من الكود (باستخدام الإندبوينت الجديد) ==========
  Future<void> _verifyOtp() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length != 4 || _isVerifying) return;

    setState(() => _isVerifying = true);

    try {
      // ✅ تغيير الإندبوينت إلى /auth/verify-otp
      final url = Uri.parse('https://auth-login-for-daleel1.vercel.app/auth/verify-otp');
      final body = {'email': widget.email, 'otp': otp};

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (!mounted) return;

      debugPrint('🔹 Verify OTP Status: ${response.statusCode}');
      debugPrint('🔹 Verify OTP Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ========== استخراج التوكن وبيانات المستخدم وحفظهم (كانت ناقصة) ==========
        Map<String, dynamic> data = {};
        try {
          final decoded = json.decode(response.body);
          if (decoded is Map<String, dynamic>) data = decoded;
        } catch (_) {}

        // استخراج الكوكي لو السيرفر بيرجعه في الهيدر
        String? cookie;
        final setCookie = response.headers['set-cookie'];
        if (setCookie != null) {
          final match = RegExp(r'connect\.sid=([^;]+)').firstMatch(setCookie);
          if (match != null) cookie = match.group(1);
        }

        // استخراج التوكن من الرد (نفس منطق شاشة تسجيل الدخول)
        String? token = data['token']?.toString() ??
            data['data']?['token']?.toString() ??
            data['accessToken']?.toString();
        if (token == null && cookie != null) {
          token = 'cookie_$cookie';
        }

        if (token == null || token.isEmpty) {
          debugPrint('⚠️ Verify OTP succeeded but no token/cookie found in response');
          _showSnackBar('تم التحقق، لكن تعذر بدء الجلسة، يرجى تسجيل الدخول', isError: true);
          setState(() => _isVerifying = false);
          return;
        }

        final userData = (data['user'] is Map<String, dynamic>)
            ? data['user'] as Map<String, dynamic>
            : (data['data'] is Map<String, dynamic>)
                ? data['data'] as Map<String, dynamic>
                : data;

        final user = User(
          displayName: userData['username']?.toString() ??
              userData['name']?.toString() ??
              widget.email.split('@').first,
          email: userData['email']?.toString() ?? widget.email,
          photoUrl: userData['photoUrl']?.toString(),
          token: token,
          phone: userData['phone']?.toString(),
          cookie: cookie,
        );

        // ignore: use_build_context_synchronously
        context.read<UserProvider>().updateUser(user);
        debugPrint('✅ User logged in after OTP, token saved: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');

        _showSnackBar('تم التحقق بنجاح');
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        String errorMsg = 'رمز التحقق غير صحيح';
        try {
          final errorData = json.decode(response.body);
          errorMsg = errorData['message'] ?? errorData['error'] ?? errorMsg;
        } catch (_) {}
        _showSnackBar(errorMsg, isError: true);
        for (var c in _controllers) { c.clear(); }
        _focusNodes[0].requestFocus();
      }
    } catch (e) {
      if (mounted) _showSnackBar('حدث خطأ في الاتصال: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isVerifying = false);
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
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(top: 10, left: -100, child: _BackgroundDecoration()),
              Positioned(bottom: 10, right: -100, child: _BackgroundDecoration()),
              Column(
                children: [
                  const SizedBox(height: 70),
                  SvgPicture.asset('assets/images/logo.svg'),
                  const SizedBox(height: 40),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text('الكود ', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: const Color(0xFF379777), fontWeight: FontWeight.bold)),
                            Text('أدخل', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                          ]),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black87, height: 1.5),
                                children: [
                                  const TextSpan(text: 'لقد أرسلنا رسالة نصية قصيرة تحتوي على كود تفعيل الى بريدك الالكتروني '),
                                  TextSpan(text: widget.email, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF379777))),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 50),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(4, (index) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: _OtpBox(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                onChanged: (value) => _onChanged(value, index),
                                onKeyPressed: (event) => _onKeyPressed(event, index),
                              ),
                            )),
                          ),
                          const SizedBox(height: 40),
                          if (_isVerifying)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 20),
                              child: CircularProgressIndicator(color: Color(0xFF379777)),
                            ),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            if (!_canResend)
                              Text(_timerText, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black87, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: _canResend ? _resendCode : null,
                              child: Text('إعادة إرسال', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: _canResend ? const Color(0xFF379777) : Colors.grey.shade600, fontWeight: FontWeight.w600)),
                            ),
                          ]),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: SizedBox(
                      width: double.infinity, height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          final otp = _controllers.map((c) => c.text).join();
                          if (otp.length == 4) _verifyOtp();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF379777),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: Text('التالي', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
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
}

class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;
  final Function(RawKeyEvent) onKeyPressed;
  const _OtpBox({required this.controller, required this.focusNode, required this.onChanged, required this.onKeyPressed});
  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  bool _isFocused = false;
  @override
  void initState() { super.initState(); widget.focusNode.addListener(_onFocusChange); }
  @override
  void dispose() { widget.focusNode.removeListener(_onFocusChange); super.dispose(); }
  void _onFocusChange() { setState(() { _isFocused = widget.focusNode.hasFocus; }); }
  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: widget.onKeyPressed,
      child: Container(
        width: 60, height: 60,
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _isFocused ? const Color(0xFF379777) : Colors.grey.shade300, width: 2),
        ),
        child: TextField(
          controller: widget.controller, focusNode: widget.focusNode,
          textAlign: TextAlign.center, keyboardType: TextInputType.number, maxLength: 1,
          style: const TextStyle(color: Color(0xFF379777), fontSize: 24, fontWeight: FontWeight.bold),
          cursorColor: const Color(0xFF379777), cursorWidth: 2, cursorHeight: 24,
          showCursor: true, enableInteractiveSelection: false,
          decoration: const InputDecoration(counterText: '', border: InputBorder.none, focusedBorder: InputBorder.none, enabledBorder: InputBorder.none, filled: false),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}

class _BackgroundDecoration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.1,
      child: SvgPicture.asset('assets/images/part_1.svg', width: 200, height: 200,
          colorFilter: const ColorFilter.mode(Color(0xFF379777), BlendMode.srcIn)),
    );
  }
}