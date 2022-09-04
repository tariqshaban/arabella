import 'dart:typed_data';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'maps_icon_provider.dart';

class ThemeProvider with ChangeNotifier {
  Color _color = const Color(0xFF43A047);

  late ThemeData _lightThemeData;

  late ThemeData _darkThemeData;

  ThemeProvider() {
    _loadPersistentSate();
    _initializeThemeData();
    notifyListeners();
  }

  void initialize(BuildContext context) {
    _initializeThemeData();
    _setTheme(context);
    _applyMapMarkerColor(context);
  }

  void _initializeThemeData() {
    _lightThemeData = ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Color(0xFFFAFAFA),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: _color,
        primary: _color,
        brightness: Brightness.light,
      ),
      listTileTheme: ListTileThemeData(iconColor: _color),
      radioTheme: RadioThemeData(
          fillColor: MaterialStateProperty.all<Color>(_color.withOpacity(0.8))),
      checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.all<Color>(_color.withOpacity(0.8))),
    );

    _darkThemeData = ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Color(0xFF303030),
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: _color,
        primary: _color,
        brightness: Brightness.dark,
      ),
      listTileTheme: ListTileThemeData(iconColor: _color),
      radioTheme: RadioThemeData(
          fillColor: MaterialStateProperty.all<Color>(_color.withOpacity(0.8))),
      checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.all<Color>(_color.withOpacity(0.8))),
    );
  }

  Future<void> _loadPersistentSate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('selectedColor')) {
      _color = Color(prefs.getInt('selectedColor')!);
    }
  }

  Future<void> _savePersistentSate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('selectedColor', _color.value);
  }

  Color get color => _color;

  void setColor(BuildContext context, Color value) {
    _color = value;
    _savePersistentSate();
    _initializeThemeData();
    _setTheme(context);
    _applyMapMarkerColor(context);
    notifyListeners();
  }

  ThemeData get lightThemeData => _lightThemeData;

  ThemeData get darkThemeData => _darkThemeData;

  set lightThemeData(ThemeData value) {
    _lightThemeData = value;
    notifyListeners();
  }

  set darkThemeData(ThemeData value) {
    _darkThemeData = value;
    notifyListeners();
  }

  void _setTheme(BuildContext context) {
    AdaptiveTheme.of(context).setTheme(
      light: _lightThemeData,
      dark: _darkThemeData,
    );
  }

  Future<void> _applyMapMarkerColor(BuildContext context) async {
    MapsIconProvider mapsIcon = context.read<MapsIconProvider>();
    MediaQueryData mediaQueryData = MediaQuery.of(context);

    mapsIcon.iconLight = BitmapDescriptor.fromBytes(
      await _getBytesFromAsset(
        'assets/images/markers/marker_light.png',
        (mediaQueryData.devicePixelRatio * 25).round(),
        Colors.green,
        _color,
      ),
    );

    mapsIcon.iconDark = BitmapDescriptor.fromBytes(
      await _getBytesFromAsset(
        'assets/images/markers/marker_dark.png',
        (mediaQueryData.devicePixelRatio * 25).round(),
        Colors.green,
        _color,
      ),
    );
  }

  static img.Image _decodePng(Uint8List int8List) {
    return img.decodePng(int8List)!;
  }

  static List<int> _encodePng(img.Image image) {
    return img.encodePng(image);
  }

  static Future<Uint8List> _getBytesFromAsset(
      String path, int width, Color fromColor, Color toColor) async {
    ByteData byteData = await rootBundle.load(path);
    Uint8List int8List = byteData.buffer.asUint8List();

    img.Image outputImage = await compute(_decodePng, int8List);

    final pixels = outputImage.getBytes(format: img.Format.rgba);

    final int length = pixels.lengthInBytes;

    for (var i = 0; i < length; i += 4) {
      if (pixels[i] == fromColor.red &&
          pixels[i + 1] == fromColor.green &&
          pixels[i + 2] == fromColor.blue) {
        pixels[i] = toColor.red;
        pixels[i + 1] = toColor.green;
        pixels[i + 2] = toColor.blue;
      }
    }

    outputImage = img.copyResize(outputImage, width: width);

    return Uint8List.fromList(await compute(_encodePng, outputImage));
  }
}
