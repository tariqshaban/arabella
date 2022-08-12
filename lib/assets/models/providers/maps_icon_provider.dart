import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsIconProvider with ChangeNotifier {
  late BitmapDescriptor _icon;

  BitmapDescriptor get icon => _icon;

  set icon(BitmapDescriptor value) {
    _icon = value;
    notifyListeners();
  }
}
