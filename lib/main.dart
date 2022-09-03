import 'dart:math';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:animated_background/animated_background.dart';
import 'package:confetti/confetti.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'assets/models/providers/answered_questions_provider.dart';
import 'assets/models/providers/assets_provider.dart';
import 'assets/models/providers/background_animation_provider.dart';
import 'assets/models/providers/celebrate_provider.dart';
import 'assets/models/providers/chapters_provider.dart';
import 'assets/models/providers/confetti_provider.dart';
import 'assets/models/providers/covered_material_provider.dart';
import 'assets/models/providers/maps_icon_provider.dart';
import 'assets/models/providers/post_navigation_animation_provider.dart';
import 'assets/models/providers/scroll_direction_provider.dart';
import 'assets/models/providers/selected_color_provider.dart';
import 'assets/models/providers/theme_provider.dart';
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

class _MainState extends State<Main> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    setNavigationBarColor();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AssetsProvider>(
            create: (context) => AssetsProvider(), lazy: false),
        ChangeNotifierProxyProvider<AssetsProvider, ChaptersProvider>(
          create: (BuildContext context) => ChaptersProvider(),
          update: (context, assets, chaptersProvider) =>
          chaptersProvider!..update(assets),
        ),
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
        ChangeNotifierProvider<ThemeProvider>(
            create: (context) => ThemeProvider(), lazy: false),
        ChangeNotifierProxyProvider<ThemeProvider, SelectedColorProvider>(
          create: (BuildContext context) => SelectedColorProvider(),
          update: (context, theme, selectedColor) =>
              selectedColor!..update(theme),
        ),
        ChangeNotifierProvider<PostNavigationAnimationProvider>(
            create: (context) => PostNavigationAnimationProvider()),
      ],
      child: AdaptiveTheme(
        light: ThemeData(),
        dark: ThemeData(),
        initial: AdaptiveThemeMode.dark,
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
                  Consumer<BackgroundAnimationProvider>(
                    builder: (context, backgroundAnimation, child) {
                      return Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.elliptical(
                                  MediaQuery.of(context).size.width,
                                  backgroundAnimation.bottomRadius),
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              height: backgroundAnimation.height,
                              decoration: BoxDecoration(
                                boxShadow: const [BoxShadow(blurRadius: 40)],
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).scaffoldBackgroundColor,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: const [0, 1],
                                ),
                              ),
                              child: AnimatedBackground(
                                behaviour: RandomParticleBehaviour(
                                  options: ParticleOptions(
                                      particleCount: 50,
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
                                          : Colors.white),
                                ),
                                vsync: this,
                                child: const SizedBox(),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Theme(
                    data: Theme.of(context)
                        .copyWith(scaffoldBackgroundColor: Colors.transparent),
                    child: child!,
                  ),
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

              Widget selectedPage = const SizedBox();

              switch (settings.name) {
                case '/':
                  selectedPage = const Home();
                  break;
                case '/splash':
                  selectedPage = const Splash();
                  break;
                case '/chapter':
                  selectedPage = Chapter(chapter: arguments['chapter']);
                  break;
                case '/lesson':
                  selectedPage = Lesson(
                    chapter: arguments['chapter'],
                    lesson: arguments['lesson'],
                  );
                  break;
                case '/quiz':
                  selectedPage = Quiz(
                    chapterName: arguments['chapterName'],
                    questions: arguments['questions'],
                  );
                  break;
                case '/question':
                  selectedPage = Question(
                    chapterName: arguments['chapterName'],
                    questions: arguments['questions'],
                    currentQuestion: arguments['currentQuestion'],
                  );
                  break;
                case '/badge':
                  selectedPage = const Badge();
                  break;
              }

              return PageRouteBuilder(
                settings: settings,
                pageBuilder: (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                ) =>
                    FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 1).animate(animation),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 1, end: 0)
                        .animate(secondaryAnimation),
                    child: selectedPage,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> setNavigationBarColor() async {
    AdaptiveThemeMode? adaptiveThemeMode = await AdaptiveTheme.getThemeMode();
    bool isDark = adaptiveThemeMode == null ||
        adaptiveThemeMode == AdaptiveThemeMode.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor:
            isDark ? const Color(0xFF303030) : const Color(0xFFFAFAFA),
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }
}
