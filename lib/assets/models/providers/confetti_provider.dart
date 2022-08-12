import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class ConfettiProvider with ChangeNotifier {
  ConfettiProvider([
    this.duration = const Duration(seconds: 2),
    this.minBlastForce = 2,
    this.maxBlastForce = 50,
    this.emissionFrequency = 0.01,
    this.numberOfParticles = 10,
    this.gravity = 0.08,
    this.shouldLoop = false,
    this.particlePath,
  ]) {
    _controller = ConfettiController(duration: duration);
    particlePath ??= star;
  }

  late ConfettiController _controller;
  Duration duration;
  double minBlastForce;
  double maxBlastForce;
  double emissionFrequency;
  int numberOfParticles;
  double gravity;
  bool shouldLoop;
  Path Function(Size)? particlePath;

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
