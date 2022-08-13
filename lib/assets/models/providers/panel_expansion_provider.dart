import 'package:flutter/material.dart';

class PanelExpansionProvider with ChangeNotifier {
  final Map<String, bool> _isExpanded = {};

  Map<String, bool> get isExpanded => _isExpanded;

  void setExpanded(String key, bool value) {
    _isExpanded[key] = value;
    notifyListeners();
  }
}
