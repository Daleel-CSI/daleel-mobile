import 'package:daleel/screen/slpashes/on_boarding.dart';
import 'package:daleel/widgets/animated_logo.dart';
import 'package:flutter/material.dart';

class Splash1 extends StatefulWidget {
  const Splash1({super.key});

  @override
  State<Splash1> createState() => _Splash1State();
}

class _Splash1State extends State<Splash1> {
  bool _showOnboarding = false;

  void _startTransition() {
    setState(() {
      _showOnboarding = true;
    });

    // بعد ما الـ transition يخلص، استبدل الصفحة
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const Splash2(),
            transitionDuration: Duration.zero, // بدون أنيميشن إضافي
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الصفحة الأولى (Splash مع اللوجو)
          AnimatedOpacity(
            opacity: _showOnboarding ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 1300),
            child: Center(
              child: AnimatedLogo(
                onAnimationComplete: _startTransition,
              ),
            ),
          ),

          // الصفحة الثانية (Onboarding)
          AnimatedOpacity(
            opacity: _showOnboarding ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 1600),
            child: _showOnboarding ? const Splash2() : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}