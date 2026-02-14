import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnimatedLockIcon extends StatefulWidget {
  final String svgPath;
  final double size;
  final Color backgroundColor;

  const AnimatedLockIcon({
    super.key,
    required this.svgPath,
    this.size = 120,
    this.backgroundColor = Colors.blue,
  });

  @override
  State<AnimatedLockIcon> createState() => _AnimatedLockIconState();
}

class _AnimatedLockIconState extends State<AnimatedLockIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _iconAnimationController;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    _iconAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _iconAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _iconAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _iconAnimationController.forward();
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _iconAnimation,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.backgroundColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(widget.svgPath),
          ],
        ),
      ),
    );
  }
}
