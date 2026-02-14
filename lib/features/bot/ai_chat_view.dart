import 'package:simplify/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AIChatView extends StatefulWidget {
  const AIChatView({super.key});

  @override
  State<AIChatView> createState() => _AIChatViewState();
}

class _AIChatViewState extends State<AIChatView> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  late AnimationController _typingAnimationController;
  late AnimationController _botAnimationController;
  late Animation<double> _botScaleAnimation;

  bool _isTyping = false;

  @override
  void initState() {
    super.initState();

    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _botAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _botScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _botAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _botAnimationController.forward();

    // Add initial message
    _messages.add(
      ChatMessage(
        text: "Hi, Iam Educato Assistant how Can help you!",
        isBot: true,
        timestamp: DateTime.now(),
      ),
    );

    // Add quick actions
    _messages.add(
      ChatMessage(
        text: "",
        isBot: true,
        timestamp: DateTime.now(),
        quickActions: [
          'URL Educational Website',
          'Create Plan Study for schedule subjects',
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    _botAnimationController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(text: text, isBot: false, timestamp: DateTime.now()),
      );
      _messageController.clear();
      _isTyping = true;
    });

    // Scroll to bottom
    _scrollToBottom();

    // Simulate bot response
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(
            ChatMessage(
              text:
                  "I understand you need help with: $text\n\nI can assist you with creating study plans, finding educational resources, or answering questions about your subjects.",
              isBot: true,
              timestamp: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            context.setNavBarVisible(true);
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Message',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessage(_messages[index]);
              },
            ),
          ),

          // Input field
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    if (message.quickActions != null && message.quickActions!.isNotEmpty) {
      return _buildQuickActions(message.quickActions!);
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            message.isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (message.isBot) ...[_buildBotAvatar(), SizedBox(width: 12.w)],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color:
                    message.isBot
                        ? const Color(0xFF2D4F4F)
                        : const Color(0xFF167F71),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft:
                      message.isBot ? Radius.zero : Radius.circular(16.r),
                  bottomRight:
                      message.isBot ? Radius.circular(16.r) : Radius.zero,
                ),
                gradient:
                    message.isBot
                        ? null
                        : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF167F71),
                            const Color(0xFF0A5F53),
                          ],
                        ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotAvatar() {
    return ScaleTransition(
      scale: _botScaleAnimation,
      child: Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              const Color(0xFF167F71).withOpacity(0.8),
              const Color(0xFF0A5F53),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF167F71).withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Icon(Icons.smart_toy, color: Colors.white, size: 24.sp),
        ),
      ),
    );
  }

  Widget _buildQuickActions(List<String> actions) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children:
            actions.map((action) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: GestureDetector(
                  onTap: () => _sendMessage(action),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2D2D),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey[800]!, width: 1),
                    ),
                    child: Text(
                      action,
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 14.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          _buildBotAvatar(),
          SizedBox(width: 12.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFF2D4F4F),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
                bottomRight: Radius.circular(16.r),
              ),
            ),
            child: AnimatedBuilder(
              animation: _typingAnimationController,
              builder: (context, child) {
                return Row(
                  children: List.generate(3, (index) {
                    final delay = index * 0.2;
                    final animation = Tween<double>(
                      begin: 0.0,
                      end: 1.0,
                    ).animate(
                      CurvedAnimation(
                        parent: _typingAnimationController,
                        curve: Interval(
                          delay,
                          delay + 0.6,
                          curve: Curves.easeInOut,
                        ),
                      ),
                    );

                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 2.w),
                          width: 8.w,
                          height: 8.h,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(animation.value),
                            shape: BoxShape.circle,
                          ),
                        );
                      },
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2D),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: Colors.grey[800]!, width: 1),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'Ask me any thing',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                ),
                onSubmitted: _sendMessage,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: () => _sendMessage(_messageController.text),
            child: Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFF167F71), const Color(0xFF0A5F53)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF167F71).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(Icons.send_rounded, color: Colors.white, size: 20.sp),
            ),
          ),
        ],
      ),
    );
  }
}

// Chat Message Model
class ChatMessage {
  final String text;
  final bool isBot;
  final DateTime timestamp;
  final List<String>? quickActions;

  ChatMessage({
    required this.text,
    required this.isBot,
    required this.timestamp,
    this.quickActions,
  });
}
