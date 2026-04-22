import 'dart:async';
import 'package:daleel/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  
  const OtpVerificationScreen({
    super.key,
    required this.email, required String userName,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );

  int _secondsRemaining = 60;
  Timer? _timer;
  bool _canResend = false;
  int _resendCount = 0; // عدد مرات إعادة الإرسال
  static const int _maxResendAttempts = 5; // الحد الأقصى 5 مرات

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
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
          _canResend = _resendCount < _maxResendAttempts; // تحقق من عدد المرات
          timer.cancel();
        }
      });
    });
  }

  void _resendCode() {
    if (_canResend && _resendCount < _maxResendAttempts) {
      _resendCount++;
      
      // TODO: هنا حط كود إعادة إرسال الكود
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم إعادة إرسال الكود ($_resendCount/$_maxResendAttempts)',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: const Color(0xFF379777),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      _startTimer();
    } else if (_resendCount >= _maxResendAttempts) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'لقد تجاوزت الحد الأقصى لإعادة الإرسال',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
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

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    
    // تحقق إذا تم ملء كل الحقول
    if (_controllers.every((controller) => controller.text.isNotEmpty)) {
      _verifyOtp();
    }
  }

  void _onKeyPressed(RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_controllers[index].text.isEmpty && index > 0) {
          _focusNodes[index - 1].requestFocus();
        }
      }
    }
  }

  void _verifyOtp() {
    final otp = _controllers.map((c) => c.text).join();
    
    if (otp.length == 4) {
      // TODO: هنا حط كود التحقق من الـ OTP
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  String get _timerText {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
              // الديكور الخلفي
              Positioned(
                top: 10,
                left: -100,
                child: _BackgroundDecoration(),
              ),
              Positioned(
                bottom: 10,
                right: -100,
                child: _BackgroundDecoration(),
              ),

              // المحتوى
              Column(
                children: [
                  const SizedBox(height: 70),

                  // اللوجو - نفس الحجم في الصفحات التانية
                  SvgPicture.asset(
                    'assets/images/logo.svg',
                  ),

                  const SizedBox(height: 40),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          // النص
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                Text(
                                'الكود ',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: const Color(0xFF379777),
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'أدخل',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),

                            ],
                          ),

                          const SizedBox(height: 16),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.black87,
                                      height: 1.5,
                                    ),
                                children: [
                                  const TextSpan(
                                    text: 'لقد أرسلنا رسالة نصية قصيرة تحتوي على كود تفعيل الى بريدك الالكتروني ',
                                  ),
                                  TextSpan(
                                    text: widget.email,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF379777),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 50),

                          // حقول الـ OTP
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              4,
                              (index) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: _OtpBox(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  onChanged: (value) => _onChanged(value, index),
                                  onKeyPressed: (event) => _onKeyPressed(event, index),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // إعادة الإرسال
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!_canResend)
                                Text(
                                  _timerText,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: _canResend ? _resendCode : null,
                                child: Text(
                                  'إعادة إرسال',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: _canResend
                                            ? const Color(0xFF379777)
                                            : Colors.grey.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // زر التالي
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _verifyOtp,
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

// Widget لصندوق الـ OTP
class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;
  final Function(RawKeyEvent) onKeyPressed;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKeyPressed,
  });

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: widget.onKeyPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isFocused 
                ? const Color(0xFF379777) 
                : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: const TextStyle(
            color: Color(0xFF379777),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          cursorColor: const Color(0xFF379777),
          cursorWidth: 2,
          cursorHeight: 24,
          showCursor: true,
          enableInteractiveSelection: false,
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            filled: false,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}

// Widget للديكور الخلفي
class _BackgroundDecoration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.1,
      child: SvgPicture.asset(
        'assets/images/part_1.svg',
        width: 200,
        height: 200,
        colorFilter: ColorFilter.mode(
          const Color(0xFF379777),
          BlendMode.srcIn,
        ),
      ),
    );
  }
}