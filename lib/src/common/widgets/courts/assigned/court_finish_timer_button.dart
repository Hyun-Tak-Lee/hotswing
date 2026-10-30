import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:hotswing/src/common/widgets/courts/assigned/assigned_gradient_button.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:provider/provider.dart';

/// 경기 진행 중인 코트의 실시간 경과 시간과 종료(정지) 액션을 제공하는 버튼 위젯.
class CourtFinishTimerButton extends StatelessWidget {
  final int sectionIndex;
  final bool isTablet;
  final bool isLoading;
  final VoidCallback onTap;

  const CourtFinishTimerButton({
    super.key,
    required this.sectionIndex,
    required this.isTablet,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final courtColors = context.courtColors;
    final startTime = context.select<PlayersProvider, DateTime?>(
      (p) => sectionIndex < p.courtStartTimes.length
          ? p.courtStartTimes[sectionIndex]
          : null,
    );

    return AssignedGradientButton(
      width: isTablet ? 150.0 : 90.0,
      height: isTablet ? 45.0 : 30.0,
      colors: [
        courtColors.btnFinishStart,
        courtColors.btnFinishEnd,
      ],
      isLoading: isLoading,
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.stop_rounded,
            size: isTablet ? 20.0 : 14.0,
            color: Colors.white,
          ),
          const SizedBox(width: 4.0),
          _ElapsedTimeText(
            startTime: startTime,
            fontSize: isTablet ? 18.0 : 12.0,
          ),
        ],
      ),
    );
  }
}

/// 경기 시작 시각으로부터의 경과 시간을 1초 단위로 갱신하는 텍스트 위젯.
/// 매초 갱신 범위를 이 텍스트로 한정하고, 시작 시각이 없으면 타이머를 돌리지 않습니다.
class _ElapsedTimeText extends StatefulWidget {
  final DateTime? startTime;
  final double fontSize;

  const _ElapsedTimeText({required this.startTime, required this.fontSize});

  @override
  State<_ElapsedTimeText> createState() => _ElapsedTimeTextState();
}

class _ElapsedTimeTextState extends State<_ElapsedTimeText> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _syncTimer();
  }

  @override
  void didUpdateWidget(covariant _ElapsedTimeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.startTime == null) != (widget.startTime == null)) {
      _syncTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatElapsedTime(widget.startTime),
      style: TextStyle(
        fontSize: widget.fontSize,
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }

  void _syncTimer() {
    _timer?.cancel();
    _timer = null;
    if (widget.startTime == null) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  String _formatElapsedTime(DateTime? startTime) {
    if (startTime == null) return '00:00';
    final elapsedSeconds = DateTime.now().difference(startTime).inSeconds;
    if (elapsedSeconds < 0) return '00:00';

    final minutes = (elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
