import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/core.dart';

class ElevatedButtonForVideoPlayer extends StatelessWidget {
  const ElevatedButtonForVideoPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.pushNamed(AppRoutes.courseContentsView);
      },
      style: ButtonStyle(
        fixedSize: WidgetStateProperty.all(const Size(55, 55)),
        shape: WidgetStateProperty.all(CircleBorder()),
        padding: WidgetStateProperty.all(EdgeInsets.zero),
      ),
      child: SvgPicture.asset(
        "assets/svgs/playButton.svg",
        width: 25,
        height: 25,
      ),
    );
  }
}
