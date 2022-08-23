import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsIconProvider with ChangeNotifier {
  late BitmapDescriptor _iconLight;
  late BitmapDescriptor _iconDark;

  BitmapDescriptor get iconLight => _iconLight;

  BitmapDescriptor get iconDark => _iconDark;

  set iconLight(BitmapDescriptor value) {
    _iconLight = value;
    notifyListeners();
  }

  set iconDark(BitmapDescriptor value) {
    _iconDark = value;
    notifyListeners();
  }
}
