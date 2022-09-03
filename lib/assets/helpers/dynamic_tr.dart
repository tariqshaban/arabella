import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/providers/assets_provider.dart';

extension TextTranslateExtension on Text {
  Text dtr(
    BuildContext context,
  ) =>
      Text(
          context
              .read<AssetsProvider>()
              .getTranslation(data!, context, context.locale.toString()),
          key: key,
          style: style,
          strutStyle: strutStyle,
          textAlign: textAlign,
          textDirection: textDirection,
          locale: locale,
          softWrap: softWrap,
          overflow: overflow,
          textScaleFactor: textScaleFactor,
          maxLines: maxLines,
          semanticsLabel: semanticsLabel,
          textWidthBasis: textWidthBasis);
}

extension StringTranslateExtension on String {
  String dtr(
    BuildContext context,
  ) =>
      context
          .read<AssetsProvider>()
          .getTranslation(this, context, context.locale.toString());
}
