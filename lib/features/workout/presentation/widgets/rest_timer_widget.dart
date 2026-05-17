import 'dart:async';
import 'package:flutter/material.dart';

class RestTimerWidget extends StatefulWidget {
  final int defaultRestSeconds;
  final VoidCallback? onTimerComplete;

  const RestTimerWidget({
    super.key,
    required this.defaultRestSeconds,
    this.onTimerComplete,
  });

  @override
  State<RestTimerWidget> createState() => RestTimerWidgetState();
}

class RestTimerWidgetState extends State<RestTimerWidget> {
  int _remainingSeconds = 0;
  bool _isRunning = false;
  Timer? _timer;
  int _currentTotalSeconds = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void start(int seconds) {
    _timer?.cancel();
    setState(() {
      _currentTotalSeconds = seconds;
      _remainingSeconds = seconds;
      _isRunning = seconds > 0;
    });

    if (_isRunning) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
        } else {
          _timer?.cancel();
          setState(() {
            _isRunning = false;
          });
          widget.onTimerComplete?.call();
        }
      });
    }
  }

  void _onTap() {
    // Manually restart or stop
    if (_isRunning) {
      _timer?.cancel();
      setState(() {
        _isRunning = false;
      });
    } else {
      start(_currentTotalSeconds > 0 ? _currentTotalSeconds : widget.defaultRestSeconds);
    }
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_currentTotalSeconds == 0 && !_isRunning && widget.defaultRestSeconds == 0) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isComplete = !_isRunning && _remainingSeconds == 0 && _currentTotalSeconds > 0;

    double progress = 1.0;
    if (_currentTotalSeconds > 0) {
      progress = _remainingSeconds / _currentTotalSeconds;
    }

    return GestureDetector(
      onTap: _onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: isComplete 
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: _isRunning ? progress : 1.0,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    color: isComplete ? theme.colorScheme.primary : theme.colorScheme.primary,
                    strokeWidth: 4,
                  ),
                  Center(
                    child: Icon(
                      isComplete ? Icons.check : Icons.timer,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isRunning
                        ? 'Resting...'
                        : (isComplete ? 'Rest Complete' : 'Ready'),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isRunning
                        ? _formatTime(_remainingSeconds)
                        : (isComplete ? 'Tap to restart' : 'Tap to start rest'),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
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
}
