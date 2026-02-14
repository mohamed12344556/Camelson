import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:audio_waveforms/audio_waveforms.dart';
import 'dart:async';
import '../../../../core/core.dart';

class EnhancedVoicePlayer extends StatefulWidget {
  final String audioUrl;
  final Duration duration;
  final bool isCurrentUser;
  final VoidCallback? onPlaybackComplete;

  const EnhancedVoicePlayer({
    super.key,
    required this.audioUrl,
    required this.duration,
    this.isCurrentUser = false,
    this.onPlaybackComplete,
  });

  @override
  State<EnhancedVoicePlayer> createState() => _EnhancedVoicePlayerState();
}

class _EnhancedVoicePlayerState extends State<EnhancedVoicePlayer> {
  final ap.AudioPlayer _audioPlayer = ap.AudioPlayer();
  final PlayerController _waveformController = PlayerController();

  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _playbackSpeed = 1.0;

  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _stateSubscription;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    setState(() => _isLoading = true);

    try {
      // Set audio source
      await _audioPlayer.setSourceUrl(widget.audioUrl);

      // Listen to position changes
      _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
        setState(() => _currentPosition = position);
      });

      // Listen to duration changes
      _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
        setState(() => _totalDuration = duration);
      });

      // Listen to player state
      _stateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
        if (state == ap.PlayerState.completed) {
          setState(() {
            _isPlaying = false;
            _currentPosition = Duration.zero;
          });
          widget.onPlaybackComplete?.call();
        }
      });

      // Prepare waveform controller
      await _waveformController.preparePlayer(
        path: widget.audioUrl,
        noOfSamples: 100,
      );

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error initializing audio player: $e');
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      await _waveformController.pausePlayer();
    } else {
      await _audioPlayer.resume();
      await _waveformController.startPlayer();
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  void _changePlaybackSpeed() {
    setState(() {
      if (_playbackSpeed == 1.0) {
        _playbackSpeed = 1.5;
      } else if (_playbackSpeed == 1.5) {
        _playbackSpeed = 2.0;
      } else {
        _playbackSpeed = 1.0;
      }
    });
    _audioPlayer.setPlaybackRate(_playbackSpeed);
  }

  Future<void> _seekTo(Duration position) async {
    await _audioPlayer.seek(position);
    setState(() => _currentPosition = position);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _waveformController.dispose();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _stateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.isCurrentUser
        ? context.colors.primary.withOpacity(0.1)
        : context.colors.surfaceContainerHighest;

    final iconColor = widget.isCurrentUser
        ? context.colors.primary
        : context.colors.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isCurrentUser
              ? context.colors.primary.withOpacity(0.3)
              : context.colors.outlineVariant,
        ),
      ),
      child: _isLoading
          ? _buildLoadingState(iconColor)
          : _buildPlayerUI(iconColor),
    );
  }

  Widget _buildLoadingState(Color iconColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(iconColor),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Loading...',
          style: context.textTheme.bodyMedium?.copyWith(color: iconColor),
        ),
      ],
    );
  }

  Widget _buildPlayerUI(Color iconColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Play/Pause Button
        InkWell(
          onTap: _togglePlayPause,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: iconColor,
              size: 24,
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Waveform and Progress
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Waveform
              SizedBox(
                height: 40,
                child: AudioFileWaveforms(
                  size: Size(MediaQuery.of(context).size.width * 0.5, 40),
                  playerController: _waveformController,
                  waveformType: WaveformType.fitWidth,
                  playerWaveStyle: PlayerWaveStyle(
                    fixedWaveColor: iconColor.withOpacity(0.3),
                    liveWaveColor: iconColor,
                    spacing: 4,
                    scaleFactor: 50,
                    showSeekLine: false,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Time and Speed
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Current Time / Total Duration
                  Text(
                    '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: iconColor.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),

                  // Playback Speed Button
                  InkWell(
                    onTap: _changePlaybackSpeed,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_playbackSpeed}x',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: iconColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
