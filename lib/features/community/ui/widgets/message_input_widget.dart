import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/core.dart';
import '../../../../core/themes/font_weight_helper.dart';
import '../../data/models/message.dart';
import 'voice_recording_button.dart';

class MessageInputWidget extends StatefulWidget {
  final Function(String content, List<String>? attachments) onSendMessage;
  final Function(String audioPath, Duration duration) onSendVoiceMessage;
  final Function(String) onTyping;
  final bool isEnabled;
  final Message? replyToMessage;
  final VoidCallback? onCancelReply;

  const MessageInputWidget({
    super.key,
    required this.onSendMessage,
    required this.onSendVoiceMessage,
    required this.onTyping,
    this.isEnabled = true,
    this.replyToMessage,
    this.onCancelReply,
  });

  @override
  State<MessageInputWidget> createState() => _MessageInputWidgetState();
}

class _MessageInputWidgetState extends State<MessageInputWidget>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<String> _attachments = [];

  bool _showAttachmentOptions = false;
  bool _isRecording = false; // ✅ NEW: Track recording state

  late AnimationController _sendButtonController;
  late AnimationController _attachmentController;
  late AnimationController _expandController;
  late AnimationController
  _inputFadeController; // ✅ NEW: For input fade animation

  late Animation<double> _sendButtonScale;
  late Animation<double> _attachmentRotation;
  late Animation<double> _expandAnimation;
  late Animation<double> _inputFadeAnimation; // ✅ NEW

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupListeners();
  }

  void _setupAnimations() {
    // Send button scale animation
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _sendButtonScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sendButtonController, curve: Curves.easeOutBack),
    );

    // Attachment button rotation animation
    _attachmentController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _attachmentRotation = Tween<double>(begin: 0.0, end: 0.785).animate(
      CurvedAnimation(parent: _attachmentController, curve: Curves.easeInOut),
    );

    // Expand animation for attachment options
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutCubic,
    );

    // ✅ NEW: Input fade animation
    _inputFadeController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
      value: 1.0, // Start visible
    );
    _inputFadeAnimation = CurvedAnimation(
      parent: _inputFadeController,
      curve: Curves.easeInOut,
    );
  }

  void _setupListeners() {
    _controller.addListener(() {
      widget.onTyping(_controller.text);

      if (_controller.text.trim().isNotEmpty) {
        if (_sendButtonController.value != 1.0) {
          _sendButtonController.forward();
        }
      } else {
        if (_sendButtonController.value != 0.0) {
          _sendButtonController.reverse();
        }
      }

      if (mounted) setState(() {});
    });

    _focusNode.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
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
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Attachment Options (Expandable)
            if (!_isRecording) // ✅ Hide when recording
              _buildAttachmentOptions(),

            // Attachments Preview
            if (_attachments.isNotEmpty &&
                !_isRecording) // ✅ Hide when recording
              _buildAttachmentsPreview(),

            // Main Input Row
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Attachment Button
                  if (!_isRecording) // ✅ Hide when recording
                    _buildAttachmentButton(),

                  if (!_isRecording) // ✅ Hide when recording
                    const SizedBox(width: 8),

                  // Text Input (with fade animation)
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SizeTransition(
                            sizeFactor: animation,
                            axis: Axis.horizontal,
                            child: child,
                          ),
                        );
                      },
                      child: _isRecording
                          ? const SizedBox.shrink() // ✅ Hide input when recording
                          : _buildMessageInput(),
                    ),
                  ),

                  if (!_isRecording) // ✅ Only show spacing when not recording
                    const SizedBox(width: 8),

                  // Send/Voice Button
                  _buildActionButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOptions() {
    return SizeTransition(
      sizeFactor: _expandAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest.withOpacity(0.3),
          border: Border(
            bottom: BorderSide(
              color: context.colors.outlineVariant.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildAttachmentOption(
              icon: Icons.camera_alt_rounded,
              label: 'كاميرا',
              color: Colors.blue,
              onTap: () => _pickImage(ImageSource.camera),
            ),
            _buildAttachmentOption(
              icon: Icons.photo_library_rounded,
              label: 'معرض',
              color: Colors.green,
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            _buildAttachmentOption(
              icon: Icons.attach_file_rounded,
              label: 'ملف',
              color: Colors.orange,
              onTap: _pickFile,
            ),
            _buildAttachmentOption(
              icon: Icons.location_on_rounded,
              label: 'موقع',
              color: Colors.red,
              onTap: () {
                _toggleAttachmentOptions();
                _showComingSoonSnackbar('مشاركة الموقع');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withOpacity(0.8)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
              fontWeight: FontWeightHelper.medium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsPreview() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: context.colors.outlineVariant.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _attachments.length,
        itemBuilder: (context, index) {
          final attachment = _attachments[index];
          return _buildAttachmentCard(attachment, index);
        },
      ),
    );
  }

  Widget _buildAttachmentCard(String path, int index) {
    final isImage = _isImageFile(path);

    return Container(
      width: 64,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.outlineVariant, width: 1),
      ),
      child: Stack(
        children: [
          // Preview
          ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: isImage
                ? Image.file(
                    File(path),
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  )
                : Center(
                    child: Icon(
                      _getFileIcon(path),
                      size: 32,
                      color: context.colors.primary,
                    ),
                  ),
          ),

          // Remove Button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeAttachment(index),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentButton() {
    return AnimatedBuilder(
      animation: _attachmentRotation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _attachmentRotation.value,
          child: InkWell(
            onTap: widget.isEnabled ? _toggleAttachmentOptions : null,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _showAttachmentOptions
                    ? context.colors.primary
                    : context.colors.surfaceContainerHighest.withOpacity(0.5),
                shape: BoxShape.circle,
                boxShadow: _showAttachmentOptions
                    ? [
                        BoxShadow(
                          color: context.colors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                Icons.add_rounded,
                color: _showAttachmentOptions
                    ? Colors.white
                    : context.colors.onSurfaceVariant,
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return TextField(
      key: const ValueKey('message_input'), // ✅ For AnimatedSwitcher
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.isEnabled,
      maxLines: null,
      textInputAction: TextInputAction.newline,
      style: context.textTheme.bodyLarge,

      decoration: InputDecoration(
        fillColor: context.colors.surfaceContainerHighest.withOpacity(0.3),
        hintText: 'اكتب رسالة...',
        hintStyle: context.textTheme.bodyLarge?.copyWith(
          color: context.colors.onSurfaceVariant.withOpacity(0.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),

        border: InputBorder.none,
        // // Emoji button
        // suffixIcon: IconButton(
        //   icon: Icon(
        //     Icons.emoji_emotions_outlined,
        //     color: context.colors.onSurfaceVariant,
        //   ),
        //   onPressed: () {
        //     _showComingSoonSnackbar('الرموز التعبيرية');
        //   },
        // ),
      ),
    );
  }

  Widget _buildActionButton() {
    final hasText = _controller.text.trim().isNotEmpty;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: hasText
          ? _buildSendButton()
          : VoiceRecordingButton(
              key: const ValueKey('voice'),
              onAudioRecorded: (audioPath, duration) {
                // ✅ Reset recording state
                setState(() => _isRecording = false);
                _inputFadeController.forward();

                widget.onSendVoiceMessage(audioPath, duration);
              },
              onRecordingStart: () {
                // ✅ NEW: Set recording state and hide input
                setState(() => _isRecording = true);
                _inputFadeController.reverse();

                if (_showAttachmentOptions) {
                  _toggleAttachmentOptions();
                }
              },
              // ✅ NEW: Add callback for when recording is cancelled
              onRecordingCancel: () {
                setState(() => _isRecording = false);
                _inputFadeController.forward();
              },
            ),
    );
  }

  Widget _buildSendButton() {
    return ScaleTransition(
      scale: _sendButtonScale,
      child: InkWell(
        onTap: widget.isEnabled ? _sendMessage : null,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.colors.primary,
                context.colors.primary.withOpacity(0.85),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: context.colors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  void _toggleAttachmentOptions() {
    setState(() {
      _showAttachmentOptions = !_showAttachmentOptions;
    });

    if (_showAttachmentOptions) {
      _attachmentController.forward();
      _expandController.forward();
    } else {
      _attachmentController.reverse();
      _expandController.reverse();
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _attachments.add(image.path);
        });
        _toggleAttachmentOptions();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      _showErrorSnackbar('فشل اختيار الصورة');
    }
  }

  Future<void> _pickFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'zip'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _attachments.add(result.files.first.path!);
        });
        _toggleAttachmentOptions();
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      _showErrorSnackbar('فشل اختيار الملف');
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();

    if (text.isEmpty && _attachments.isEmpty) {
      return;
    }

    widget.onSendMessage(
      text,
      _attachments.isNotEmpty ? List.from(_attachments) : null,
    );

    // Clear input
    _controller.clear();
    _attachments.clear();

    // Hide attachment options if shown
    if (_showAttachmentOptions) {
      _toggleAttachmentOptions();
    }

    setState(() {});
  }

  bool _isImageFile(String path) {
    final extension = path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }

  IconData _getFileIcon(String path) {
    final extension = path.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'txt':
        return Icons.text_snippet_rounded;
      case 'zip':
        return Icons.folder_zip_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  void _showComingSoonSnackbar(String feature) {
    if (!mounted) return;

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
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _sendButtonController.dispose();
    _attachmentController.dispose();
    _expandController.dispose();
    _inputFadeController.dispose(); // ✅ Don't forget to dispose
    super.dispose();
  }
}
