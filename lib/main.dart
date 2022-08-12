import 'dart:math';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:arabella/assets/models/providers/answered_questions_provider.dart';
import 'package:arabella/assets/models/providers/covered_material_provider.dart';
import 'package:arabella/assets/models/providers/maps_icon_provider.dart';
import 'package:arabella/assets/models/providers/scroll_direction_provider.dart';
import 'package:arabella/badge.dart';
import 'package:arabella/home.dart';
import 'package:arabella/lesson.dart';
import 'package:arabella/question.dart';
import 'package:arabella/quiz.dart';
import 'package:arabella/splash.dart';
import 'package:confetti/confetti.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'assets/models/providers/background_animation_provider.dart';
import 'assets/models/providers/celebrate_provider.dart';
import 'assets/models/providers/chapters_provider.dart';
import 'assets/models/providers/confetti_provider.dart';
import 'assets/models/providers/scroll_offset_provider.dart';
import 'chapter.dart';

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
        ChangeNotifierProvider<ScrollOffsetProvider>(
            create: (context) => ScrollOffsetProvider()),
        ChangeNotifierProvider<MapsIconProvider>(
            create: (context) => MapsIconProvider()),
        ChangeNotifierProvider<BackgroundAnimationProvider>(
            create: (context) => BackgroundAnimationProvider()),
      ],
      child: AdaptiveTheme(
        light: ThemeData(
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarBrightness: Brightness.dark,
              statusBarIconBrightness: Brightness.dark,
              systemNavigationBarColor: Color(0xfffafafa),
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF29b6f6),
            brightness: Brightness.light,
          ),
          listTileTheme: const ListTileThemeData(iconColor: Color(0xFF29b6f6)),
        ),
        dark: ThemeData(
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarBrightness: Brightness.light,
              statusBarIconBrightness: Brightness.light,
              systemNavigationBarColor: Color(0xff303030),
              systemNavigationBarIconBrightness: Brightness.light,
            ),
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF29b6f6),
            brightness: Brightness.dark,
          ),
          listTileTheme: const ListTileThemeData(iconColor: Color(0xFF29b6f6)),
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
}
