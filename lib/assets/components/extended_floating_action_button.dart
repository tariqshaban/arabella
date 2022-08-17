import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../models/providers/scroll_direction_provider.dart';

class ExtendedFloatingActionButton extends StatefulWidget {
  const ExtendedFloatingActionButton(
      {Key? key,
      required this.text,
      required this.icon,
      this.elementSpacing = 5,
      this.iconFirst = true,
      this.onPressed})
      : super(key: key);

  final String text;
  final Widget icon;
  final double elementSpacing;
  final bool iconFirst;
  final VoidCallback? onPressed;

  @override
  State<ExtendedFloatingActionButton> createState() =>
      _ExtendedFloatingActionButtonState();
}

class _ExtendedFloatingActionButtonState
    extends State<ExtendedFloatingActionButton> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ScrollDirectionProvider>(
      builder: (context, scrollDirection, child) {
        return FloatingActionButton.extended(
          extendedPadding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
          backgroundColor: Theme.of(context).colorScheme.primary,
          label: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  axis: Axis.horizontal,
                  child: child,
                ),
              );
            },
            child: (scrollDirection.direction != ScrollDirection.forward)
                ? widget.icon
                : Row(
                    children: (widget.iconFirst)
                        ? [
                            widget.icon,
                            SizedBox(width: widget.elementSpacing),
                            Text(
                              widget.text,
                              style: const TextStyle(letterSpacing: 0),
                            ),
                          ]
                        : [
                            Text(
                              widget.text,
                              style: const TextStyle(letterSpacing: 0),
                            ),
                            SizedBox(width: widget.elementSpacing),
                            widget.icon,
                          ],
                  ),
          ),
          onPressed: () => widget.onPressed?.call(),
        );
      },
    );
  }
}
