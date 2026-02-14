import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BuildRowOfTextAndTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Widget? child;
  final Color? seeAllColor;
  const BuildRowOfTextAndTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.seeAllColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: TextStyle(
            color: Color(0xff202244),
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
                    'See All',
                    style: TextStyle(
                      color: seeAllColor ?? Color(0xff2F98D7),
                    ),
                  ),
              const SizedBox(width: 8),
              SvgPicture.asset(
                'assets/icons/arrow_right.svg',
                height: 10,
                width: 6,
                colorFilter: ColorFilter.mode(
                  seeAllColor ?? Color(0xff2F98D7),
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
