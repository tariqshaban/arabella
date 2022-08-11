import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ScrollDirectionProvider with ChangeNotifier {
  ScrollDirection _direction = ScrollDirection.idle;

  ScrollDirection get direction => _direction;

  set direction(ScrollDirection value) {
    _direction = value;
    notifyListeners();
  }
}
