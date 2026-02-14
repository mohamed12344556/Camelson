import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:wave_blob/wave_blob.dart'; // ✅ NEW

class VoiceRecordingButton extends StatefulWidget {
  final Function(String audioPath, Duration duration) onAudioRecorded;
  final VoidCallback? onRecordingStart;
  final VoidCallback? onRecordingCancel;

  const VoiceRecordingButton({
    super.key,
    required this.onAudioRecorded,
    this.onRecordingStart,
    this.onRecordingCancel,
  });

  @override
  State<VoiceRecordingButton> createState() => _VoiceRecordingButtonState();
}

class _VoiceRecordingButtonState extends State<VoiceRecordingButton>
    with TickerProviderStateMixin {
  final AudioRecorder _recorder = AudioRecorder();
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  bool _isRecording = false;
  bool _hasPermission = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _timer;
  String? _currentRecordingPath;

  // ✅ NEW: For WaveBlob amplitude control
  double _amplitude = 0.0;
  Timer? _amplitudeTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkPermissions();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.microphone.request();
    setState(() {
      _hasPermission = status == PermissionStatus.granted;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    _timer?.cancel();
    _amplitudeTimer?.cancel(); // ✅ NEW
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isRecording) {
      return _buildRecordingUI();
    }
    return _buildRecordButton();
  }

  Widget _buildRecordButton() {
    return GestureDetector(
      onLongPressStart: (_) => _startRecording(),
      onLongPressEnd: (_) => _stopRecording(),
      onTap: () => _showRecordingInstructions(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _hasPermission ? Icons.mic : Icons.mic_off,
                color: Colors.white,
                size: 24,
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ UPDATED: Recording UI with WaveBlob
  Widget _buildRecordingUI() {
    return Container(
      height: 56,
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        // mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Cancel button
          GestureDetector(
            onTap: _cancelRecording,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.red, size: 20),
            ),
          ),
          const SizedBox(width: 12),

          // ✅ NEW: WaveBlob Animation
          SizedBox(
            width: 48,
            height: 48,
            child: WaveBlob(
              blobCount: 2,
              amplitude: _amplitude,
              scale: 1.0,
              autoScale: true,
              centerCircle: true,
              overCircle: true,
              circleColors: const [Colors.red, Colors.redAccent],
              child: const Icon(Icons.mic, color: Colors.white, size: 24),
            ),
          ),

          const SizedBox(width: 12),
          // Duration text
          Text(
            _formatDuration(_recordingDuration),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          const SizedBox(width: 12),

          // Stop/Send button
          GestureDetector(
            onTap: _stopRecording,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startRecording() async {
    if (!_hasPermission) {
      _showError('لم يتم منح إذن الميكروفون');
      return;
    }

    _scaleController.forward().then((_) => _scaleController.reverse());

    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _currentRecordingPath = '${directory.path}/$fileName';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _currentRecordingPath!,
      );

      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
      });

      widget.onRecordingStart?.call();
      HapticFeedback.lightImpact();

      _startTimer();
      _startAmplitudeAnimation(); // ✅ NEW

      _showSnackBar('🎤 جاري التسجيل...', Colors.green, Icons.mic);
    } catch (e) {
      _showError('فشل في بدء التسجيل: ${e.toString()}');
    }
  }

  // ✅ NEW: Animate amplitude for WaveBlob
  void _startAmplitudeAnimation() async {
    final stream = _recorder.onAmplitudeChanged(
      const Duration(milliseconds: 100),
    );
    stream.listen((amplitude) {
      setState(() {
        // تحويل amplitude من -160dB to 0dB إلى 0-8500
        _amplitude = ((amplitude.current + 160) / 160 * 8500).clamp(
          0.0,
          8500.0,
        );
      });
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    try {
      final recordedDuration = _recordingDuration;
      final path = await _recorder.stop();

      _timer?.cancel();
      _amplitudeTimer?.cancel(); // ✅ NEW

      setState(() {
        _isRecording = false;
        _amplitude = 0.0; // ✅ Reset amplitude
      });

      if (path != null && recordedDuration.inMilliseconds >= 500) {
        final file = File(path);
        if (await file.exists()) {
          final fileSize = await file.length();
          if (fileSize > 1000) {
            widget.onAudioRecorded(path, recordedDuration);
            _showSnackBar(
              '✅ تم تسجيل رسالة صوتية (${_formatDuration(recordedDuration)})',
              Colors.green,
              Icons.check_circle,
            );
          } else {
            await file.delete();
            _showError('فشل التسجيل - ملف صغير جداً');
          }
        } else {
          _showError('فشل في حفظ الملف الصوتي');
        }
      } else {
        _showError('التسجيل قصير جداً (الحد الأدنى نصف ثانية)');
        if (path != null) {
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      _stopRecordingUI();
      _showError('فشل في إيقاف التسجيل: ${e.toString()}');
    }
  }

  Future<void> _cancelRecording() async {
    try {
      final recordedDuration = _recordingDuration;
      if (_isRecording) {
        await _recorder.stop();
        if (_currentRecordingPath != null) {
          final file = File(_currentRecordingPath!);
          if (await file.exists()) {
            await file.delete();
          }
        }
      }

      _stopRecordingUI();
      widget.onRecordingCancel?.call();

      _showSnackBar(
        '❌ تم إلغاء التسجيل (كان ${recordedDuration.inSeconds}s)',
        Colors.orange,
        Icons.cancel,
      );

      setState(() {
        _recordingDuration = Duration.zero;
      });
    } catch (e) {
      _stopRecordingUI();
      _showError('خطأ في إلغاء التسجيل: ${e.toString()}');
    }
  }

  void _stopRecordingUI() {
    _timer?.cancel();
    _timer = null;
    _amplitudeTimer?.cancel(); // ✅ NEW
    _amplitudeTimer = null;

    setState(() {
      _isRecording = false;
      _amplitude = 0.0; // ✅ Reset amplitude
    });
  }

  void _startTimer() {
    _timer?.cancel();
    DateTime startTime = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final elapsed = DateTime.now().difference(startTime);
      setState(() {
        _recordingDuration = elapsed;
      });

      if (_recordingDuration.inMinutes >= 5) {
        _stopRecording();
        _showSnackBar(
          '⏰ تم الوصول للحد الأقصى للتسجيل (5 دقائق)',
          Colors.blue,
          Icons.timer,
        );
      }
    });
  }

  void _showRecordingInstructions() {
    if (!_hasPermission) {
      _checkPermissions();
      return;
    }
    _showSnackBar(
      'اضغط مطولاً لتسجيل رسالة صوتية',
      Colors.blue,
      Icons.info_outline,
    );
  }

  void _showError(String message) {
    _showSnackBar(message, Colors.red, Icons.error);
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: message.contains('✅') ? 2 : 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
