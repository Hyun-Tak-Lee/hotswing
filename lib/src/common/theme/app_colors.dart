import 'package:flutter/material.dart';
import 'types/base_colors.dart';
import 'types/player_colors.dart';
import 'types/form_colors.dart';
import 'types/court_colors.dart';
import 'types/dialog_colors.dart';

export 'types/base_colors.dart';
export 'types/player_colors.dart';
export 'types/form_colors.dart';
export 'types/court_colors.dart';
export 'types/dialog_colors.dart';

/// 테마 색상 확장을 [BuildContext]를 통해 간편하게 접근할 수 있도록 돕는 익스텐션.
extension BuildContextThemeExtension on BuildContext {
  /// 기본 색상 테마.
  BaseColors get baseColors => Theme.of(this).extension<BaseColors>()!;

  /// 플레이어 관련 색상 테마.
  PlayerColors get playerColors => Theme.of(this).extension<PlayerColors>()!;

  /// 폼 관련 색상 테마.
  FormColors get formColors => Theme.of(this).extension<FormColors>()!;

  /// 코트 관련 색상 테마.
  CourtColors get courtColors => Theme.of(this).extension<CourtColors>()!;

  /// 다이얼로그 관련 색상 테마.
  DialogColors get dialogColors => Theme.of(this).extension<DialogColors>()!;

  /// 머티리얼 [ColorScheme].
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}
