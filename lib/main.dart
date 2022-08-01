import 'dart:convert';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:arabella/lessons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'assets/models/providers/chapters.dart';
import 'home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      fallbackLocale: const Locale('en'),
      path: 'assets/translations',
      child: const Main(),
    ),
  );
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  @override
  Widget build(BuildContext context) {
    preCacheImages(context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Chapters>(
            create: (context) => Chapters(), lazy: false),
      ],
      child: AdaptiveTheme(
        light: ThemeData(
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          primaryColor: const Color(0xFF0E8B8B),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0E8B8B),
            brightness: Brightness.light,
          ),
          listTileTheme: const ListTileThemeData(iconColor: Color(0xFF0E8B8B)),
        ),
        dark: ThemeData(
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0E8B8B),
            brightness: Brightness.dark,
          ),
          listTileTheme: const ListTileThemeData(iconColor: Color(0xFF0E8B8B)),
        ),
        initial: AdaptiveThemeMode.light,
        builder: (theme, darkTheme) {
          return MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: theme,
            darkTheme: darkTheme,
            initialRoute: '/',
            onGenerateRoute: (settings) {
              Map arguments = {};

              if (settings.arguments != null) {
                arguments = settings.arguments as Map;
              }

              switch (settings.name) {
                case '/':
                  return MaterialPageRoute(builder: (_) => const Home());
                case '/lessons':
                  return MaterialPageRoute(
                      builder: (_) => Lessons(
                            chapter: arguments['chapter'],
                            lesson: arguments['lesson'],
                          ));
              }
              return null;
            },
          );
        },
      ),
    );
  }

  preCacheImages(BuildContext context) async {
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final images = json
        .decode(manifestJson)
        .keys
        .where((String key) => key.startsWith('assets/images/'))
        .toList();

    images.forEach((image) => precacheImage(AssetImage(image), context));
  }
}
