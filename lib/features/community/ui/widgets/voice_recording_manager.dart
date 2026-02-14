import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class VoiceRecordingManager {
  static final _instance = VoiceRecordingManager._internal();
  factory VoiceRecordingManager() => _instance;
  VoiceRecordingManager._internal();

  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String? _currentRecordingPath;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;

  // Stream controllers for UI updates
  final _recordingStateController = StreamController<bool>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();

  Stream<bool> get recordingStateStream => _recordingStateController.stream;
  Stream<Duration> get durationStream => _durationController.stream;

  bool get isRecording => _isRecording;
  Duration get recordingDuration => _recordingDuration;

  Future<bool> requestPermission() async {
    final permission = await Permission.microphone.request();
    return permission == PermissionStatus.granted;
  }

  Future<String?> startRecording() async {
    try {
      // Check permission
      if (!await requestPermission()) {
        throw Exception('Microphone permission denied');
      }

      // Stop any existing recording
      if (_isRecording) {
        await stopRecording();
      }

      // Create file path - استخدم external storage للتأكد
      final directory =
          await getExternalStorageDirectory() ?? await getTemporaryDirectory();
      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _currentRecordingPath = '${directory.path}/$fileName';

      print('🎤 Recording to: $_currentRecordingPath'); // للتجربة

      // Start recording with better config
      await _recorder.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
          numChannels: 1, // Mono for smaller file size
        ),
        path: _currentRecordingPath!,
      );

      _isRecording = true;
      _recordingDuration = Duration.zero;
      _recordingStateController.add(true);

      // Start timer
      _startTimer();

      return _currentRecordingPath;
    } catch (e) {
      print('❌ Recording error: $e'); // للتجربة
      _isRecording = false;
      _recordingStateController.add(false);
      rethrow;
    }
  }

  Future<String?> stopRecording() async {
    try {
      if (!_isRecording) return null;

      final path = await _recorder.stop();
      _stopTimer();

      _isRecording = false;
      _recordingStateController.add(false);

      // Check minimum duration (1 second)
      if (_recordingDuration.inSeconds < 1) {
        // Delete short recording
        if (path != null && await File(path).exists()) {
          await File(path).delete();
        }
        throw Exception('Recording too short (minimum 1 second)');
      }

      return path;
    } catch (e) {
      _isRecording = false;
      _recordingStateController.add(false);
      rethrow;
    }
  }

  Future<void> cancelRecording() async {
    try {
      if (_isRecording) {
        await _recorder.stop();
        _stopTimer();

        // Delete the recording file
        if (_currentRecordingPath != null &&
            await File(_currentRecordingPath!).exists()) {
          await File(_currentRecordingPath!).delete();
        }
      }

      _isRecording = false;
      _recordingDuration = Duration.zero;
      _recordingStateController.add(false);
      _durationController.add(Duration.zero);
    } catch (e) {
      print('Error canceling recording: $e');
    }
  }

  void _startTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _recordingDuration = Duration(seconds: timer.tick);
      _durationController.add(_recordingDuration);

      // Auto-stop after 5 minutes
      if (_recordingDuration.inMinutes >= 5) {
        stopRecording();
      }
    });
  }

  void _stopTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  void dispose() {
    _recordingTimer?.cancel();
    _recordingStateController.close();
    _durationController.close();
    _recorder.dispose();
  }
}
