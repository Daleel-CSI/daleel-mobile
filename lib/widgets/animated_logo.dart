import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AnimatedLogo extends StatefulWidget {
  final VoidCallback? onAnimationComplete;
  
  const AnimatedLogo({
    super.key,
    this.onAnimationComplete,
  });

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with TickerProviderStateMixin {
  late AnimationController _part1Controller;
  late AnimationController _part2Controller;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _part2ScaleAnimation;
  late Animation<double> _part2RotationAnimation;
  late Animation<double> _part2OpacityAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _part1Controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _part2Controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-3.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _part1Controller,
      curve: Curves.easeOutCubic,
    ));

    _rotationAnimation = Tween<double>(
      begin: -6.28,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _part1Controller,
      curve: Curves.easeOutCubic,
    ));

    _part2ScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40.0,
      ),
    ]).animate(_part2Controller);

    _part2RotationAnimation = Tween<double>(
      begin: 0.5,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _part2Controller,
      curve: Curves.elasticOut,
    ));

    _part2OpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _part2Controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    ));
  }

  void _startAnimations() async {
    await _part1Controller.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    await _part2Controller.forward();
    
    // بعد ما الأنيميشن يخلص، نادي على الـ callback
    widget.onAnimationComplete?.call();
  }

  @override
  void dispose() {
    _part1Controller.dispose();
    _part2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _part1Controller,
          builder: (context, child) {
            return SlideTransition(
              position: _slideAnimation,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: SvgPicture.asset('assets/images/part_1.svg'),
              ),
            );
          },
        ),
        const SizedBox(width: 16),
        AnimatedBuilder(
          animation: _part2Controller,
          builder: (context, child) {
            return Opacity(
              opacity: _part2OpacityAnimation.value,
              child: Transform.scale(
                scale: _part2ScaleAnimation.value,
                child: Transform.rotate(
                  angle: _part2RotationAnimation.value,
                  child: SvgPicture.asset('assets/images/part_2.svg'),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}