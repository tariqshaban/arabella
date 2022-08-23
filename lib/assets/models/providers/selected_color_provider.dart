import 'package:flutter/material.dart';

class SelectedColorProvider with ChangeNotifier {
  Color _selectedColor = const Color(0xFF29B6F6);

  Color get selectedColor => _selectedColor;

  set selectedColor(Color value) {
    _selectedColor = value;
    notifyListeners();
  }

  bool isColorBright() {
    double grayscalePercent = ((0.299 * _selectedColor.red) +
            (0.587 * _selectedColor.green) +
            (0.114 * _selectedColor.blue)) /
        255;
    return grayscalePercent > 0.7;
  }

  bool isColorDark() {
    double grayscalePercent = ((0.299 * _selectedColor.red) +
            (0.587 * _selectedColor.green) +
            (0.114 * _selectedColor.blue)) /
        255;
    return grayscalePercent < 0.3;
  }
}
