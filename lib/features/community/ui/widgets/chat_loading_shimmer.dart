import 'package:flutter/material.dart';

class ChatLoadingShimmer extends StatefulWidget {
  final int itemCount;

  const ChatLoadingShimmer({
    super.key,
    this.itemCount = 8,
  });

  @override
  State<ChatLoadingShimmer> createState() => _ChatLoadingShimmerState();
}

class _ChatLoadingShimmerState extends State<ChatLoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween<double>(
      begin: -2,
      end: 2,
    ).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        // Alternate between left and right aligned messages
        final isRight = index % 3 == 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildShimmerMessage(isRight),
        );
      },
    );
  }

  Widget _buildShimmerMessage(bool isRight) {
    return Align(
      alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isRight ? 64 : 8,
          right: isRight ? 8 : 64,
        ),
        child: Column(
          crossAxisAlignment:
              isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Avatar for left-aligned messages
            if (!isRight)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerCircle(32),
                  const SizedBox(width: 8),
                  Expanded(child: _buildMessageBubble()),
                ],
              )
            else
              _buildMessageBubble(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.5, 1.0],
              colors: [
                Colors.grey.shade200,
                Colors.grey.shade100,
                Colors.grey.shade200,
              ],
              transform: GradientRotation(_shimmerAnimation.value),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Message content lines
              _buildShimmerLine(double.infinity, 12),
              const SizedBox(height: 8),
              _buildShimmerLine(200, 12),
              const SizedBox(height: 8),
              _buildShimmerLine(150, 12),
              const SizedBox(height: 12),

              // Timestamp
              _buildShimmerLine(60, 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerCircle(double size) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade200,
                Colors.grey.shade100,
                Colors.grey.shade200,
              ],
              transform: GradientRotation(_shimmerAnimation.value),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerLine(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Compact shimmer for loading more messages (pagination)
class ChatPaginationShimmer extends StatefulWidget {
  const ChatPaginationShimmer({super.key});

  @override
  State<ChatPaginationShimmer> createState() => _ChatPaginationShimmerState();
}

class _ChatPaginationShimmerState extends State<ChatPaginationShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Row(
                children: List.generate(3, (index) {
                  final delay = index * 0.3;
                  final value = (_controller.value - delay) % 1.0;
                  final opacity = (value < 0.5 ? value * 2 : (1 - value) * 2);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade400.withValues(alpha: opacity),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(width: 12),
          Text(
            'جاري تحميل الرسائل...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
