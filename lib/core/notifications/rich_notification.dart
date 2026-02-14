import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart'; // ← أضف الـ import

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

class RichNotification extends StatefulWidget {
  final String title;
  final String message;
  final NotificationType type;
  final String? avatarUrl;
  final String? senderName;
  final String? timeAgo;
  final String? badge;
  final VoidCallback? onTap;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;
  final Duration duration;

  const RichNotification({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    this.avatarUrl,
    this.senderName,
    this.timeAgo,
    this.badge,
    this.onTap,
    this.onAction,
    this.onDismiss,
    this.duration = const Duration(seconds: 6),
  });

  @override
  State<RichNotification> createState() => _RichNotificationState();
}

class _RichNotificationState extends State<RichNotification>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _progressController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  double _dragDistance = 0;
  bool _isDismissing = false;

  // ✅ إضافة Audio Player
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _progressController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    // ✅ تشغيل الصوت المخصص
    try {
      // غير اسم الملف حسب الملف اللي عندك
      await _audioPlayer.play(AssetSource('audios/notification.mp3'));
    } catch (e) {
      // لو فشل تشغيل الملف، استخدم صوت النظام
      try {
        SystemSound.play(SystemSoundType.alert);
      } catch (_) {}
    }

    HapticFeedback.mediumImpact();

    await _slideController.forward();
    _progressController.forward().then((_) {
      if (!_isDismissing) {
        _dismiss();
      }
    });
  }

  void _dismiss() async {
    if (_isDismissing) return;
    _isDismissing = true;

    // ✅ إيقاف الصوت عند الإغلاق
    try {
      await _audioPlayer.stop();
    } catch (e) {
      // Ignore
    }

    await _slideController.reverse();
    if (mounted) {
      widget.onDismiss?.call();
    }
  }

  NotificationConfig _getConfig() {
    switch (widget.type) {
      case NotificationType.newLesson:
        return NotificationConfig(
          primaryColor: const Color(0xFF8B5CF6),
          secondaryColor: const Color(0xFFA78BFA),
          icon: Icons.play_circle_filled_rounded,
          emoji: '📚',
          actionLabel: 'مشاهدة',
        );
      case NotificationType.exam:
        return NotificationConfig(
          primaryColor: const Color(0xFFEF4444),
          secondaryColor: const Color(0xFFF87171),
          icon: Icons.assignment_rounded,
          emoji: '📝',
          actionLabel: 'التفاصيل',
        );
      case NotificationType.lessonReminder:
        return NotificationConfig(
          primaryColor: const Color(0xFFF59E0B),
          secondaryColor: const Color(0xFFFBBF24),
          icon: Icons.alarm_rounded,
          emoji: '⏰',
          actionLabel: 'جاهز',
        );
      case NotificationType.chatMessage:
        return NotificationConfig(
          primaryColor: const Color(0xFF3B82F6),
          secondaryColor: const Color(0xFF60A5FA),
          icon: Icons.chat_bubble_rounded,
          emoji: '💬',
          actionLabel: 'رد',
        );
      case NotificationType.communityPost:
        return NotificationConfig(
          primaryColor: const Color(0xFF06B6D4),
          secondaryColor: const Color(0xFF22D3EE),
          icon: Icons.groups_rounded,
          emoji: '👥',
          actionLabel: 'عرض',
        );
      case NotificationType.competition:
        return NotificationConfig(
          primaryColor: const Color(0xFFEC4899),
          secondaryColor: const Color(0xFFF472B6),
          icon: Icons.emoji_events_rounded,
          emoji: '🏆',
          actionLabel: 'اشترك',
        );
      case NotificationType.achievement:
        return NotificationConfig(
          primaryColor: const Color(0xFF10B981),
          secondaryColor: const Color(0xFF34D399),
          icon: Icons.workspace_premium_rounded,
          emoji: '🎉',
          actionLabel: 'شارك',
        );
      case NotificationType.liveStream:
        return NotificationConfig(
          primaryColor: const Color(0xFFDC2626),
          secondaryColor: const Color(0xFFEF4444),
          icon: Icons.videocam_rounded,
          emoji: '🔴',
          actionLabel: 'انضم',
        );
      case NotificationType.homework:
        return NotificationConfig(
          primaryColor: const Color(0xFF6366F1),
          secondaryColor: const Color(0xFF818CF8),
          icon: Icons.create_rounded,
          emoji: '✏️',
          actionLabel: 'ابدأ',
        );
      case NotificationType.grade:
        return NotificationConfig(
          primaryColor: const Color(0xFF14B8A6),
          secondaryColor: const Color(0xFF2DD4BF),
          icon: Icons.star_rounded,
          emoji: '⭐',
          actionLabel: 'عرض',
        );
      case NotificationType.announcement:
      default:
        return NotificationConfig(
          primaryColor: const Color(0xFF64748B),
          secondaryColor: const Color(0xFF94A3B8),
          icon: Icons.campaign_rounded,
          emoji: '📢',
          actionLabel: 'عرض',
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
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 45, 10, 0),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _scaleController.forward().then((_) {
                  _scaleController.reverse();
                });
                widget.onTap?.call();
                Future.delayed(const Duration(milliseconds: 200), _dismiss);
              },
              onVerticalDragUpdate: (details) {
                setState(() {
                  _dragDistance += details.delta.dy;
                  if (_dragDistance < 0) {
                    final progress = (_dragDistance.abs() / 120).clamp(
                      0.0,
                      1.0,
                    );
                    _slideController.value = 1.0 - progress;
                  }
                });
              },
              onVerticalDragEnd: (details) {
                if (_dragDistance < -60) {
                  _dismiss();
                } else {
                  _slideController.forward();
                }
                _dragDistance = 0;
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: config.primaryColor.withOpacity(0.3),
                      blurRadius: 24,
                      spreadRadius: 0,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 16,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Colored top bar
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              config.primaryColor,
                              config.secondaryColor,
                            ],
                          ),
                        ),
                      ),
                      // Main content
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar/Icon
                                _buildAvatar(config),
                                const SizedBox(width: 12),
                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Header row
                                      Row(
                                        children: [
                                          if (widget.senderName != null) ...[
                                            Flexible(
                                              child: Text(
                                                widget.senderName!,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: config.primaryColor,
                                                  letterSpacing: 0.2,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                          ],
                                          if (widget.badge != null)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    config.primaryColor
                                                        .withOpacity(0.2),
                                                    config.secondaryColor
                                                        .withOpacity(0.1),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: config.primaryColor
                                                      .withOpacity(0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                widget.badge!,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: config.primaryColor,
                                                ),
                                              ),
                                            ),
                                          const Spacer(),
                                          if (widget.timeAgo != null)
                                            Text(
                                              widget.timeAgo!,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.white.withOpacity(
                                                  0.5,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
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
                                          color: Colors.white.withOpacity(0.75),
                                          height: 1.4,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 12),
                                      // Action buttons
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildActionButton(
                                              label: config.actionLabel,
                                              isPrimary: true,
                                              config: config,
                                              onPressed: () {
                                                HapticFeedback.lightImpact();
                                                widget.onAction?.call();
                                                _dismiss();
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: _buildActionButton(
                                              label: 'تجاهل',
                                              isPrimary: false,
                                              config: config,
                                              onPressed: () {
                                                HapticFeedback.lightImpact();
                                                _dismiss();
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Progress bar
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return SizedBox(
                            height: 3,
                            child: LinearProgressIndicator(
                              value: 1 - _progressController.value,
                              backgroundColor: Colors.white.withOpacity(0.05),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                config.primaryColor.withOpacity(0.6),
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

  Widget _buildAvatar(NotificationConfig config) {
    if (widget.avatarUrl != null) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: config.primaryColor.withOpacity(0.3),
            width: 2,
          ),
          image: DecorationImage(
            image: NetworkImage(widget.avatarUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [config.primaryColor, config.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: config.primaryColor.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Text(config.emoji, style: const TextStyle(fontSize: 24)),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required bool isPrimary,
    required NotificationConfig config,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? LinearGradient(
                    colors: [config.primaryColor, config.secondaryColor],
                  )
                : null,
            color: isPrimary ? null : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: !isPrimary
                ? Border.all(color: Colors.white.withOpacity(0.1), width: 1)
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : Colors.white.withOpacity(0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // ✅ تنظيف Audio Player
    _audioPlayer.dispose();
    _slideController.dispose();
    _progressController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
}

class NotificationConfig {
  final Color primaryColor;
  final Color secondaryColor;
  final IconData icon;
  final String emoji;
  final String actionLabel;

  NotificationConfig({
    required this.primaryColor,
    required this.secondaryColor,
    required this.icon,
    required this.emoji,
    required this.actionLabel,
  });
}
