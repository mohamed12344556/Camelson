import 'package:flutter/material.dart';

import '../../data/models/user.dart';

class TypingIndicator extends StatefulWidget {
  final List<User> users;

  const TypingIndicator({super.key, required this.users});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.users.isEmpty) return const SizedBox();

    final typingText =
        widget.users.length == 1
            ? '${widget.users.first.name} يكتب'
            : '${widget.users.length} أشخاص يكتبون';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Row(
                children: List.generate(3, (index) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                    transform: Matrix4.translationValues(
                      0,
                      -5 * _wave(index, _animation.value),
                      0,
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(width: 8),
          Text(
            typingText,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  double _wave(int index, double value) {
    final delay = index * 0.1;
    final wave = (value - delay).clamp(0.0, 1.0);
    return wave < 0.5 ? wave * 2 : 2 - wave * 2;
  }
}
