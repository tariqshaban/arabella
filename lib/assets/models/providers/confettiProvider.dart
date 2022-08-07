import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';

class ConfettiProvider with ChangeNotifier {
  late ConfettiController _controller;
  double minBlastForce = 2;
  double maxBlastForce = 50;
  double emissionFrequency = 0.01;
  int numberOfParticles = 10;
  double gravity = 0.4;
  bool shouldLoop = false;
  Path Function(Size)? particlePath;

  ConfettiProvider([Duration duration = const Duration(seconds: 2)]) {
    _controller = ConfettiController(duration: duration);
    particlePath = star;
  }

  ConfettiController get controller => _controller;

  set controller(ConfettiController value) {
    _controller = value;
    notifyListeners();
  }

  void play({bool shouldLoop = false}) {
    this.shouldLoop = shouldLoop;
    notifyListeners();
    _controller.play();
  }

  void stop() {
    _controller.stop();
  }

  Path star(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }
}
