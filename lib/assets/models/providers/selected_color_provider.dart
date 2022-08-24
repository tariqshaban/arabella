import 'package:arabella/assets/models/providers/theme_provider.dart';
import 'package:flutter/material.dart';

class SelectedColorProvider with ChangeNotifier {
  Color? _selectedColor;

  void update(ThemeProvider theme){
    _selectedColor??=theme.color;
  }

  Color get selectedColor => _selectedColor!;

  set selectedColor(Color value) {
    _selectedColor = value;
    notifyListeners();
  }

  bool isColorBright() {
    double grayscalePercent = ((0.299 * selectedColor.red) +
            (0.87 * selectedColor.green) +
            (0.114 * selectedColor.blue)) /
        255;
    return grayscalePercent > 0.7;
  }

  bool isColorDark() {
    double grayscalePercent = ((0.299 * selectedColor.red) +
            (0.587 * selectedColor.green) +
            (0.114 * selectedColor.blue)) /
        255;
    return grayscalePercent < 0.3;
  }
}
