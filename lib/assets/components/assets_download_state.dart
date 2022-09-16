import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enums/assets_state.dart';
import '../models/providers/assets_provider.dart';

class AssetsDownloadState extends StatefulWidget {
  const AssetsDownloadState({Key? key, this.onUpdateFinish}) : super(key: key);

  final Function()? onUpdateFinish;

  @override
  State<AssetsDownloadState> createState() => _AssetsDownloadStateState();
}

class _AssetsDownloadStateState extends State<AssetsDownloadState> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AssetsProvider>(
      builder: (context, assetsProvider, child) {
        return AnimatedOpacity(
          opacity: assetsProvider.assetsState != AssetsState.noUpdateRequired
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
      },
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
    } else if (assetsProvider.assetsState == AssetsState.unpacking) {
      return ListTile(
        key: Key(assetsProvider.assetsState.toString()),
        leading: const CircularProgressIndicator(),
        title: const Text(
          'splash.unpacking',
        ).tr(),
      );
    } else if (assetsProvider.assetsState == AssetsState.finishedUpdating) {
      widget.onUpdateFinish?.call();
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
      widget.onUpdateFinish?.call();
      return ListTile(
        key: Key(assetsProvider.assetsState.toString()),
      );
    }
  }
}
