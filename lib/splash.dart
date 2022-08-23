import 'dart:convert';
import 'dart:math';

import 'package:animated_background/animated_background.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'assets/models/providers/background_animation_provider.dart';
import 'assets/models/providers/theme_provider.dart';

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
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
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
                  options: ParticleOptions(
                    particleCount: 100,
                    minOpacity: 0.1,
                    maxOpacity: 0.2,
                    spawnMinSpeed: 5,
                    spawnMaxSpeed: 10,
                    baseColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .computeLuminance() >
                            0.5
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
                vsync: this,
                child: Padding(
                  padding: const EdgeInsets.all(50),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 750),
                    style: TextStyle(
                        color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .computeLuminance() >
                                0.5
                            ? Colors.black
                            : Colors.white),
                    child: Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: min(MediaQuery.of(context).size.width / 2, 250),
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: const Text(
                            'app_name',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ).tr(),
                        ),
                      ),
                    ),
                  ),
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

  Future<void> changeTheme(BuildContext context) async {
    context.read<ThemeProvider>().initialize(context);
  }

  void initializeApplication(BuildContext context) async {
    precacheImages(context);
    Future.delayed(const Duration(milliseconds: 1500), () {
      changeTheme(context);
    });

    Future.delayed(const Duration(milliseconds: 3000), () {
      context.read<BackgroundAnimationProvider>().isVisible = false;
    });

    Future.delayed(const Duration(milliseconds: 3500), () {
      Navigator.pop(context);
    });
  }
}
