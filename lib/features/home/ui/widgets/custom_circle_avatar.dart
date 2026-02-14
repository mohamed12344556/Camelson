import 'package:simplify/features/profile/ui/views/profile_settings_view.dart';
import 'package:flutter/material.dart';

class CustomCircleAvatar extends StatelessWidget {
  final Widget? child;
  final String? imagePath;
  final bool isHasImage;
  final Color? backgroundColor;
  final double? radius;
  final VoidCallback? onTap;

  const CustomCircleAvatar({
    super.key,
    this.child,
    this.imagePath,
    this.isHasImage = true,
    this.backgroundColor,
    this.radius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: (radius ?? 25) * 2,
        width: (radius ?? 25) * 2,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          image: isHasImage && child == null
              ? DecorationImage(
                  image: AssetImage(imagePath ?? 'assets/images/profile.png'),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: child != null ? Center(child: child) : null,
      ),
    );
  }
}
