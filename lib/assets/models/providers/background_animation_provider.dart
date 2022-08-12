import 'package:flutter/material.dart';

class BackgroundAnimationProvider with ChangeNotifier {
  bool _isVisible = true;

  bool get isVisible => _isVisible;

  set isVisible(bool value) {
    _isVisible = value;
    notifyListeners();
  }
}
