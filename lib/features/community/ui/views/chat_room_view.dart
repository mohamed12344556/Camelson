import 'dart:async';
import 'package:boraq/features/community/data/models/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/core.dart';
import '../../../../core/themes/font_weight_helper.dart';
import '../../../../core/widgets/modern_dialogs.dart';
import '../../../../core/widgets/modern_error_state.dart';
import '../../data/models/community_constants.dart';
import '../../data/models/room.dart';
import '../../data/models/user.dart';
import '../logic/chat_bloc/chat_bloc.dart';
import '../logic/chat_bloc/chat_event.dart';
import '../logic/chat_bloc/chat_state.dart';
import '../widgets/chat_loading_shimmer.dart';
import '../widgets/connection_status_widget.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input_widget.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/question_members_bottom_sheet.dart';
import '../widgets/edit_question_bottom_sheet.dart';
import '../../data/services/question_service.dart';

class ChatRoomView extends StatefulWidget {
  final Room? room;
  final bool isViewOnly;

  const ChatRoomView({super.key, this.room, this.isViewOnly = false});

  @override
  State<ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<ChatRoomView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  late ChatBloc _chatBloc;
  Timer? _typingTimer;
  bool _isTyping = false;
  bool _showScrollToBottom = false;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  Message? _replyToMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _chatBloc = context.read<ChatBloc>();
    _setupScrollListener();
    _setupAnimations();
    _connectToChat();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;

      // Show/hide scroll to bottom button
      // الآن نتحقق إذا كان المستخدم بعيد عن الأسفل بأكثر من 300 بكسل
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      final showButton = (maxScroll - currentScroll) > 300;

      if (showButton != _showScrollToBottom) {
        setState(() => _showScrollToBottom = showButton);
      }

