import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/core.dart';

class BuildRowOfTextAndTextButton extends StatelessWidget {
  final String text;
  final String? textEn;
  final VoidCallback onPressed;
  final Widget? child;
  final Color? seeAllColor;
  const BuildRowOfTextAndTextButton({
    super.key,
    required this.text,
    this.textEn,
    required this.onPressed,
    this.seeAllColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = context.isArabic ? text : (textEn ?? text);
    final seeAllText = context.isArabic ? 'عرض الكل' : 'See All';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          displayText,
          style: TextStyle(
            color: AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: onPressed,
          child: Row(
            children: [
              child ??
                  Text(
                    seeAllText,
                    style: TextStyle(
                      color: seeAllColor ?? AppColors.primary,
                    ),
                  ),
              const SizedBox(width: 8),
              SvgPicture.asset(
                'assets/icons/arrow_right.svg',
                height: 10,
                width: 6,
                colorFilter: ColorFilter.mode(
                  seeAllColor ?? AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
