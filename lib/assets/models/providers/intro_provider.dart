import 'package:flutter/material.dart';

class IntroProvider with ChangeNotifier {
  bool _shouldShowIntro = false;

  bool get shouldShowIntro => _shouldShowIntro;

  set shouldShowIntro(bool value) {
    _shouldShowIntro = value;
    notifyListeners();
  }
}
