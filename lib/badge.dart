import 'dart:io';
import 'dart:math';

import 'package:animated_background/animated_background.dart';
import 'package:arabella/assets/helpers/dynamic_tr.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'assets/components/custom/fullscreen_widget.dart';
import 'assets/helpers/shader_callback_helper.dart';
import 'assets/models/providers/assets_provider.dart';
import 'assets/models/providers/background_animation_provider.dart';
import 'assets/models/providers/celebrate_provider.dart';
import 'assets/models/providers/chapters_provider.dart';
import 'assets/models/providers/confetti_provider.dart';
import 'assets/models/providers/covered_material_provider.dart';

class Badge extends StatefulWidget {
  const Badge({Key? key}) : super(key: key);

  @override
  State<Badge> createState() => _BadgeState();
}

class _BadgeState extends State<Badge> with TickerProviderStateMixin {
  late CoveredMaterialProvider coveredMaterialProvider;
  late ConfettiProvider confettiProvider;
  late BackgroundAnimationProvider backgroundAnimationProvider;
  late MediaQueryData mediaQueryData;
  late String applicationDocumentsDirectory;

  @override
  void initState() {
    super.initState();
    coveredMaterialProvider = context.read<CoveredMaterialProvider>();
    confettiProvider = context.read<ConfettiProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<CelebrateProvider>().isCelebrating) {
        confettiProvider.play(shouldLoop: true);
      }

      backgroundAnimationProvider = context.read<BackgroundAnimationProvider>();
      mediaQueryData = MediaQuery.of(context);
      backgroundAnimationProvider.changeBackgroundAttributes(
          max(mediaQueryData.size.height * 0.6, 500), 120);
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (coveredMaterialProvider.isEligibleForCompletionBadge()) {
      confettiProvider.stop();
    }

    Future.delayed(const Duration(milliseconds: 0), () {
      backgroundAnimationProvider.changeBackgroundAttributes(
          max(mediaQueryData.size.height * 0.2, 150), 40);
    });
  }

  @override
  Widget build(BuildContext context) {
    applicationDocumentsDirectory =
        context.read<AssetsProvider>().applicationDocumentsDirectory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('badges.badges').tr(),
        actions: <Widget>[
          Consumer<CelebrateProvider>(
            builder: (context, celebrate, child) {
              if (!coveredMaterialProvider.isEligibleForCompletionBadge()) {
                return const SizedBox();
              }

              return IconButton(
                tooltip: 'badges.celebrate'.tr(),
                icon: Icon(
                  celebrate.isCelebrating
                      ? Icons.celebration
                      : Icons.celebration_outlined,
                ),
                onPressed: () {
                  celebrate.isCelebrating = !celebrate.isCelebrating;
                  if (celebrate.isCelebrating) {
                    confettiProvider.play(shouldLoop: true);
                  } else {
                    confettiProvider.stop();
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<CoveredMaterialProvider>(
        builder: (context, coveredMaterial, child) {
          Map<String, bool> eligibleBadges =
              coveredMaterial.getEligibleBadges();
          return ShaderMask(
            shaderCallback: ShaderCallbackHelper.getShaderCallback(),
            blendMode: BlendMode.dstOut,
            child: ListView(
              padding: EdgeInsetsDirectional.fromSTEB(
                5,
                context.read<BackgroundAnimationProvider>().height / 2,
                5,
                0,
              ),
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: eligibleBadges.length,
                  itemBuilder: (context, i) {
                    String key = eligibleBadges.keys.elementAt(i);
                    return FullScreenWidget(
                      opacity: 0.8,
                      padding: const EdgeInsets.all(20),
                      enabled: eligibleBadges[key]!,
                      fullScreenWidget: Hero(
                        tag: 'badge $i',
                        child: getBadgeIcon(key, eligibleBadges[key]!),
                      ),
                      child: SizedBox(
                        height: 75,
                        child: Center(
                          child: ListTile(
                            leading: Hero(
                              tag: 'badge $i',
                              child: getBadgeIcon(key, eligibleBadges[key]!),
                            ),
                            title: getBadgeTitle(key, eligibleBadges[key]!),
                            subtitle: (eligibleBadges[key]!)
                                ? null
                                : const Text('badges.complete_to_unlock').tr(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (coveredMaterial.isEligibleForCompletionBadge()) ...[
                  const Divider(),
                  getCompletionBadge(),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget getBadgeIcon(String chapterName, bool isEligible) {
    if (isEligible) {
      return Image.file(File(
          '$applicationDocumentsDirectory/assets/images/badges/$chapterName.png'));
    } else {
      return Image.file(File(
          '$applicationDocumentsDirectory/assets/images/badges/locked.png'));
    }
  }

  Widget getBadgeTitle(String chapterName, bool isEligible) {
    String text = '';
    if (context.locale.toString() == 'en') {
      text =
          '${ChaptersProvider.getChapterTranslatableName(chapterName).dtr(context)} ${'badges.fundamentals'.tr()}';
    } else {
      text =
          '${'badges.fundamentals'.tr()} ${ChaptersProvider.getChapterTranslatableName(chapterName).dtr(context)}';
    }

    return Text(text);
  }

  Widget getCompletionBadge() {
    return FullScreenWidget(
      opacity: 0.8,
      padding: const EdgeInsets.all(20),
      fullScreenWidget: Hero(
        tag: 'completion badge',
        child: Image.file(File(
            '$applicationDocumentsDirectory/assets/images/badges/completion.png')),
      ),
      child: Container(
        color: Colors.yellow.withOpacity(0.1),
        height: 75,
        child: AnimatedBackground(
          behaviour: RacingLinesBehaviour(
            numLines: 5,
          ),
          vsync: this,
          child: Center(
            child: ListTile(
              leading: Hero(
                tag: 'completion badge',
                child: Image.asset('assets/images/badges/completion.png'),
              ),
              title: const Text('badges.completion').tr(),
            ),
          ),
        ),
      ),
    );
  }
}
