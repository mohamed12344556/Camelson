import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BuildActionsIcons extends StatelessWidget {
  final String iconPath;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool? hasBadge;
  const BuildActionsIcons({
    super.key,
    required this.iconPath,
    this.onTap,
    this.iconColor = Colors.black,
    this.hasBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 32,
          height: 32,
          margin: EdgeInsets.symmetric(horizontal: 5),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: SvgPicture.asset(
              iconPath,
              colorFilter: ColorFilter.mode(iconColor!, BlendMode.srcIn),
            ),
          ),
        ),
        if (hasBadge == true)
          Positioned(
            top: 0,
            right: -2,
            child: Badge(
              isLabelVisible: hasBadge ?? false,
              label: Text('12', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.green,
            ),
          ),
      ],
    );
  }
}
