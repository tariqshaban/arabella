import 'package:flutter/cupertino.dart';

class ScrollOffsetProvider with ChangeNotifier {
  final Map<String, double> _scrollOffset = {};

  Map<String, double> get scrollOffset => _scrollOffset;

  void setScrollOffset(String key, double value) {
    _scrollOffset[key] = value;
    notifyListeners();
  }
}
