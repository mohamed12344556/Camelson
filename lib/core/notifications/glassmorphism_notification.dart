import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum NotificationType {
  newLesson,
  exam,
  lessonReminder,
  chatMessage,
  communityPost,
  competition,
  achievement,
  announcement,
  liveStream,
  homework,
  grade,
}

class GlassmorphismNotification extends StatefulWidget {
  final String title;
  final String message;
  final NotificationType type;
  final String? imageUrl;
  final String? senderName;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final Duration duration;

  const GlassmorphismNotification({
    Key? key,
    required this.title,
    required this.message,
    required this.type,
    this.imageUrl,
    this.senderName,
    this.onTap,
    this.onDismiss,
    this.duration = const Duration(seconds: 5),
  }) : super(key: key);

  @override
  State<GlassmorphismNotification> createState() =>
      _GlassmorphismNotificationState();
}

class _GlassmorphismNotificationState extends State<GlassmorphismNotification>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _progressController;
  late AnimationController _iconController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  double _dragDistance = 0;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeIn,
    ));

    _progressController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _iconController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _startAnimations();
  }

  void _startAnimations() async {
    HapticFeedback.mediumImpact();
    await _slideController.forward();
    _iconController.repeat(reverse: true);
    _progressController.forward().then((_) {
      _dismiss();
    });
  }

  void _dismiss() async {
    _iconController.stop();
    await _slideController.reverse();
    if (mounted) {
      widget.onDismiss?.call();
    }
  }

  NotificationConfig _getConfig() {
    switch (widget.type) {
      case NotificationType.newLesson:
        return NotificationConfig(
          color: const Color(0xFF8B5CF6),
          icon: Icons.play_circle_outline_rounded,
          gradient: const [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
          emoji: '📚',
        );
      case NotificationType.exam:
        return NotificationConfig(
          color: const Color(0xFFEF4444),
          icon: Icons.assignment_outlined,
          gradient: const [Color(0xFFEF4444), Color(0xFFF87171)],
          emoji: '📝',
        );
      case NotificationType.lessonReminder:
        return NotificationConfig(
          color: const Color(0xFFF59E0B),
          icon: Icons.schedule_rounded,
          gradient: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
          emoji: '⏰',
        );
      case NotificationType.chatMessage:
        return NotificationConfig(
          color: const Color(0xFF3B82F6),
          icon: Icons.chat_bubble_outline_rounded,
          gradient: const [Color(0xFF3B82F6), Color(0xFF60A5FA)],
          emoji: '💬',
        );
      case NotificationType.communityPost:
        return NotificationConfig(
          color: const Color(0xFF06B6D4),
          icon: Icons.groups_rounded,
          gradient: const [Color(0xFF06B6D4), Color(0xFF22D3EE)],
          emoji: '👥',
        );
      case NotificationType.competition:
        return NotificationConfig(
          color: const Color(0xFFEC4899),
          icon: Icons.emoji_events_outlined,
          gradient: const [Color(0xFFEC4899), Color(0xFFF472B6)],
          emoji: '🏆',
        );
      case NotificationType.achievement:
        return NotificationConfig(
          color: const Color(0xFF10B981),
          icon: Icons.celebration_outlined,
          gradient: const [Color(0xFF10B981), Color(0xFF34D399)],
          emoji: '🎉',
        );
      case NotificationType.liveStream:
        return NotificationConfig(
          color: const Color(0xFFDC2626),
          icon: Icons.videocam_outlined,
          gradient: const [Color(0xFFDC2626), Color(0xFFEF4444)],
          emoji: '🔴',
        );
      case NotificationType.homework:
        return NotificationConfig(
          color: const Color(0xFF6366F1),
          icon: Icons.edit_note_rounded,
          gradient: const [Color(0xFF6366F1), Color(0xFF818CF8)],
          emoji: '✏️',
        );
      case NotificationType.grade:
        return NotificationConfig(
          color: const Color(0xFF14B8A6),
          icon: Icons.grade_rounded,
          gradient: const [Color(0xFF14B8A6), Color(0xFF2DD4BF)],
          emoji: '⭐',
        );
      case NotificationType.announcement:
      default:
        return NotificationConfig(
          color: const Color(0xFF64748B),
          icon: Icons.campaign_outlined,
          gradient: const [Color(0xFF64748B), Color(0xFF94A3B8)],
          emoji: '📢',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 50, 12, 0),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onTap?.call();
              _dismiss();
            },
            onVerticalDragUpdate: (details) {
              setState(() {
                _dragDistance += details.delta.dy;
                if (_dragDistance < 0) {
                  final progress = (_dragDistance.abs() / 100).clamp(0.0, 1.0);
                  _slideController.value = 1.0 - progress;
                }
              });
            },
            onVerticalDragEnd: (details) {
              if (_dragDistance < -50) {
                _dismiss();
              } else {
                _slideController.forward();
              }
              _dragDistance = 0;
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        config.gradient[0].withOpacity(0.15),
                        config.gradient[1].withOpacity(0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: config.color.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: config.color.withOpacity(0.25),
                        blurRadius: 24,
                        spreadRadius: 0,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Emoji Icon
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: config.gradient,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: config.color.withOpacity(0.4),
                                    blurRadius: 8,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Text(
                                config.emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Sender name if exists
                                  if (widget.senderName != null) ...[
                                    Text(
                                      widget.senderName!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: config.color.withOpacity(0.8),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                  ],
                                  // Title
                                  Text(
                                    widget.title,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.3,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  // Message
                                  Text(
                                    widget.message,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.85),
                                      height: 1.4,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Dismiss button
                            GestureDetector(
                              onTap: _dismiss,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Progress bar
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return Container(
                            height: 3,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: LinearProgressIndicator(
                              value: 1 - _progressController.value,
                              backgroundColor: Colors.white.withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                config.color.withOpacity(0.8),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _progressController.dispose();
    _iconController.dispose();
    super.dispose();
  }
}

class NotificationConfig {
  final Color color;
  final IconData icon;
  final List<Color> gradient;
  final String emoji;

  NotificationConfig({
    required this.color,
    required this.icon,
    required this.gradient,
    required this.emoji,
  });
}
