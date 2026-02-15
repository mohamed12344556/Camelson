import 'package:boraq/features/community/ui/logic/chat_bloc/chat_bloc.dart';
import 'package:boraq/features/community/ui/logic/chat_bloc/chat_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/api_constants.dart';
import '../../../../core/widgets/cached_network_image_widget.dart';
import '../../data/models/community_constants.dart';
import '../../data/models/message.dart';
import '../../data/models/message_reaction.dart';
import '../logic/chat_bloc/chat_state.dart';
import 'voice_message_bubble_widget.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final bool isCurrentUser;
  final bool showAvatar;
  final MessageStatus? messageStatus;
  final Function(ReactionType) onReaction;
  final VoidCallback? onReply;
  final VoidCallback? onForward;
  final VoidCallback? onDelete;
  final VoidCallback? onRetry;
  final VoidCallback? onCopy;
  final Function(String)? onEdit; // ✅ Added
  final Message? replyToMessage;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.showAvatar,
    this.messageStatus,
    required this.onReaction,
    this.onReply,
    this.onForward,
    this.onDelete,
    this.onRetry,
    this.onCopy,
    this.onEdit, // ✅ Added
    this.replyToMessage,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(
          begin: Offset(widget.isCurrentUser ? 0.3 : -0.3, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Align(
          alignment: widget.isCurrentUser
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.only(
              left: widget.isCurrentUser ? 64 : 8,
              right: widget.isCurrentUser ? 8 : 64,
              top: 4,
              bottom: 4,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!widget.isCurrentUser && widget.showAvatar)
                  _buildAvatar(isDark),
                if (!widget.isCurrentUser && !widget.showAvatar)
                  const SizedBox(width: 40),
                Flexible(
                  child: GestureDetector(
                    onLongPress: () => _showMessageOptions(context),
                    onDoubleTap: () => widget.onReaction(ReactionType.like),
                    child: Column(
                      crossAxisAlignment: widget.isCurrentUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (widget.replyToMessage != null)
                          _buildReplyPreview(isDark),
                        _buildMessageContent(context, isDark),
                        const SizedBox(height: 4),
                        if (widget.message.reactions.isNotEmpty)
                          _buildReactionRow(context, widget.message),
                        _buildMessageInfo(isDark),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isDark) {
    return Hero(
      tag: 'avatar_${widget.message.user.id}_${widget.message.id}',
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.message.user.name[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReplyPreview(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.isCurrentUser
            ? Colors.white.withOpacity(0.1)
            : isDark
            ? Colors.grey.shade800
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: widget.isCurrentUser
                ? Colors.white
                : Theme.of(context).primaryColor,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.replyToMessage?.user.name ?? 'Unknown',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: widget.isCurrentUser
                  ? Colors.white70
                  : isDark
                  ? Colors.grey.shade300
                  : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.replyToMessage?.content ?? '',
            style: TextStyle(
              fontSize: 12,
              color: widget.isCurrentUser
                  ? Colors.white60
                  : isDark
                  ? Colors.grey.shade400
                  : Colors.grey.shade600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, bool isDark) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: widget.isCurrentUser
            ? LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: !widget.isCurrentUser
            ? (isDark ? Colors.grey.shade800 : Colors.grey.shade100)
            : null,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(widget.isCurrentUser ? 20 : 4),
          bottomRight: Radius.circular(widget.isCurrentUser ? 4 : 20),
        ),
        boxShadow: [
          BoxShadow(
            color:
                (widget.isCurrentUser
                        ? Theme.of(context).primaryColor
                        : Colors.black)
                    .withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.message.isQuestion) _buildQuestionBadge(isDark),
          _buildMessageBody(isDark),
        ],
      ),
    );
  }

  Widget _buildMessageBody(bool isDark) {
    final message = widget.message;

    // Audio message
    if (message.isAudioMessage && message.hasFile) {
      return _buildAudioMessage(isDark);
    }

    // Image message
    if (message.isImageMessage && message.hasFile) {
      return _buildImageMessage(isDark);
    }

    // File message
    if (message.isFileMessage && message.hasFile) {
      return _buildFileMessage(isDark);
    }

    // Video message
    if (message.isVideoMessage && message.hasFile) {
      return _buildVideoMessage(isDark);
    }

    // Default: Text message
    return SelectableText(
      message.content,
      style: TextStyle(
        color: widget.isCurrentUser
            ? Colors.white
            : (isDark ? Colors.white : Colors.black87),
        fontSize: 15,
        height: 1.4,
      ),
    );
  }

  Widget _buildAudioMessage(bool isDark) {
    return VoiceMessageBubble(
      audioPath: "${ApiConstants.baseUrl}/${widget.message.fileUrl!}",
      duration: const Duration(seconds: 30),
      isCurrentUser: widget.isCurrentUser,
    );
  }

  Widget _buildImageMessage(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.message.content.isNotEmpty) ...[
          SelectableText(
            widget.message.content,
            style: TextStyle(
              color: widget.isCurrentUser
                  ? Colors.white
                  : (isDark ? Colors.white : Colors.black87),
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
        ],
        CachedNetworkImageWidget(
          imageUrl: "${ApiConstants.baseUrl}/${widget.message.fileUrl!}",
          height: 200,
          width: double.infinity,
          borderRadius: 12,
          fit: BoxFit.cover,
        ),
      ],
    );
  }

  Widget _buildFileMessage(bool isDark) {
    final fileUrl = widget.message.fileUrl != null
        ? "${ApiConstants.baseUrl}/${widget.message.fileUrl!}"
        : null;

    return GestureDetector(
      onTap: fileUrl != null ? () => _downloadFile(fileUrl) : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.isCurrentUser
              ? Colors.white.withOpacity(0.2)
              : (isDark ? Colors.grey.shade700 : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isCurrentUser
                ? Colors.white.withOpacity(0.3)
                : (isDark ? Colors.grey.shade600 : Colors.grey.shade300),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.insert_drive_file,
                size: 24,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.message.fileName ?? 'File',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: widget.isCurrentUser
                          ? Colors.white
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatFileSize(widget.message.fileSize ?? 0),
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isCurrentUser
                          ? Colors.white70
                          : (isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.download,
              size: 20,
              color: widget.isCurrentUser ? Colors.white70 : Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoMessage(bool isDark) {
    final videoUrl = widget.message.fileUrl != null
        ? "${ApiConstants.baseUrl}/${widget.message.fileUrl!}"
        : null;

    return GestureDetector(
      onTap: videoUrl != null ? () => _downloadFile(videoUrl) : null,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              color: Colors.grey.shade800,
              child: const Center(
                child: Icon(
                  Icons.play_circle_outline,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.message.fileName ?? 'Video',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade600],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.help_outline, size: 14, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'سؤال',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInfo(bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.messageStatus != null && widget.isCurrentUser) ...[
          _buildMessageStatus(),
          const SizedBox(width: 4),
        ],
        Text(
          _formatTime(widget.message.timestamp),
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        if (!widget.isCurrentUser) ...[
          const SizedBox(width: 6),
          Text(
            _getUserDisplayName(widget.message.user.name),
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        if (widget.message.xpEarned > 0) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade600],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 12, color: Colors.white),
                const SizedBox(width: 2),
                Text(
                  '+${widget.message.xpEarned}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ✅ Helper function
  String _getUserDisplayName(String name) {
    // If it's an email, extract the part before @
    if (name.contains('@')) {
      return name.split('@').first;
    }
    return name;
  }

  Widget _buildMessageStatus() {
    IconData icon;
    Color color;

    switch (widget.messageStatus) {
      case MessageStatus.sending:
        return SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Colors.grey.shade400),
          ),
        );
      case MessageStatus.sent:
        icon = Icons.check;
        color = Colors.grey.shade400;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.grey.shade400;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = Colors.blue.shade400;
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        color = Colors.red.shade400;
        break;
      default:
        return const SizedBox();
    }

    return Icon(icon, size: 16, color: color);
  }

  Widget _buildReactionRow(BuildContext context, Message message) {
    if (message.reactions.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group reactions by type
    final reactionCounts = <ReactionType, List<String>>{};
    for (final reaction in message.reactions) {
      if (!reactionCounts.containsKey(reaction.type)) {
        reactionCounts[reaction.type] = [];
      }
      reactionCounts[reaction.type]!.add(reaction.userId);
    }

    final currentUserId = CommunityConstants.currentUser.id;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: reactionCounts.entries.map((entry) {
          final reactionType = entry.key;
          final userIds = entry.value;
          final count = userIds.length;
          final hasUserReacted = userIds.contains(currentUserId);

          return GestureDetector(
            onTap: () {
              // ✅ Toggle reaction: Add if not reacted, Remove if already reacted
              if (hasUserReacted) {
                // Remove reaction
                context.read<ChatBloc>().add(
                  ChatRemoveReactionRequested(
                    messageId: message.id,
                    reactionType: reactionType,
                  ),
                );
              } else {
                // Add reaction
                context.read<ChatBloc>().add(
                  ChatAddReactionRequested(
                    messageId: message.id,
                    reactionType: reactionType,
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: hasUserReacted
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasUserReacted
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getReactionEmoji(reactionType),
                    style: const TextStyle(fontSize: 14),
                  ),
                  if (count > 1) ...[
                    const SizedBox(width: 4),
                    Text(
                      count.toString(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: hasUserReacted
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: hasUserReacted
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getReactionEmoji(ReactionType type) {
    switch (type) {
      case ReactionType.like:
        return '👍';
      case ReactionType.love:
        return '❤️';
      case ReactionType.laugh:
        return '😂';
      case ReactionType.wow:
        return '😮';
      case ReactionType.sad:
        return '😢';
      case ReactionType.angry:
        return '😠';
      case ReactionType.clap:
        return '👏';
      case ReactionType.fire:
        return '🔥';
      case ReactionType.correct:
        return '✅';
      case ReactionType.helpful:
        return '💡';
    }
  }

  // إصلاح _showMessageOptions - Quick Reactions
  void _showMessageOptions(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Quick Reactions
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Text(
                      'التفاعلات السريعة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ✅ Fixed - Row 1
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildQuickReaction(context, '👍', ReactionType.like),
                        _buildQuickReaction(context, '❤️', ReactionType.love),
                        _buildQuickReaction(context, '😂', ReactionType.laugh),
                        _buildQuickReaction(context, '😮', ReactionType.wow),
                        _buildQuickReaction(context, '😢', ReactionType.sad),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // ✅ Fixed - Row 2
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildQuickReaction(context, '😡', ReactionType.angry),
                        _buildQuickReaction(context, '👏', ReactionType.clap),
                        _buildQuickReaction(context, '🔥', ReactionType.fire),
                        _buildQuickReaction(context, '✅', ReactionType.correct),
                        _buildQuickReaction(
                          context,
                          '💡',
                          ReactionType.helpful,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Divider(height: 1),

              // Actions
              if (widget.onReply != null)
                _buildActionTile(
                  context,
                  icon: Icons.reply_rounded,
                  label: 'رد',
                  onTap: () {
                    Navigator.pop(context);
                    widget.onReply!();
                  },
                ),
              if (widget.onForward != null)
                _buildActionTile(
                  context,
                  icon: Icons.forward_rounded,
                  label: 'إعادة توجيه',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    widget.onForward!();
                  },
                ),
              if (widget.onCopy != null)
                _buildActionTile(
                  context,
                  icon: Icons.copy_rounded,
                  label: 'نسخ',
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(text: widget.message.content),
                    );
                    Navigator.pop(context);
                    widget.onCopy!();
                  },
                ),
              _buildActionTile(
                context,
                icon: Icons.info_outline_rounded,
                label: 'تفاصيل الرسالة',
                onTap: () {
                  Navigator.pop(context);
                  _showMessageDetails(context);
                },
              ),

              // Edit option
              if (widget.isCurrentUser && widget.onEdit != null)
                _buildActionTile(
                  context,
                  icon: Icons.edit_outlined,
                  label: 'تعديل',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    _showEditDialog(context);
                  },
                ),

              // Delete option
              if (widget.isCurrentUser && widget.onDelete != null)
                _buildActionTile(
                  context,
                  icon: Icons.delete_outline_rounded,
                  label: 'حذف',
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(context);
                  },
                ),

              if (widget.messageStatus == MessageStatus.failed &&
                  widget.onRetry != null)
                _buildActionTile(
                  context,
                  icon: Icons.refresh_rounded,
                  label: 'إعادة المحاولة',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    widget.onRetry!();
                  },
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickReaction(
    BuildContext context,
    String emoji,
    ReactionType type,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        widget.onReaction(type);
        // Show feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji),
                const SizedBox(width: 8),
                const Text('تم إضافة التفاعل'),
              ],
            ),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (color ?? Theme.of(context).primaryColor).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: color ?? Theme.of(context).primaryColor,
          size: 22,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  // ✅ Edit dialog
  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: widget.message.content);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit, color: Colors.blue),
            SizedBox(width: 8),
            Text('تعديل الرسالة'),
          ],
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'اكتب الرسالة الجديدة...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final newContent = controller.text.trim();
              if (newContent.isNotEmpty &&
                  newContent != widget.message.content) {
                Navigator.pop(context);
                widget.onEdit?.call(newContent);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✏️ تم تعديل الرسالة'),
                    duration: Duration(seconds: 1),
                  ),
                );
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showMessageDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('تفاصيل الرسالة'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('المرسل:', widget.message.user.name),
            _buildDetailRow('الوقت:', _formatTime(widget.message.timestamp)),
            _buildDetailRow(
              'النوع:',
              widget.message.isQuestion ? 'سؤال' : 'رسالة عادية',
            ),
            _buildDetailRow('النقاط:', '+${widget.message.xpEarned} XP'),
            if (widget.message.reactions.isNotEmpty)
              _buildDetailRow(
                'التفاعلات:',
                '${widget.message.reactions.length}',
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('حذف الرسالة'),
          ],
        ),
        content: const Text(
          'هل أنت متأكد من حذف هذه الرسالة؟ لن تتمكن من استرجاعها.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete!();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🗑️ تم حذف الرسالة')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'أمس ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _downloadFile(String fileUrl) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              const Text('جاري تحميل الملف...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Open the URL in the browser for download
      // You can use url_launcher package here
      // await launchUrl(Uri.parse(fileUrl));

      // For now, just show the URL (you'll need to implement actual download logic)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('رابط الملف: $fileUrl'),
            action: SnackBarAction(
              label: 'نسخ',
              textColor: Colors.white,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: fileUrl));
              },
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل الملف: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
