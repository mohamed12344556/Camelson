import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class VoiceMessageBubble extends StatefulWidget {
  final String audioPath;
  final Duration duration;
  final bool isCurrentUser;

  const VoiceMessageBubble({
    super.key,
    required this.audioPath,
    required this.duration,
    required this.isCurrentUser,
  });

  @override
  State<VoiceMessageBubble> createState() => _VoiceMessageBubbleState();
}

class _VoiceMessageBubbleState extends State<VoiceMessageBubble>
    with TickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  late AnimationController _waveController;
  late AnimationController _playButtonController;

  bool _isPlaying = false;
  bool _isLoading = false;
  bool _hasError = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _initializeAudioPlayer();
    _initializeAnimations();
    _validateAudioFile();
  }

  void _validateAudioFile() async {
    try {
      // Check if it's a URL or local file path
      final isUrl = widget.audioPath.startsWith('http://') ||
          widget.audioPath.startsWith('https://');

      print('🔊 Validating audio: ${widget.audioPath}');
      print('🔊 Is URL: $isUrl');

      if (!isUrl) {
        // Local file validation
        final file = File(widget.audioPath);
        if (!await file.exists()) {
          print('❌ File does not exist: ${widget.audioPath}');
          if (mounted) {
            setState(() {
              _hasError = true;
            });
          }
          return;
        }

        final fileSize = await file.length();
        print('🔊 File size: $fileSize bytes');

        if (fileSize == 0) {
          print('❌ File is empty');
          if (mounted) {
            setState(() {
              _hasError = true;
            });
          }
          return;
        }
      }

      print('✅ Audio validation passed');

      // Set the duration from widget parameter
      if (mounted) {
        setState(() {
          _totalDuration = widget.duration;
          _hasError = false;
        });
      }
    } catch (e) {
      print('❌ Error validating audio: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  void _initializeAudioPlayer() {
    _audioPlayer = AudioPlayer();
    _totalDuration = widget.duration;

    // Listen to player state changes
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((
      state,
    ) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          _isLoading =
              state == PlayerState.playing && _currentPosition == Duration.zero;
        });

        if (state == PlayerState.playing) {
          _waveController.repeat(reverse: true);
          _playButtonController.forward();
        } else {
          _waveController.stop();
          _playButtonController.reverse();
        }

        if (state == PlayerState.completed) {
          _resetPlayer();
        }
      }
    });

    // Listen to position changes
    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoading = false;
        });
      }
    });

    // Listen to duration changes
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted && duration.inMilliseconds > 0) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });
  }

  void _initializeAnimations() {
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _playButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    print('🗑️ VoiceMessageBubble disposing...');

    // ✅ Cancel subscriptions first
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();

    // ✅ Stop and dispose audio player
    _audioPlayer.stop();
    _audioPlayer.dispose();

    // ✅ Dispose animation controllers
    _waveController.dispose();
    _playButtonController.dispose();

    super.dispose();
    print('✅ VoiceMessageBubble disposed');
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorWidget();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(maxWidth: 280),
      decoration: BoxDecoration(
        color: widget.isCurrentUser
            ? Theme.of(context).primaryColor
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play/Pause/Loading button
          _buildPlayButton(),
          const SizedBox(width: 12),
          // Waveform and progress
          Expanded(child: _buildWaveformWithProgress()),
          const SizedBox(width: 8),
          // Duration/Position
          _buildTimeDisplay(),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(maxWidth: 280),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'خطأ في تحميل الملف الصوتي',
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: _togglePlayback,
      child: AnimatedBuilder(
        animation: _playButtonController,
        builder: (context, child) {
          return Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: widget.isCurrentUser
                  ? Colors.white.withOpacity(0.2)
                  : Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.isCurrentUser
                    ? Colors.white.withOpacity(0.3)
                    : Theme.of(context).primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.isCurrentUser
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                        ),
                      ),
                    )
                  : AnimatedRotation(
                      turns: _playButtonController.value * 0.5,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: widget.isCurrentUser
                            ? Colors.white
                            : Theme.of(context).primaryColor,
                        size: 24,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWaveformWithProgress() {
    return Column(
      children: [
        // Waveform
        SizedBox(height: 30, child: _buildWaveform()),
        const SizedBox(height: 4),
        // Progress bar
        _buildProgressBar(),
      ],
    );
  }

  Widget _buildWaveform() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(20, (index) {
            final progress = _totalDuration.inMilliseconds > 0
                ? _currentPosition.inMilliseconds /
                      _totalDuration.inMilliseconds
                : 0.0;
            final isActive = (index / 20) <= progress;

            final baseHeight = 4.0;
            final maxHeight = 20.0;
            final animatedHeight =
                baseHeight +
                (maxHeight - baseHeight) * (0.3 + 0.7 * (1 + (index % 3)) / 3);

            final waveOffset = _isPlaying
                ? (0.8 +
                      0.4 *
                          (0.5 +
                              0.5 *
                                  (_waveController.value + (index * 0.1)) %
                                  1.0))
                : 1.0;

            return Container(
              width: 2.5,
              height: animatedHeight * waveOffset,
              decoration: BoxDecoration(
                color:
                    (widget.isCurrentUser
                            ? Colors.white
                            : Theme.of(context).primaryColor)
                        .withOpacity(isActive ? 0.9 : 0.4),
                borderRadius: BorderRadius.circular(1.5),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildProgressBar() {
    final progress = _totalDuration.inMilliseconds > 0
        ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
        : 0.0;

    return Container(
      height: 3,
      decoration: BoxDecoration(
        color: (widget.isCurrentUser ? Colors.white : Colors.grey).withOpacity(
          0.3,
        ),
        borderRadius: BorderRadius.circular(1.5),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: widget.isCurrentUser
                ? Colors.white
                : Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeDisplay() {
    return Column(
      children: [
        Text(
          _formatDuration(_isPlaying ? _currentPosition : _totalDuration),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: widget.isCurrentUser ? Colors.white70 : Colors.grey[600],
          ),
        ),
        if (_isPlaying && _totalDuration.inSeconds > 0) ...[
          const SizedBox(height: 2),
          Text(
            '/ ${_formatDuration(_totalDuration)}',
            style: TextStyle(
              fontSize: 9,
              color: widget.isCurrentUser ? Colors.white60 : Colors.grey[500],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _togglePlayback() async {
    if (_hasError) {
      _showError('لا يمكن تشغيل الملف الصوتي');
      return;
    }

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        final isUrl = widget.audioPath.startsWith('http://') ||
            widget.audioPath.startsWith('https://');

        print('🔊 Attempting to play: ${widget.audioPath}');
        print('🔊 Source type: ${isUrl ? "URL" : "Local File"}');

        // Validate local file only
        if (!isUrl) {
          final file = File(widget.audioPath);
          if (!await file.exists()) {
            print('❌ File not found during playback');
            if (mounted) {
              setState(() {
                _hasError = true;
              });
            }
            _showError('ملف الصوت غير موجود');
            return;
          }

          final fileSize = await file.length();
          print('🔊 File size during playback: $fileSize bytes');

          if (fileSize == 0) {
            print('❌ File is empty during playback');
            if (mounted) {
              setState(() {
                _hasError = true;
              });
            }
            _showError('ملف الصوت فارغ');
            return;
          }
        }

        if (mounted) {
          setState(() {
            _isLoading = true;
          });
        }

        if (_currentPosition.inMilliseconds >= _totalDuration.inMilliseconds) {
          await _audioPlayer.seek(Duration.zero);
        }

        print('🔊 Starting playback...');

        // Use appropriate source based on type
        if (isUrl) {
          await _audioPlayer.play(UrlSource(widget.audioPath));
        } else {
          await _audioPlayer.play(DeviceFileSource(widget.audioPath));
        }

        print('🔊 Playback started successfully');
      }
    } catch (e) {
      print('❌ Playback error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
      _showError('خطأ في تشغيل الصوت: ${e.toString()}');
    }
  }

  void _resetPlayer() {
    if (mounted) {
      setState(() {
        _isPlaying = false;
        _currentPosition = Duration.zero;
        _isLoading = false;
      });
      _waveController.reset();
      _playButtonController.reverse();
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds % 60);
    return '$minutes:$seconds';
  }
}

// Voice Message Test Button للتجربة
class VoiceMessageTestWidget extends StatelessWidget {
  const VoiceMessageTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.mic, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'تجربة الرسائل الصوتية',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Sample voice messages
          VoiceMessageBubble(
            audioPath:
                '/storage/emulated/0/Download/sample_voice.m4a', // مسار تجريبي
            duration: const Duration(minutes: 2, seconds: 15),
            isCurrentUser: true,
          ),

          const SizedBox(height: 8),

          VoiceMessageBubble(
            audioPath:
                '/storage/emulated/0/Download/sample_voice2.m4a', // مسار تجريبي
            duration: const Duration(seconds: 45),
            isCurrentUser: false,
          ),

          const SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    '🎤 لتجربة التسجيل الفعلي، استخدم الميكروفون في المدخل',
                  ),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            icon: const Icon(Icons.mic),
            label: const Text('اختبار التسجيل'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          ),
        ],
      ),
    );
  }
}
