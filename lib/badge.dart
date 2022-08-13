import 'package:arabella/assets/models/providers/celebrate_provider.dart';
import 'package:arabella/assets/models/providers/chapters_provider.dart';
import 'package:arabella/assets/models/providers/confetti_provider.dart';
import 'package:arabella/assets/models/providers/covered_material_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'assets/components/fullscreen_widget.dart';

class Badge extends StatefulWidget {
  const Badge({Key? key}) : super(key: key);

  @override
  State<Badge> createState() => _BadgeState();
}

class _BadgeState extends State<Badge> {
  late CoveredMaterialProvider coveredMaterialProvider;
  late ConfettiProvider confettiProvider;

  @override
  void initState() {
    super.initState();
    coveredMaterialProvider = context.read<CoveredMaterialProvider>();
    confettiProvider = context.read<ConfettiProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<CelebrateProvider>().isCelebrating) {
        confettiProvider.play(shouldLoop: true);
      }
    });
  }

  @override
  void dispose() {
    if (coveredMaterialProvider.isEligibleForCompletionBadge()) {
      confettiProvider.stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          return Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
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
                    child: ListTile(
                      minVerticalPadding: 10,
                      leading: Hero(
                        tag: 'badge $i',
                        child: getBadgeIcon(key, eligibleBadges[key]!),
                      ),
                      title: getBadgeTitle(key, eligibleBadges[key]!),
                      subtitle: (eligibleBadges[key]!)
                          ? const Text('\n')
                          : const Text('badges.complete_to_unlock').tr(),
                    ),
                  );
                },
              ),
              if (coveredMaterial.isEligibleForCompletionBadge()) ...[
                const Divider(),
                getCompletionBadge(),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget getBadgeIcon(String chapterName, bool isEligible) {
    if (isEligible) {
      return Image.asset('assets/images/badges/$chapterName.png');
    } else {
      return Image.asset('assets/images/badges/locked.png');
    }
  }

  Widget getBadgeTitle(String chapterName, bool isEligible) {
    String text = '';
    if (context.locale.toString() == 'en') {
      text =
          '${ChaptersProvider.getChapterTranslatableName(chapterName).tr()} ${'badges.fundamentals'.tr()}';
    } else {
      text =
          '${'badges.fundamentals'.tr()} ${ChaptersProvider.getChapterTranslatableName(chapterName).tr()}';
    }

    return Text(text);
  }

  Widget getCompletionBadge() {
    return FullScreenWidget(
      opacity: 0.8,
      padding: const EdgeInsets.all(20),
      fullScreenWidget: Hero(
        tag: 'completion badge',
        child: Image.asset('assets/images/badges/completion.png'),
      ),
      child: ListTile(
        minVerticalPadding: 10,
        leading: Hero(
          tag: 'completion badge',
          child: Image.asset('assets/images/badges/completion.png'),
        ),
        title: const Text('badges.completion').tr(),
        subtitle: const Text('\n'),
      ),
    );
  }
}
