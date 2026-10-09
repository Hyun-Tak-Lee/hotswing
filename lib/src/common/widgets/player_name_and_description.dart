import 'package:flutter/material.dart';

/// 플레이어 이름과 설명(description)을 표시하는 위젯.
///
/// 가로 너비가 충분하면 한 줄에 나란히 배치하고,
/// 너비가 부족하여 한 줄에 다 들어가지 않으면 이름과 설명을 각각 별도의 줄로 자동 개행합니다.
class PlayerNameAndDescription extends StatelessWidget {
  const PlayerNameAndDescription({
    super.key,
    required this.name,
    required this.description,
    required this.nameFontSize,
    required this.descFontSize,
    required this.nameColor,
    required this.descColor,
  });

  final String name;
  final String description;
  final double nameFontSize;
  final double descFontSize;
  final Color nameColor;
  final Color descColor;

  @override
  Widget build(BuildContext context) {
    if (description.isEmpty) {
      return Text(
        name,
        style: TextStyle(
          fontSize: nameFontSize,
          fontWeight: FontWeight.bold,
          color: nameColor,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final nameStyle = TextStyle(
          fontSize: nameFontSize,
          fontWeight: FontWeight.bold,
          color: nameColor,
        );
        final descStyle = TextStyle(
          fontSize: descFontSize,
          fontWeight: FontWeight.w500,
          color: descColor,
        );

        final textDirection = Directionality.of(context);
        final namePainter = TextPainter(
          text: TextSpan(text: name, style: nameStyle),
          textDirection: textDirection,
          maxLines: 1,
        )..layout();

        final descPainter = TextPainter(
          text: TextSpan(text: ' $description', style: descStyle),
          textDirection: textDirection,
          maxLines: 1,
        )..layout();

        final totalWidth = namePainter.width + descPainter.width;
        final isOverflow = totalWidth > constraints.maxWidth;

        if (!isOverflow) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name, style: nameStyle),
              const SizedBox(width: 6),
              Text(description, style: descStyle),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: nameStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: descStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }
}
