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

extension BuildContextThemeExtension on BuildContext {
  BaseColors get baseColors => Theme.of(this).extension<BaseColors>()!;
  PlayerColors get playerColors => Theme.of(this).extension<PlayerColors>()!;
  FormColors get formColors => Theme.of(this).extension<FormColors>()!;
  CourtColors get courtColors => Theme.of(this).extension<CourtColors>()!;
  DialogColors get dialogColors => Theme.of(this).extension<DialogColors>()!;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}
