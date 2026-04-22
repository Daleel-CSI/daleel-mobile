
import 'package:daleel/screen/auth/auth_screen.dart';
import 'package:daleel/widgets/onboarding_page_content.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash2 extends StatelessWidget {
  const Splash2({super.key});
  // دالة لحفظ إن المستخدم شاف الـ Onboarding
  Future<void> _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);

    if (!context.mounted) return;

    // انتقل للصفحة الرئيسية
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }

  // دالة لإنشاء الصفحات
  List<PageViewModel> _getPages(BuildContext context) {
    return [
      // الصفحة الأولى
      PageViewModel(
        title: "",
        bodyWidget: const OnboardingPageContent(
          imagePath: 'assets/images/splash_2.svg',
          title: "ابحث عن أي إجراء حكومي",
          titleHighlight: "بسهولة",
          description:
              "ابحث عن الأوراق المطلوبة في ثواني\nكل الإجراءات والأوراق في مكان واحد",
        ),
      ),

      // الصفحة الثانية
      PageViewModel(
        title: "",
        bodyWidget: const OnboardingPageContent(
          imagePath: 'assets/images/splash_3.svg',
          title: "تأكد من صحة الأوراق",
          titleHighlight: "قبل ما تروح",
          description:
              "راجع كل المستندات المطلوبة وتأكد إنها كاملة وصحيحة\nعشان توفر وقتك وجهدك",
        ),
      ),

      // الصفحة الثالثة
      PageViewModel(
        title: "",
        bodyWidget: const OnboardingPageContent(
          imagePath: 'assets/images/splash_4.svg',
          title: "تحديثات رسمية",
          titleHighlight: "وموثوقة",
          description:
              "احصل على تحديثات مستمرة لأي تغييرات في الإجراءات أو الأوراق المطلوبة من المصادر الرسمية",
          imageHeight: 365,
          topPadding: 25,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: _getPages(context),

      // عند الضغط على "ابدأ" أو "تخطي"
      onDone: () => _completeOnboarding(context),
      onSkip: () => _completeOnboarding(context),

      // إعدادات الأزرار
      showSkipButton: true,
      showNextButton: true,
      showDoneButton: true,
      showBackButton: false,

      // نصوص الأزرار
      skip: Text(
        'تخطي',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.black,
            ),
      ),
      next: const Icon(
        Icons.arrow_forward,
        color: Color(0xFF379777),
        size: 28,
      ),
      done: Text(
        'ابدأ',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF379777),
              fontWeight: FontWeight.bold,
            ),
      ),

dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(24.0, 10.0),
        activeColor: const Color(0xFF379777),
        color: Colors.grey.shade300,
        spacing: const EdgeInsets.symmetric(horizontal: 4.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),

      // إعدادات إضافية
      globalBackgroundColor: Colors.white,
      skipOrBackFlex: 0,
      nextFlex: 0,
      curve: Curves.easeInOut,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsContainerDecorator: const BoxDecoration(),
    );
  }
}