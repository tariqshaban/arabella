import 'dart:convert';
import 'dart:math';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key, required this.context}) : super(key: key);

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (notification) {
            notification.disallowIndicator();
            return true;
          },
          child: ListView(
            children: <Widget>[
              _header(this.context),
              _themeSwitch(this.context),
              _languageDropdown(this.context),
              const Divider(),
              _badge(this.context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return FutureBuilder(
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          String backgroundImage = snapshot.data as String;
          String imageText = 'nav_drawer.drawer_background.'
                  '${backgroundImage.substring(backgroundImage.lastIndexOf("/") + 1, backgroundImage.lastIndexOf("."))}'
                  '.name'
              .tr();
          String imageDescription = 'nav_drawer.drawer_background.'
                  '${backgroundImage.substring(backgroundImage.lastIndexOf("/") + 1, backgroundImage.lastIndexOf("."))}'
                  '.description'
              .tr();
          return UserAccountsDrawerHeader(
              accountName: Text(imageText),
              accountEmail: Text(imageDescription),
              otherAccountsPictures: const [
                CircleAvatar(
                  backgroundImage:
                      AssetImage('assets/images/drawer_circular/just.png'),
                  backgroundColor: Colors.transparent,
                ),
                CircleAvatar(
                  backgroundImage:
                      AssetImage('assets/images/drawer_circular/ministry.png'),
                  backgroundColor: Colors.transparent,
                ),
                CircleAvatar(
                  backgroundImage:
                      AssetImage('assets/images/drawer_circular/irbid.png'),
                  backgroundColor: Colors.transparent,
                ),
              ],
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                image: DecorationImage(
                  image: AssetImage(backgroundImage),
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.2), BlendMode.darken),
                  fit: BoxFit.cover,
                ),
              ));
        }
        return const SizedBox();
      },
      future: getRandomBackgroundImage(),
    );
  }

  Widget _themeSwitch(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.format_color_fill),
      title: const Text('nav_drawer.dark_theme').tr(),
      trailing: FutureBuilder(
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            AdaptiveThemeMode themeMode = snapshot.data as AdaptiveThemeMode;
            return Switch(
              activeColor: Theme.of(context).colorScheme.primary,
              value: themeMode == AdaptiveThemeMode.dark,
              onChanged: (bool value) {
                _changeTheme(context);
              },
            );
          }
          return const SizedBox();
        },
        future: AdaptiveTheme.getThemeMode(),
      ),
      onTap: () {
        _changeTheme(context);
      },
    );
  }

  Widget _languageDropdown(BuildContext context) {
    final GlobalKey dropdownKey = GlobalKey();
    return ListTile(
      leading: const Icon(Icons.language),
      title: const Text('nav_drawer.language').tr(),
      trailing: Padding(
        padding: const EdgeInsetsDirectional.only(end: 5),
        child: DropdownButton<String>(
          key: dropdownKey,
          iconEnabledColor: Theme.of(context).colorScheme.primary,
          underline: const SizedBox(),
          items: <String>['English', 'العربية'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {
            if (value == 'English') {
              context.setLocale(const Locale('en'));
              Navigator.pop(context, 'en');
            } else {
              context.setLocale(const Locale('ar'));
              Navigator.pop(context, 'ar');
            }
          },
        ),
      ),
      onTap: () {
        _openDropdown(dropdownKey);
      },
    );
  }

  Widget _badge(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.military_tech),
      title: const Text('nav_drawer.badge').tr(),
      onTap: () {
        Navigator.popAndPushNamed(context, '/badge');
      },
    );
  }

  void _openDropdown(GlobalKey dropdownKey) {
    GestureDetector? detector;
    void searchForGestureDetector(BuildContext? element) {
      element!.visitChildElements((element) {
        if (element.widget is GestureDetector) {
          detector = element.widget as GestureDetector?;
          return;
        } else {
          searchForGestureDetector(element);
        }
        return;
      });
    }

    searchForGestureDetector(dropdownKey.currentContext);
    assert(detector != null);

    detector!.onTap!();
  }

  static _changeTheme(BuildContext context) async {
    final navigator = Navigator.of(context);
    if (await AdaptiveTheme.getThemeMode() == AdaptiveThemeMode.light) {
      AdaptiveTheme.of(context).setDark();
    } else {
      AdaptiveTheme.of(context).setLight();
    }
    navigator.pop();
  }

  getRandomBackgroundImage() async {
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final images = json
        .decode(manifestJson)
        .keys
        .where(
            (String key) => key.startsWith('assets/images/drawer_background/'))
        .toList();
    final randomImageIndex = Random().nextInt(images.length);
    return images[randomImageIndex];
  }
}
