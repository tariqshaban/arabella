import 'package:flutter/material.dart';

class ShaderCallbackHelper {
  static Shader Function(Rect) getShaderCallback() {
    return (Rect rect) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.blue, Colors.transparent],
        stops: [0.0, 0.1],
      ).createShader(rect);
    };
  }
}
