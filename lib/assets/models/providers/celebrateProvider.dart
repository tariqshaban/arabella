import 'package:flutter/cupertino.dart';

class CelebrateProvider with ChangeNotifier {
  bool _isCelebrating = false;

  bool get isCelebrating => _isCelebrating;

  set isCelebrating(bool value) {
    _isCelebrating = value;
    notifyListeners();
  }
}
