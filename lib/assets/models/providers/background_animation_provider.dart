import 'package:flutter/material.dart';

class BackgroundAnimationProvider with ChangeNotifier {
  bool _isVisible = true;
  double _height = MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height;
  double _bottomRadius = 0;

  bool get isVisible => _isVisible;

  double get height => _height;

  double get bottomRadius => _bottomRadius;

  set isVisible(bool value) {
    _isVisible = value;
    notifyListeners();
  }

  set height(double value) {
    _height = value;
    notifyListeners();
  }

  set bottomRadius(double value) {
    _bottomRadius = value;
    notifyListeners();
  }

  changeBackgroundAttributes(double height, double bottomRadius) {
    _height = height;
    _bottomRadius = bottomRadius;
    notifyListeners();
  }
}
