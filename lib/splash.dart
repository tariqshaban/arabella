import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'assets/enums/assets_state.dart';
import 'assets/models/providers/assets_provider.dart';
import 'assets/models/providers/background_animation_provider.dart';
import 'assets/models/providers/post_navigation_animation_provider.dart';
import 'assets/models/providers/theme_provider.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with WidgetsBindingObserver {
  bool _didFinalize = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<BackgroundAnimationProvider>(
        builder: (context, backgroundAnimation, child) {
          return AnimatedOpacity(
            opacity: backgroundAnimation.isVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
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
                  child: Column(
                    children: [
                      Expanded(
                        child: SizedBox(
                          width:
                              min(MediaQuery.of(context).size.width / 2, 250),
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
                      Consumer<AssetsProvider>(
                          builder: (context, assetsProvider, child) {
                        return AnimatedOpacity(
                          opacity: assetsProvider.assetsState !=
                                  AssetsState.noUpdateRequired
                              ? 1.0
                              : 0,
                          duration: const Duration(milliseconds: 300),
                          child: Card(
                            elevation: 5,
                            shadowColor: Theme.of(context).colorScheme.primary,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: SizedBox(
                              height: 70,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: getAssetsDownloadState(assetsProvider),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget getAssetsDownloadState(AssetsProvider assetsProvider) {
    if (assetsProvider.assetsState == AssetsState.contacting) {
      return ListTile(
        key: Key(assetsProvider.assetsState.toString()),
        leading: const CircularProgressIndicator(),
        title: const Text(
          'splash.contacting',
        ).tr(),
      );
    } else if (assetsProvider.assetsState == AssetsState.updating) {
      return ListTile(
        key: Key(assetsProvider.assetsState.toString()),
        leading: CircularProgressIndicator(
            value: assetsProvider.received / assetsProvider.total),
        title: const Text(
          'splash.downloading',
        ).tr(),
        subtitle: Text(
            '${assetsProvider.getReceived()}/${assetsProvider.getTotal()} ${'splash.mb'.tr()}'),
      );
    } else if (assetsProvider.assetsState == AssetsState.finishedUpdating) {
      finalizeSplash();
      return ListTile(
        key: Key(assetsProvider.assetsState.toString()),
        leading: Stack(
          children: [
            const CircularProgressIndicator(value: 1),
            SizedBox(
              height: 36,
              width: 36,
              child: Icon(Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
        title: const Text(
          'splash.done',
        ).tr(),
      );
    } else if (assetsProvider.assetsState == AssetsState.failedConnecting) {
      return ListTile(
        key: Key(assetsProvider.assetsState.toString()),
        leading: Stack(
          children: [
            assetsProvider.didGiveUp
                ? const SizedBox()
                : const CircularProgressIndicator(),
            SizedBox(
              height: 36,
              width: 36,
              child: Icon(Icons.warning_amber,
                  color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
        title: const Text(
          'splash.failure',
        ).tr(),
        subtitle: Text(
          assetsProvider.didGiveUp
              ? 'splash.giving_up'.tr()
              : '${'splash.attempt'.tr()} ${assetsProvider.failureAttemptCount}',
        ),
      );
    } else if (assetsProvider.assetsState == AssetsState.failedUpdating) {
      return ListTile(
        key: Key(assetsProvider.assetsState.toString()),
        leading: SizedBox(
          height: 36,
          width: 36,
          child: Icon(Icons.warning_amber,
              color: Theme.of(context).colorScheme.primary),
        ),
        title: const Text(
          'splash.unknown_failure',
        ).tr(),
      );
    } else {
      finalizeSplash();
      return ListTile(
        key: Key(assetsProvider.assetsState.toString()),
      );
    }
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

    Future.delayed(const Duration(milliseconds: 1500), () {
      changeTheme(context);
    });

    Future.delayed(const Duration(milliseconds: 3000), () {
      context.read<BackgroundAnimationProvider>().isVisible = false;
    });

    Future.delayed(const Duration(milliseconds: 3500), () {
      Navigator.of(context).pop();
    });

    BackgroundAnimationProvider backgroundAnimationProvider =
        context.read<BackgroundAnimationProvider>();
    PostNavigationAnimationProvider postNavigationAnimationProvider =
        context.read<PostNavigationAnimationProvider>();
    MediaQueryData mediaQueryData = MediaQuery.of(context);

    Future.delayed(const Duration(milliseconds: 4000), () {
      backgroundAnimationProvider.changeBackgroundAttributes(
          max(mediaQueryData.size.height * 0.1, 150), 40);
      postNavigationAnimationProvider.animate = true;
    });
  }
}
