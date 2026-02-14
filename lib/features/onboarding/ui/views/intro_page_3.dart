import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../widgets/image_shadow.dart';
import '../widgets/title_subtitle.dart';

class IntroPage3 extends StatelessWidget {
  const IntroPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 43),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ImageShadow(
                  image1: Image.asset(
                    Assets.robot,
                    width: 271,
                    height: 354,
                  ),
                ),
                const SizedBox(height: 120),
                const TitleSubtitle(
                  title: 'AI Assistant 24/7',
                  subtitle: 'Get instant help and personalized guidance from our intelligent AI assistant, available whenever you need it.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}