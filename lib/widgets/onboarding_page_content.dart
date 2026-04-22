import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingPageContent extends StatelessWidget {
  final String imagePath;
  final String title;
  final String titleHighlight;
  final String description;
  final double imageHeight;
  final double topPadding;

  const OnboardingPageContent({
    super.key,
    required this.imagePath,
    required this.title,
    required this.titleHighlight,
    required this.description,
    this.imageHeight = 400,
    this.topPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            imagePath,
            width: 300,
            height: imageHeight,
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          Text(
            titleHighlight,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: const Color(0xFF379777),
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                    height: 1.6,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}