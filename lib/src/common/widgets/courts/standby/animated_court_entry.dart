import 'package:flutter/material.dart';

/// 코트 카드 추가 및 삭제 시 자연스러운 크기 확장/축소(SizeTransition) 및 페이드 애니메이션을 제공하는 래퍼 위젯.
class AnimatedCourtEntry extends StatefulWidget {
  final Axis axis;
  final VoidCallback onRemove;
  final Widget Function(BuildContext context, VoidCallback startRemove) builder;

  const AnimatedCourtEntry({
    super.key,
    required this.builder,
    required this.onRemove,
    this.axis = Axis.vertical,
  });

  @override
  State<AnimatedCourtEntry> createState() => _AnimatedCourtEntryState();
}

class _AnimatedCourtEntryState extends State<AnimatedCourtEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final Animation<double> _fadeAnimation = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.15, 1.0, curve: Curves.easeIn),
  );
  late final Animation<double> _sizeAnimation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  bool _isRemoving = false;

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startRemove() {
    if (_isRemoving) return;
    _isRemoving = true;
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onRemove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRect(
        child: SizeTransition(
          sizeFactor: _sizeAnimation,
          axis: widget.axis,
          axisAlignment: -1.0,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: widget.builder(context, _startRemove),
          ),
        ),
      ),
    );
  }
}
