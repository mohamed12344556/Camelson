import 'package:flutter/material.dart';

import '../widgets/image_shadow.dart';
import '../widgets/title_subtitle.dart';

class IntroPage1 extends StatelessWidget {
  const IntroPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 43),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ImageShadow(),
                SizedBox(height: 120),
                TitleSubtitle(
                  title: 'Best Learn',
                  subtitle:
                      'Discover the most effective way to learn with our innovative platform designed for modern learners.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
