import 'package:flutter/material.dart';

class FullScreenWidget extends StatelessWidget {
  const FullScreenWidget(
      {Key? key,
      required this.child,
      this.fullScreenWidget,
      this.backgroundColor = Colors.black,
      this.backgroundIsTransparent = true,
      this.opacity = 0.5,
      this.padding = EdgeInsets.zero,
      this.enabled = true,
      this.disposeLevel})
      : super(key: key);

  final Widget child;
  final Widget? fullScreenWidget;
  final Color backgroundColor;
  final bool backgroundIsTransparent;
  final double opacity;
  final EdgeInsetsGeometry padding;
  final bool enabled;
  final DisposeLevel? disposeLevel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (!enabled) {
          return;
        }
        Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            barrierColor: backgroundIsTransparent
                ? Colors.white.withOpacity(0)
                : backgroundColor,
            pageBuilder: (BuildContext context, _, __) {
              return FullScreenPage(
                backgroundColor: backgroundColor,
                backgroundIsTransparent: backgroundIsTransparent,
                opacity: opacity,
                padding: padding,
                disposeLevel: disposeLevel,
                child: (fullScreenWidget == null) ? child : fullScreenWidget!,
              );
            },
          ),
        );
      },
      child: child,
    );
  }
}

enum DisposeLevel { high, medium, low }

class FullScreenPage extends StatefulWidget {
  const FullScreenPage(
      {Key? key,
      required this.child,
      this.backgroundColor = Colors.black,
      this.backgroundIsTransparent = true,
      this.opacity = 0.5,
      this.padding = EdgeInsets.zero,
      this.disposeLevel = DisposeLevel.medium})
      : super(key: key);

  final Widget child;
  final Color backgroundColor;
  final bool backgroundIsTransparent;
  final double opacity;
  final EdgeInsetsGeometry padding;
  final DisposeLevel? disposeLevel;

  @override
  FullScreenPageState createState() => FullScreenPageState();
}

class FullScreenPageState extends State<FullScreenPage> {
  double? initialPositionY = 0;

  double? currentPositionY = 0;

  double positionYDelta = 0;

  double opacity = 0;

  double disposeLimit = 150;

  late Duration animationDuration;

  @override
  void initState() {
    super.initState();
    setDisposeLevel();
    animationDuration = Duration.zero;
    opacity = widget.opacity;
  }

  setDisposeLevel() {
    setState(() {
      if (widget.disposeLevel == DisposeLevel.high) {
        disposeLimit = 300;
      } else if (widget.disposeLevel == DisposeLevel.medium) {
        disposeLimit = 200;
      } else {
        disposeLimit = 100;
      }
    });
  }

  void _startVerticalDrag(details) {
    setState(() {
      initialPositionY = details.globalPosition.dy;
    });
  }

  void _whileVerticalDrag(details) {
    setState(() {
      currentPositionY = details.globalPosition.dy;
      positionYDelta = currentPositionY! - initialPositionY!;
    });
  }

  _endVerticalDrag(DragEndDetails details) {
    if (positionYDelta > disposeLimit || positionYDelta < -disposeLimit) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        animationDuration = const Duration(milliseconds: 300);
        opacity = 1;
        positionYDelta = 0;
      });

      Future.delayed(animationDuration).then((_) {
        setState(() {
          animationDuration = Duration.zero;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundIsTransparent
          ? Colors.transparent
          : widget.backgroundColor,
      body: GestureDetector(
        onVerticalDragStart: (details) => _startVerticalDrag(details),
        onVerticalDragUpdate: (details) => _whileVerticalDrag(details),
        onVerticalDragEnd: (details) => _endVerticalDrag(details),
        child: Container(
          color: widget.backgroundColor.withOpacity(opacity),
          constraints: BoxConstraints.expand(
            height: MediaQuery.of(context).size.height,
          ),
          child: Stack(
            children: <Widget>[
              AnimatedPositioned(
                duration: animationDuration,
                curve: Curves.fastOutSlowIn,
                top: 0 + positionYDelta,
                bottom: 0 - positionYDelta,
                left: 0,
                right: 0,
                child: Padding(
                  padding: widget.padding,
                  child: widget.child,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
