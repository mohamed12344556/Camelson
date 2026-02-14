import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/core.dart';

class ImageShadow extends StatelessWidget {
  const ImageShadow({super.key, this.image1, this.image2, this.image3});

  final Widget? image1;
  final Widget? image2;
  final Widget? image3;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Background shadow
          Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          ),

          // Main background
          SvgPicture.asset(Assets.group, width: 350, height: 350),

          // Gradient overlay
          Positioned(
            bottom: -245,
            right: -70,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.fromARGB(0, 255, 255, 255), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 1.0],
                ),
              ),
              width: 451,
              height: 389,
            ),
          ),

          // Images with better positioning
          if (image1 != null)
            Positioned(
              left: 36,
              top: 20,
              child: Hero(tag: 'image1', child: image1!),
            ),
          if (image2 != null)
            Positioned(
              right: 60,
              top: 160,
              child: Hero(tag: 'image2', child: image2!),
            ),
          if (image3 != null)
            Positioned(
              left: 75,
              bottom: -105,
              child: Hero(tag: 'image3', child: image3!),
            ),
        ],
      ),
    );
  }
}
