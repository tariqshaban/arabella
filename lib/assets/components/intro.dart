import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class Intro extends StatefulWidget {
  const Intro({
    Key? key,
    required this.onDonePressed,
  }) : super(key: key);

  final Function()? onDonePressed;

  @override
  State<Intro> createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  @override
  Widget build(BuildContext context) {
    Color textColor =
        Theme.of(context).colorScheme.primary.computeLuminance() > 0.5
            ? Colors.black
            : Colors.white;

    TextStyle textStyle = TextStyle(
      color: textColor,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    return IntroductionScreen(
      pages: [
        PageViewModel(
          titleWidget: Text(
            '${'splash.slides.0.en'.tr()}\n\n${'splash.slides.0.ar'.tr()}',
            maxLines: 4,
            textAlign: TextAlign.center,
            style: textStyle,
          ),
          bodyWidget: Image.asset('assets/images/intro/home_light_ar.png'),
        ),
        PageViewModel(
          titleWidget: Text(
            '${'splash.slides.1.en'.tr()}\n\n${'splash.slides.1.ar'.tr()}',
            maxLines: 4,
            textAlign: TextAlign.center,
            style: textStyle,
          ),
          bodyWidget: Image.asset('assets/images/intro/home.png'),
        ),
        PageViewModel(
          titleWidget: Text(
            '${'splash.slides.2.en'.tr()}\n\n${'splash.slides.2.ar'.tr()}',
            maxLines: 4,
            textAlign: TextAlign.center,
            style: textStyle,
          ),
          bodyWidget: Image.asset('assets/images/intro/chapter.png'),
        ),
        PageViewModel(
          titleWidget: Text(
            '${'splash.slides.3.en'.tr()}\n\n${'splash.slides.3.ar'.tr()}',
            maxLines: 4,
            textAlign: TextAlign.center,
            style: textStyle,
          ),
          bodyWidget: Image.asset('assets/images/intro/lesson.png'),
        ),
        PageViewModel(
          titleWidget: Text(
            '${'splash.slides.4.en'.tr()}\n\n${'splash.slides.4.ar'.tr()}',
            maxLines: 4,
            textAlign: TextAlign.center,
            style: textStyle,
          ),
          bodyWidget: Image.asset('assets/images/intro/lesson_point.png'),
        ),
        PageViewModel(
          titleWidget: Text(
            '${'splash.slides.5.en'.tr()}\n\n${'splash.slides.5.ar'.tr()}',
            maxLines: 4,
            textAlign: TextAlign.center,
            style: textStyle,
          ),
          bodyWidget: Image.asset('assets/images/intro/quiz.png'),
        ),
        PageViewModel(
          titleWidget: Text(
            '${'splash.slides.6.en'.tr()}\n\n${'splash.slides.6.ar'.tr()}',
            maxLines: 4,
            textAlign: TextAlign.center,
            style: textStyle,
          ),
          bodyWidget: Image.asset('assets/images/intro/question.png'),
        ),
        PageViewModel(
          titleWidget: Text(
            '${'splash.slides.7.en'.tr()}\n\n${'splash.slides.7.ar'.tr()}',
            maxLines: 4,
            textAlign: TextAlign.center,
            style: textStyle,
          ),
          bodyWidget: Image.asset('assets/images/intro/badge.png'),
        ),
      ],
      showSkipButton: true,
      skip: const Text(
        'splash.slides.skip',
        style: TextStyle(fontWeight: FontWeight.w600),
      ).tr(),
      next: const Icon(Icons.arrow_forward),
      overrideDone: TextButton(
        onPressed: widget.onDonePressed,
        style: TextButton.styleFrom(
          minimumSize: const Size(75, 40),
          maximumSize: const Size(75, 40),
        ),
        child: const Text(
          'splash.slides.done',
          style: TextStyle(fontWeight: FontWeight.w600),
        ).tr(),
      ),
      nextFlex: 1,
      skipOrBackFlex: 1,
      controlsPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      dotsFlex: 3,
      dotsDecorator: DotsDecorator(
          activeSize: const Size(20, 9),
          activeShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
          activeColor: Theme.of(context).colorScheme.primary),
      baseBtnStyle: TextButton.styleFrom(
        minimumSize: const Size(75, 40),
        maximumSize: const Size(75, 40),
      ),
    );
  }
}