      // Load more messages when scrolled to top
      if (_scrollController.position.pixels <=
          _scrollController.position.minScrollExtent + 100) {
        _loadMoreMessages();
      }
    });
  }

  void _setupAnimations() {
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    );
  }

  void _connectToChat() {
    if (widget.room != null) {
      _chatBloc.add(
        ChatConnectRequested(
          userId: CommunityConstants.currentUser.id,
          roomId: widget.room!.id,
          isViewOnly: widget.isViewOnly,
        ),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // _chatBloc.add(const ChatReconnectRequested());
    }
  }

  @override
  void dispose() {
    print('🗑️ ChatRoomView disposing...');

    // ✅ 1. Leave the room via SignalR BEFORE disposing Bloc
    if (widget.room != null) {
      _chatBloc.add(ChatLeaveRoomRequested(widget.room!.id));
    }

    // ✅ 2. Cancel all timers
    _typingTimer?.cancel();

    // ✅ 3. Clean up controllers
    _scrollController.dispose();
    _fabController.dispose();

    // ✅ 4. Remove observer
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
    print('✅ ChatRoomView disposed');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print('🔙 User pressed back button');
        return true; // Allow pop
      },
      child: Scaffold(
        backgroundColor: context.colors.surface,
        appBar: _buildAppBar(),
        body: BlocConsumer<ChatBloc, ChatState>(
          listener: _handleStateChanges,
          builder: _buildBody,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.colors.primary,
              context.colors.primary.withOpacity(0.85),
            ],
          ),
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoaded) {
            return _buildAppBarTitle(state);
          }
          return Text(
            widget.room?.name ?? 'Chat',
            style: context.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeightHelper.bold,
            ),
          );
        },
      ),
      actions: _buildAppBarActions(),
    );
  }

  Widget _buildAppBarTitle(ChatLoaded state) {
    return InkWell(
      onTap: () => _showRoomDetails(state),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Room Avatar
            Hero(
              tag: 'room_${state.room.id}',
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    state.room.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Room Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.room.name,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeightHelper.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Typing indicator or member count
                  if (state.typingUsers.isNotEmpty)
                    _buildTypingIndicatorText(state.typingUsers)
                  else
                    Text(
                      '${state.room.memberCount} members',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicatorText(List<User> typingUsers) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white.withOpacity(0.8),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            typingUsers.length == 1
                ? '${typingUsers.first.name} is typing...'
                : 'Several people are typing...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
              fontStyle: FontStyle.italic,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAppBarActions() {
    // Only the question creator can manage (edit/close)
    final canManage =
        widget.room?.creatorId == CommunityConstants.currentUser.id;

    return [
      // Search
      IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.search_rounded, color: Colors.white),
        ),
        onPressed: () => _showComingSoonSnackbar('البحث في المحادثة'),
      ),

      // More options
      PopupMenuButton<String>(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.more_vert_rounded, color: Colors.white),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        itemBuilder: (context) => [
          _buildPopupMenuItem(
            icon: Icons.people_rounded,
            title: 'عرض الأعضاء',
            value: 'members',
          ),
          // Only show edit option if user has admin privileges
          if (canManage)
            _buildPopupMenuItem(
              icon: Icons.edit_rounded,
              title: 'تعديل السؤال',
              value: 'edit',
            ),
          _buildPopupMenuItem(
            icon: Icons.attach_file_rounded,
            title: 'الملفات المرفقة',
            value: 'attachments',
          ),
          _buildPopupMenuItem(
            icon: Icons.notifications_off_rounded,
            title: 'كتم الإشعارات',
            value: 'mute',
          ),
          const PopupMenuDivider(),
          // Only show close option if user has admin privileges
          if (canManage)
            _buildPopupMenuItem(
              icon: Icons.close_rounded,
              title: 'إغلاق السؤال',
              value: 'close',
              isDestructive: true,
            ),
          if (!widget.isViewOnly)
            _buildPopupMenuItem(
              icon: Icons.exit_to_app_rounded,
              title: 'مغادرة الغرفة',
              value: 'leave',
              isDestructive: true,
            ),
        ],
        onSelected: _handleMenuAction,
      ),
      const SizedBox(width: 8),
    ];
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required IconData icon,
    required String title,
    required String value,
    bool isDestructive = false,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDestructive ? Colors.red : context.colors.onSurface,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: isDestructive ? Colors.red : context.colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  int _previousMessageCount = 0;
  String _previousLastMessageId = '';

  void _handleStateChanges(BuildContext context, ChatState state) {
    if (state is ChatLoaded) {
      // ✅ Check if messages changed by comparing both count AND last message ID
      final currentLastMessageId = state.messages.isNotEmpty
          ? state.messages.last.id
          : '';

      final shouldScroll =
          state.messages.length != _previousMessageCount ||
          currentLastMessageId != _previousLastMessageId;

      _previousMessageCount = state.messages.length;
      _previousLastMessageId = currentLastMessageId;

      if (shouldScroll && state.messages.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            // Use a delay to ensure the ListView is fully built
            Future.delayed(const Duration(milliseconds: 150), () {
              if (_scrollController.hasClients) {
                _scrollToBottom(animate: state.messages.length > 1);
              }
            });
          }
        });
      }

      // Show/hide FAB
      if (!_showScrollToBottom) {
        _fabController.forward();
      } else {
        _fabController.reverse();
      }
    }

    if (state is ChatError) {
      _showErrorSnackbar(state.message);
    }
  }

  Widget _buildBody(BuildContext context, ChatState state) {
    if (state is ChatInitial || state is ChatLoading) {
      return const ChatLoadingShimmer();
    }

    if (state is ChatError && state.previousState == null) {
      return ErrorStateExtension.fromErrorMessage(
        state.message,
        onRetry: _connectToChat,
      );
    }

    if (state is ChatLoaded || state is ChatReconnecting) {
      final chatState = state is ChatLoaded
          ? state
          : (state as ChatReconnecting).previousState as ChatLoaded;

      return Column(
        children: [
          // Connection Status Banner
          if (chatState.connectionStatus != ConnectionStatus.connected)
            ConnectionStatusWidget(
              status: chatState.connectionStatus,
              isReconnecting: state is ChatReconnecting,
            ),

          // Messages List
          Expanded(
            child: Stack(
              children: [
                _buildMessagesList(chatState),

                // Scroll to bottom FAB
                if (_showScrollToBottom)
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: ScaleTransition(
                      scale: _fabAnimation,
                      child: FloatingActionButton.small(
                        onPressed: () => _scrollToBottom(animate: true),
                        backgroundColor: context.colors.primary,
                        child: const Icon(
                          Icons.arrow_downward_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Reply Preview (hidden in view-only mode)
          if (_replyToMessage != null && !chatState.isViewOnly)
            _buildReplyPreview(),

          // Message Input
          _buildMessageInput(chatState),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildMessagesList(ChatLoaded state) {
    if (state.messages.isEmpty) {
      return Column(
        children: [
          _buildQuestionHeader(state),
          const Expanded(
            child: Center(child: Text('لا توجد رسائل بعد، كن أول من يجيب!')),
          ),
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            context.colors.surface,
            context.colors.primary.withOpacity(0.01),
          ],
        ),
      ),
      child: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              physics: const BouncingScrollPhysics(),
              // +1 for the question header at index 0
              itemCount: state.messages.length + 1,
              itemBuilder: (context, index) {
                // First item is the question header
                if (index == 0) {
                  return _buildQuestionHeader(state);
                }
                final messageIndex = index - 1;
                final message = state.messages[messageIndex];
                final isCurrentUser =
                    message.userId == CommunityConstants.currentUser.id;

                final showAvatar = _shouldShowAvatar(
                  state.messages,
                  messageIndex,
                );
                final viewOnly = state.isViewOnly;
                return MessageBubble(
                  key: ValueKey(message.id),
                  message: message,
                  isCurrentUser: isCurrentUser,
                  showAvatar: showAvatar,
                  messageStatus: isCurrentUser
                      ? state.messageStatuses[message.id]
                      : null,
                  onReaction: viewOnly
                      ? (_) {}
                      : (type) => context.read<ChatBloc>().add(
                          ChatAddReactionRequested(
                            messageId: message.id,
                            reactionType: type,
                          ),
                        ),
                  onReply: viewOnly
                      ? null
                      : () {
                          setState(() {
                            _replyToMessage = message;
                          });
                        },
                  onForward: viewOnly
                      ? null
                      : () => _showComingSoonSnackbar('إعادة توجيه الرسالة'),
                  onDelete: viewOnly
                      ? null
                      : isCurrentUser
                      ? () => context.read<ChatBloc>().add(
                          ChatDeleteMessage(message.id),
                        )
                      : null,
                  onRetry: viewOnly
                      ? null
                      : state.messageStatuses[message.id] ==
                            MessageStatus.failed
                      ? () => _retryMessage(message)
                      : null,
                  onEdit: viewOnly
                      ? null
                      : isCurrentUser
                      ? (newContent) => context.read<ChatBloc>().add(
                          ChatUpdateMessage(
                            messageId: message.id,
                            newContent: newContent,
                          ),
                        )
                      : null,
                  onCopy: () => _copyMessage(message),
                  replyToMessage: message.replyToId != null
                      ? _findMessageById(state.messages, message.replyToId!)
                      : null,
                );
              },
            ),
          ),

          // ✅ Typing Indicator (في الأسفل)
          if (state.typingUsers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: TypingIndicator(users: state.typingUsers),
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionHeader(ChatLoaded state) {
    final room = state.room;
    final description = widget.room?.description ?? room.description;
    final creatorName = widget.room?.creatorName ?? room.creatorName ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.primary.withOpacity(0.08),
            context.colors.primary.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question label
          Row(
            children: [
              Icon(
                Icons.help_outline_rounded,
                size: 18,
                color: context.colors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'السؤال',
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeightHelper.bold,
                ),
              ),
              const Spacer(),
              if (creatorName.isNotEmpty)
                Text(
                  creatorName,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Question title
          Text(
            room.name,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeightHelper.bold,
            ),
          ),

          // Question description (if different from title)
          if (description != null &&
              description.isNotEmpty &&
              description != room.name) ...[
            const SizedBox(height: 8),
            Text(
              description,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Subject tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: context.colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              room.subject,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowAvatar(List<Message> messages, int index) {
    if (index == messages.length - 1) return true;

    final currentMessage = messages[index];
    final nextMessage = messages[index + 1];

    return currentMessage.userId != nextMessage.userId;
  }

  Message? _findMessageById(List<Message> messages, String id) {
    try {
      return messages.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  Widget _buildReplyPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withOpacity(0.5),
        border: Border(
          top: BorderSide(color: context.colors.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: context.colors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الرد على ${_replyToMessage!.user.name}',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeightHelper.semiBold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _replyToMessage!.content,
                  style: context.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          IconButton(
            icon: Icon(
              Icons.close_rounded,
              size: 20,
              color: context.colors.onSurfaceVariant,
            ),
            onPressed: () {
              setState(() => _replyToMessage = null);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(ChatLoaded state) {
    // View-only mode: show info bar instead of input
    if (state.isViewOnly) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          border: Border(
            top: BorderSide(color: context.colors.outlineVariant, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.visibility_rounded,
              size: 18,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              'أنت في وضع المشاهدة فقط',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: MessageInputWidget(
        onSendMessage: (content, attachments) {
          _chatBloc.add(
            ChatSendMessageRequested(
              content: content,
              attachmentPaths: attachments,
              replyToId: _replyToMessage?.id,
            ),
          );

          // Clear reply
          if (_replyToMessage != null) {
            setState(() => _replyToMessage = null);
          }

          // Scroll to bottom
          _scrollToBottom(animate: true);
        },
        onSendVoiceMessage: (audioPath, duration) {
          _chatBloc.add(
            ChatSendMessageRequested(
              content: '🎤 رسالة صوتية (${_formatDuration(duration)})',
              attachmentPaths: [audioPath],
              replyToId: _replyToMessage?.id,
            ),
          );

          // Clear reply
          if (_replyToMessage != null) {
            setState(() => _replyToMessage = null);
          }
        },
        onTyping: _handleTyping,
        isEnabled: state.connectionStatus == ConnectionStatus.connected,
        replyToMessage: _replyToMessage,
        onCancelReply: () {
          setState(() => _replyToMessage = null);
        },
      ),
    );
  }

  void _handleTyping(String text) {
    if (text.isNotEmpty) {
      if (!_isTyping) {
        _isTyping = true;
        print('📝 User started typing, sending event...');
        _chatBloc.add(const ChatTypingRequested(isTyping: true));
      } else {
        // ✅ Refresh typing indicator while user is still typing
        print('🔄 User still typing, refreshing indicator...');
        _chatBloc.add(const ChatTypingRequested(isTyping: true));
      }

      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 3), () {
        if (_isTyping) {
          _isTyping = false;
          print('⏸️ User stopped typing, sending event...');
          _chatBloc.add(const ChatTypingRequested(isTyping: false));
        }
      });
    }
  }

  void _scrollToBottom({bool animate = false}) {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;

    if (animate) {
      _scrollController.animateTo(
        maxScroll,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(maxScroll);
    }
  }

  void _loadMoreMessages() {
    // _chatBloc.add(const ChatLoadMoreMessagesRequested());
  }

  void _deleteMessage(Message message) {
    ModernDialogs.showConfirmationDialog(
      context: context,
      title: 'حذف الرسالة',
      message: 'هل أنت متأكد من حذف هذه الرسالة؟',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
      // isDestructive: true,
      // onConfirm: () {
      //   _chatBloc.add(ChatDeleteMessageRequested(messageId: message.id));
      // },
    );
  }

  void _retryMessage(Message message) {
    // _chatBloc.add(ChatRetryMessageRequested(messageId: message.id));
  }

  void _copyMessage(Message message) {
    Clipboard.setData(ClipboardData(text: message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 12),
            Text('تم نسخ الرسالة'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'members':
        _showMembersBottomSheet();
        break;
      case 'edit':
        _showEditQuestionDialog();
        break;
      case 'attachments':
        _showComingSoonSnackbar('الملفات المرفقة');
        break;
      case 'mute':
        _showComingSoonSnackbar('كتم الإشعارات');
        break;
      case 'close':
        _closeQuestion();
        break;
      case 'leave':
        _leaveRoom();
        break;
    }
  }

  void _showMembersBottomSheet() {
    if (widget.room == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) =>
            QuestionMembersBottomSheet(questionId: widget.room!.id),
      ),
    );
  }

  Future<void> _showEditQuestionDialog() async {
    if (widget.room == null) return;

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Fetch full question data
      final questionService = sl<QuestionService>();
      final question = await questionService.getQuestionById(widget.room!.id);

      if (!mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      // Show edit bottom sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: EditQuestionBottomSheet(
            question: question,
            onQuestionUpdated: () {
              // Optionally refresh chat data
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Close loading dialog if still open
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('فشل في تحميل بيانات السؤال: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _closeQuestion() async {
    if (widget.room == null) return;

    final confirmed = await ModernDialogs.showConfirmationDialog(
      context: context,
      title: 'إغلاق السؤال',
      message:
          'هل أنت متأكد من إغلاق هذا السؤال؟ لن يتمكن الأعضاء من إرسال رسائل جديدة.',
      confirmText: 'إغلاق',
      cancelText: 'إلغاء',
      icon: Icons.close_rounded,
      confirmColor: Colors.red,
    );

    if (confirmed != true || !mounted) return;

    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('جاري إغلاق السؤال...'),
            ],
          ),
          backgroundColor: context.colors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Close question via API
      final questionService = sl<QuestionService>();
      final success = await questionService.closeQuestion(widget.room!.id);

      if (!mounted) return;

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('تم إغلاق السؤال بنجاح'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate back after a short delay
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        throw Exception('فشل في إغلاق السؤال');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('خطأ: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _leaveRoom() async {
    if (widget.room == null) return;

    final confirmed = await ModernDialogs.showConfirmationDialog(
      context: context,
      title: 'مغادرة الغرفة',
      message: 'هل أنت متأكد من مغادرة هذه الغرفة؟',
      confirmText: 'مغادرة',
      cancelText: 'إلغاء',
      icon: Icons.exit_to_app_rounded,
      confirmColor: Colors.red,
    );

    if (confirmed != true || !mounted) return;

    _chatBloc.add(ChatLeaveRoomRequested(widget.room!.id));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 12),
            Text('تم مغادرة الغرفة'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );

    // Return room ID so community view tracks it as left
    Navigator.pop(context, widget.room!.id);
  }

  void _showRoomDetails(ChatLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildRoomDetailsSheet(state),
    );
  }

  Widget _buildRoomDetailsSheet(ChatLoaded state) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.onSurfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 24),

          // Room Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [context.colors.primary, context.colors.secondary],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: context.colors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                state.room.name[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Room Name
          Text(
            state.room.name,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeightHelper.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Room Description
          // if (state.room.description.isNotEmpty)
          //   Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 24),
          //     child: Text(
          //       state.room.description,
          //       style: context.textTheme.bodyMedium?.copyWith(
          //         color: context.colors.onSurfaceVariant,
          //       ),
          //       textAlign: TextAlign.center,
          //       maxLines: 2,
          //       overflow: TextOverflow.ellipsis,
          //     ),
          //   ),
          const SizedBox(height: 24),

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn(
                icon: Icons.people_rounded,
                label: 'الأعضاء',
                value: '${state.room.memberCount}',
              ),
              _buildStatColumn(
                icon: Icons.message_rounded,
                label: 'الرسائل',
                value: '${state.room.messageCount}',
              ),
              _buildStatColumn(
                icon: Icons.class_rounded,
                label: 'المادة',
                value: state.room.subject,
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(),

          // Actions
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildActionTile(
                  icon: Icons.people_rounded,
                  title: 'عرض الأعضاء',
                  subtitle: '${state.room.memberCount} عضو',
                  onTap: () => _showComingSoonSnackbar('عرض الأعضاء'),
                ),
                _buildActionTile(
                  icon: Icons.attach_file_rounded,
                  title: 'الملفات المشتركة',
                  subtitle: 'الصور والملفات',
                  onTap: () => _showComingSoonSnackbar('الملفات المشتركة'),
                ),
                _buildActionTile(
                  icon: Icons.notifications_rounded,
                  title: 'الإشعارات',
                  subtitle: 'إدارة الإشعارات',
                  onTap: () => _showComingSoonSnackbar('إدارة الإشعارات'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: context.colors.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeightHelper.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: context.colors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: context.colors.primary, size: 24),
      ),
      title: Text(
        title,
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeightHelper.semiBold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: context.colors.onSurfaceVariant,
      ),
    );
  }

  void _showComingSoonSnackbar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Text('$feature قريباً!'),
          ],
        ),
        backgroundColor: context.colors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'إعادة المحاولة',
          textColor: Colors.white,
          onPressed: _connectToChat,
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds % 60);
    return '$minutes:$seconds';
  }
}
