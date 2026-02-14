import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedMessageBubble extends StatelessWidget {
  final Widget child;
  final bool isCurrentUser;
  final int index;
  final bool enableAnimation;

  const AnimatedMessageBubble({
    super.key,
    required this.child,
    required this.isCurrentUser,
    this.index = 0,
    this.enableAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enableAnimation) {
      return child;
    }

    // Calculate delay based on index (stagger animation)
    final delay = Duration(milliseconds: 50 * (index % 5));

    return child
        .animate(delay: delay)
        .fadeIn(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        )
        .slideY(
          begin: 0.2,
          end: 0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        )
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.0, 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
  }
}

/// Animated container for message actions (reply, forward, delete)
class AnimatedMessageActions extends StatelessWidget {
  final Widget child;
  final bool show;

  const AnimatedMessageActions({
    super.key,
    required this.child,
    required this.show,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      height: show ? null : 0,
      child: child
          .animate(target: show ? 1 : 0)
          .fadeIn(duration: const Duration(milliseconds: 200))
          .slideY(
            begin: -0.5,
            end: 0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          ),
    );
  }
}

/// Animated reaction bubble
class AnimatedReactionBubble extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const AnimatedReactionBubble({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  State<AnimatedReactionBubble> createState() => _AnimatedReactionBubbleState();
}

class _AnimatedReactionBubbleState extends State<AnimatedReactionBubble> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}

/// Typing indicator with animated dots
class AnimatedTypingIndicator extends StatelessWidget {
  const AnimatedTypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(delay: 0),
        const SizedBox(width: 4),
        _buildDot(delay: 200),
        const SizedBox(width: 4),
        _buildDot(delay: 400),
      ],
    );
  }

  Widget _buildDot({required int delay}) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
      ),
    )
        .animate(
          onPlay: (controller) => controller.repeat(),
        )
        .fadeOut(
          duration: const Duration(milliseconds: 600),
          delay: Duration(milliseconds: delay),
        )
        .then()
        .fadeIn(
          duration: const Duration(milliseconds: 600),
        );
  }
}

/// Shimmer loading effect for messages
class MessageLoadingShimmer extends StatelessWidget {
  final bool isCurrentUser;

  const MessageLoadingShimmer({
    super.key,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerLine(width: 200),
            const SizedBox(height: 8),
            _buildShimmerLine(width: 150),
            const SizedBox(height: 8),
            _buildShimmerLine(width: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLine({required double width}) {
    return Container(
      width: width,
      height: 12,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(6),
      ),
    )
        .animate(
          onPlay: (controller) => controller.repeat(),
        )
        .shimmer(
          duration: const Duration(milliseconds: 1500),
          color: Colors.white,
        );
  }
}

/// Animated connection status banner
class AnimatedConnectionBanner extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color color;
  final bool show;

  const AnimatedConnectionBanner({
    super.key,
    required this.message,
    required this.icon,
    required this.color,
    required this.show,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: show ? 40 : 0,
      child: Container(
        color: color,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )
          .animate(target: show ? 1 : 0)
          .fadeIn(duration: const Duration(milliseconds: 200))
          .slideY(
            begin: -1,
            end: 0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          ),
    );
  }
}

/// Animated scroll-to-bottom FAB
class AnimatedScrollToBottomFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final bool show;
  final int unreadCount;

  const AnimatedScrollToBottomFAB({
    super.key,
    required this.onPressed,
    required this.show,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: show ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: FloatingActionButton.small(
        onPressed: onPressed,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.arrow_downward_rounded),
            if (unreadCount > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
