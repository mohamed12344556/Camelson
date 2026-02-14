import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/core.dart';
import '../widgets/image_shadow.dart';
import '../widgets/title_subtitle.dart';

class IntroPage2 extends StatelessWidget {
  const IntroPage2({super.key});

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
                  image1: SvgPicture.asset(Assets.iPhoneMochupWhite),
                  image2: Image.asset(Assets.learning, width: 206, height: 226),
                  image3: SvgPicture.asset(Assets.buttonFrame),
                ),
                const SizedBox(height: 170),
                const TitleSubtitle(
                  title: 'Share with Community',
                  subtitle:
                      'Connect with fellow learners, share your progress, and grow together in our supportive community.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
