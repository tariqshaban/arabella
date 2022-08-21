import 'dart:convert';
import 'dart:typed_data';

import 'package:animated_background/animated_background.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';

import 'assets/models/providers/background_animation_provider.dart';
import 'assets/models/providers/maps_icon_provider.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeApplication(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Theme.of(context).colorScheme.primary,
        child: Consumer<BackgroundAnimationProvider>(
          builder: (context, backgroundAnimation, child) {
            return AnimatedOpacity(
              opacity: backgroundAnimation.isVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: AnimatedBackground(
                behaviour: RandomParticleBehaviour(
                  options: const ParticleOptions(
                    particleCount: 100,
                    minOpacity: 0.1,
                    maxOpacity: 0.2,
                    spawnMinSpeed: 5,
                    spawnMaxSpeed: 10,
                  ),
                ),
                vsync: this,
                child: Center(
                  child: const Text(
                    'app_name',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ).tr(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> precacheImages(BuildContext context) async {
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final images = json
        .decode(manifestJson)
        .keys
        .where((String key) => key.startsWith('assets/images/'))
        .toList();

    images.forEach((image) => precacheImage(AssetImage(image), context));
  }

  Future<void> precacheMapsIcon(BuildContext context) async {
    context.read<MapsIconProvider>().icon = BitmapDescriptor.fromBytes(
      await _getBytesFromAsset(
        'assets/images/markers/marker.png',
        (MediaQuery.of(context).devicePixelRatio * 25).round(),
        Theme.of(context).colorScheme.primary,
      ),
    );
  }

  static img.Image decodePng(Uint8List int8List) {
    return img.decodePng(int8List)!;
  }

  static Future<Uint8List> _getBytesFromAsset(
      String path, int width, Color color) async {
    ByteData byteData = await rootBundle.load(path);
    Uint8List int8List = byteData.buffer.asUint8List();

    img.Image outputImage = await compute(decodePng, int8List);

    img.colorOffset(
      outputImage,
      red: color.red,
      green: color.green,
      blue: color.blue,
    );

    outputImage = img.copyResize(outputImage, width: width);

    return Uint8List.fromList(img.encodePng(outputImage));
  }

  void initializeApplication(BuildContext context) async {
    precacheImages(context);
    precacheMapsIcon(context);

    Future.delayed(const Duration(milliseconds: 3000), () {
      context.read<BackgroundAnimationProvider>().isVisible = false;
    });

    Future.delayed(const Duration(milliseconds: 3500), () {
      Navigator.pop(context);
    });
  }
}
