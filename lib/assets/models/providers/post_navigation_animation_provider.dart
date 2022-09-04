import 'package:flutter/material.dart';

class PostNavigationAnimationProvider with ChangeNotifier {
  bool _animate = false;

  bool get animate => _animate;

  set animate(bool value) {
    _animate = true;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 20), () {
      _animate = false;
    });
  }
}
