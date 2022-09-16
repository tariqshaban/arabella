import 'package:flutter/animation.dart';

class DelayedCurve extends Curve {
  final double threshold;

  const DelayedCurve({this.threshold = 0.75});

  @override
  double transformInternal(double t) {
    assert(threshold > 0.0);
    assert(threshold < 1.0);

    if (t < threshold) {
      return 0;
    }

    return (t - threshold) / (1 - threshold);
  }
}
