import 'dart:math';

import 'package:arabella/assets/enums/assets_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'assets/components/assets_download_state.dart';
import 'assets/components/intro.dart';
import 'assets/helpers/delayed_curve.dart';
import 'assets/models/providers/assets_provider.dart';
import 'assets/models/providers/background_animation_provider.dart';
import 'assets/models/providers/intro_provider.dart';
import 'assets/models/providers/post_navigation_animation_provider.dart';
import 'assets/models/providers/theme_provider.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with WidgetsBindingObserver {
  bool _didFinalize = false;
  bool isIntroShown = false;
  late AssetsProvider assetsProvider;
  late IntroProvider introProvider;
  late Function() assetDownloadHandler;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    assetsProvider = context.read<AssetsProvider>();
    introProvider = context.read<IntroProvider>();
    assetDownloadHandler = () {
      if (assetsProvider.assetsState == AssetsState.updating && !isIntroShown) {
        isIntroShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          introProvider.shouldShowIntro = true;
        });
      }
    };

    Future.delayed(const Duration(milliseconds: 1000), () {
      assetDownloadHandler();
    });
    assetsProvider.addListener(assetDownloadHandler);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    context
        .read<BackgroundAnimationProvider>()
        .changeBackgroundAttributes(MediaQuery.of(context).size.width, 0);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    assetsProvider.removeListener(assetDownloadHandler);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: Consumer3<BackgroundAnimationProvider, IntroProvider,
            AssetsProvider>(
          builder: (context, backgroundAnimation, intro, assets, child) {
            return AnimatedOpacity(
              opacity: backgroundAnimation.isVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Align(
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    AnimatedOpacity(
                      opacity: intro.shouldShowIntro ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: Intro(
                          onDonePressed:
                              assets.assetsState == AssetsState.finishedUpdating
                                  ? finalizeSplash
                                  : null,
                        ),
                      ),
                    ),
                    AnimatedAlign(
                      alignment: intro.shouldShowIntro
                          ? Alignment.topCenter
                          : Alignment.center,
                      duration: const Duration(milliseconds: 300),
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
                                : Colors.white,
                          ),
                          child: SizedBox(
                            width: intro.shouldShowIntro
                                ? min(
                                    MediaQuery.of(context).size.width / 2, 125)
                                : min(
                                    MediaQuery.of(context).size.width / 2, 200),
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
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      bottom: intro.shouldShowIntro ? 75 : 50,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: AnimatedOpacity(
                          opacity:
                              assets.assetsState != AssetsState.finishedUpdating
                                  ? 1.0
                                  : 0.0,
                          curve: const DelayedCurve(),
                          duration: const Duration(milliseconds: 1500),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 50),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: AssetsDownloadState(
                                onUpdateFinish: () {
                                  if (!intro.shouldShowIntro) {
                                    Future.delayed(
                                        const Duration(milliseconds: 500), () {
                                      finalizeSplash();
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> changeTheme(BuildContext context) async {
    context.read<ThemeProvider>().initialize(context);
  }

  void finalizeSplash() {
    if (_didFinalize) {
      return;
    }

    _didFinalize = true;

    context.read<AssetsProvider>().precacheImages(context);

    changeTheme(context);

    Future.delayed(const Duration(milliseconds: 1500), () {
      context.read<BackgroundAnimationProvider>().isVisible = false;
    });

    Future.delayed(const Duration(milliseconds: 2000), () {
      Navigator.of(context).pop();
    });

    BackgroundAnimationProvider backgroundAnimationProvider =
        context.read<BackgroundAnimationProvider>();
    PostNavigationAnimationProvider postNavigationAnimationProvider =
        context.read<PostNavigationAnimationProvider>();
    MediaQueryData mediaQueryData = MediaQuery.of(context);

    Future.delayed(const Duration(milliseconds: 2500), () {
      backgroundAnimationProvider.changeBackgroundAttributes(
          max(mediaQueryData.size.height * 0.1, 150), 40);
      postNavigationAnimationProvider.animate = true;
    });
  }
}
