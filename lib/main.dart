import 'dart:math';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:confetti/confetti.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'assets/models/providers/answered_questions_provider.dart';
import 'assets/models/providers/background_animation_provider.dart';
import 'assets/models/providers/celebrate_provider.dart';
import 'assets/models/providers/chapters_provider.dart';
import 'assets/models/providers/confetti_provider.dart';
import 'assets/models/providers/covered_material_provider.dart';
import 'assets/models/providers/maps_icon_provider.dart';
import 'assets/models/providers/panel_expansion_provider.dart';
import 'assets/models/providers/scroll_direction_provider.dart';
import 'badge.dart';
import 'chapter.dart';
import 'home.dart';
import 'lesson.dart';
import 'question.dart';
import 'quiz.dart';
import 'splash.dart';

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
    setNavigationBarColor();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChaptersProvider>(
            create: (context) => ChaptersProvider(), lazy: false),
        ChangeNotifierProvider<ScrollDirectionProvider>(
            create: (context) => ScrollDirectionProvider()),
        ChangeNotifierProxyProvider<ChaptersProvider, CoveredMaterialProvider>(
          create: (BuildContext context) => CoveredMaterialProvider(),
          update: (context, chapters, coveredMaterial) =>
              coveredMaterial!..update(chapters),
        ),
        ChangeNotifierProxyProvider2<ChaptersProvider, CoveredMaterialProvider,
            AnsweredQuestionsProvider>(
          create: (BuildContext context) => AnsweredQuestionsProvider(),
          update: (context, chapters, coveredMaterial, answeredQuestions) =>
              answeredQuestions!..update(chapters, coveredMaterial),
        ),
        ChangeNotifierProvider<ConfettiProvider>(
            create: (context) => ConfettiProvider()),
        ChangeNotifierProvider<CelebrateProvider>(
            create: (context) => CelebrateProvider()),
        ChangeNotifierProvider<MapsIconProvider>(
            create: (context) => MapsIconProvider()),
        ChangeNotifierProvider<BackgroundAnimationProvider>(
            create: (context) => BackgroundAnimationProvider()),
        ChangeNotifierProvider<PanelExpansionProvider>(
            create: (context) => PanelExpansionProvider()),
      ],
      child: AdaptiveTheme(
        light: ThemeData(
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
            seedColor: const Color(0xFF29B6F6),
            brightness: Brightness.light,
          ),
          listTileTheme: const ListTileThemeData(iconColor: Color(0xFF29B6F6)),
        ),
        dark: ThemeData(
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
            seedColor: const Color(0xFF29B6F6),
            brightness: Brightness.dark,
          ),
          listTileTheme: const ListTileThemeData(iconColor: Color(0xFF29B6F6)),
        ),
        initial: AdaptiveThemeMode.light,
        builder: (theme, darkTheme) {
          return MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: theme,
            darkTheme: darkTheme,
            initialRoute: '/splash',
            builder: (context, child) {
              return Stack(
                children: [
                  child!,
                  Consumer<ConfettiProvider>(
                    builder: (context, confetti, child) {
                      return Stack(
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: ConfettiWidget(
                              confettiController: confetti.controller,
                              blastDirectionality:
                                  BlastDirectionality.directional,
                              blastDirection: 135 * pi / 180,
                              maxBlastForce: confetti.maxBlastForce,
                              minBlastForce: confetti.minBlastForce,
                              emissionFrequency: confetti.emissionFrequency,
                              numberOfParticles: confetti.numberOfParticles,
                              gravity: confetti.gravity,
                              shouldLoop: confetti.shouldLoop,
                              createParticlePath: confetti.particlePath,
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: ConfettiWidget(
                              confettiController: confetti.controller,
                              blastDirectionality:
                                  BlastDirectionality.directional,
                              blastDirection: 45 * pi / 180,
                              maxBlastForce: confetti.maxBlastForce,
                              minBlastForce: confetti.minBlastForce,
                              emissionFrequency: confetti.emissionFrequency,
                              numberOfParticles: confetti.numberOfParticles,
                              gravity: confetti.gravity,
                              shouldLoop: confetti.shouldLoop,
                              createParticlePath: confetti.particlePath,
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: ConfettiWidget(
                              confettiController: confetti.controller,
                              blastDirectionality:
                                  BlastDirectionality.directional,
                              blastDirection: 135 * pi / 180,
                              maxBlastForce: confetti.maxBlastForce,
                              minBlastForce: confetti.minBlastForce,
                              emissionFrequency: confetti.emissionFrequency,
                              numberOfParticles: confetti.numberOfParticles,
                              gravity: confetti.gravity,
                              shouldLoop: confetti.shouldLoop,
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: ConfettiWidget(
                              confettiController: confetti.controller,
                              blastDirectionality:
                                  BlastDirectionality.directional,
                              blastDirection: 45 * pi / 180,
                              maxBlastForce: confetti.maxBlastForce,
                              minBlastForce: confetti.minBlastForce,
                              emissionFrequency: confetti.emissionFrequency,
                              numberOfParticles: confetti.numberOfParticles,
                              gravity: confetti.gravity,
                              shouldLoop: confetti.shouldLoop,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              );
            },
            onGenerateRoute: (settings) {
              Map arguments = {};
              if (settings.arguments != null) {
                arguments = settings.arguments as Map;
              }
              switch (settings.name) {
                case '/':
                  return MaterialPageRoute(builder: (_) => const Home());
                case '/splash':
                  return MaterialPageRoute(builder: (_) => const Splash());
                case '/chapter':
                  return MaterialPageRoute(
                    builder: (_) => Stack(
                      children: [Chapter(chapter: arguments['chapter'])],
                    ),
                  );
                case '/lesson':
                  return MaterialPageRoute(
                    builder: (_) => Stack(
                      children: [
                        Lesson(
                          chapter: arguments['chapter'],
                          lesson: arguments['lesson'],
                        )
                      ],
                    ),
                  );
                case '/quiz':
                  return MaterialPageRoute(
                    builder: (_) => Quiz(
                      chapterName: arguments['chapterName'],
                      questions: arguments['questions'],
                    ),
                  );
                case '/question':
                  return MaterialPageRoute(
                    builder: (_) => Question(
                      chapterName: arguments['chapterName'],
                      questions: arguments['questions'],
                      currentQuestion: arguments['currentQuestion'],
                    ),
                  );
                case '/badge':
                  return MaterialPageRoute(
                    builder: (_) => const Badge(),
                  );
              }
              return null;
            },
          );
        },
      ),
    );
  }

  Future<void> setNavigationBarColor() async {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor:
            (await AdaptiveTheme.getThemeMode() == AdaptiveThemeMode.dark)
                ? const Color(0xFF303030)
                : const Color(0xFFFAFAFA),
        systemNavigationBarIconBrightness:
            (await AdaptiveTheme.getThemeMode() == AdaptiveThemeMode.dark)
                ? Brightness.light
                : Brightness.dark,
      ),
    );
  }
}
