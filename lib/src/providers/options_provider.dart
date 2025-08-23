import 'package:flutter/material.dart';

class OptionsProvider with ChangeNotifier {
  bool _divideTeam = false; // Default to false
  bool get divideTeam => _divideTeam;

  void toggleDivideTeam() {
    _divideTeam = !_divideTeam;
    notifyListeners();
  }
}
