import 'package:flutter/material.dart';

class StandbyGradientButton extends StatelessWidget {
  const StandbyGradientButton({
    super.key,
    required this.width,
    required this.height,
    required this.colors,
    required this.onTap,
    required this.child,
  });

  final double width;
  final double height;
  final List<Color> colors;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.last.withAlpha(80),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15.0),
          onTap: onTap,
          child: Center(child: child),
        ),
      ),
    );
  }
}
