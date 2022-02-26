import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'LifecycleState.dart';

class VerticalTextLine extends StatefulWidget {
  const VerticalTextLine({
    required this.onFinished,
    this.speed = 12.0,
    this.maxLength = 10,
    Key? key,
  }) : super(key: key);

  final double speed;
  final int maxLength;
  final VoidCallback onFinished;

  @override
  _VerticalTextLineState createState() => _VerticalTextLineState();
}

class _VerticalTextLineState extends LifecycleState<VerticalTextLine> {
  final List<String> _characters = [];

  late int _maxLength;
  late Duration _stepInterval;
  late Timer timer;

  @override
  void setLifecycleStateHandler() {
    lifecycleStateHandler = LifecycleStateHandler(
      onResumed: () => _startTimer(),
      onPaused: () => _cancelTimer(),
      onInactive: () => _cancelTimer(),
      onDetached: () => _cancelTimer(),
    );
  }

  @override
  void initState() {
    _maxLength = widget.maxLength;
    _stepInterval = Duration(milliseconds: (1000 ~/ widget.speed));
    _startTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Color> colors = [Colors.transparent, Colors.green, Colors.green, Colors.white];
    double greenStart;
    double whiteStart;

    whiteStart = (_characters.length - 1) / (_characters.length);
    if (((_characters.length - _maxLength) / _characters.length) < 0.3) {
      greenStart = 0.3;
    }
    else {
      greenStart = (_characters.length - _maxLength) / _characters.length;
    }
    List<double> stops = [0, greenStart, whiteStart, whiteStart];
    return _getShaderMask(stops, colors);
  }

  void _startTimer() {
    timer = Timer.periodic(_stepInterval, (timer) {
      final _random = Random();
      String element = String.fromCharCode(
          _random.nextInt(512)
      );

      final box = context.findRenderObject() as RenderBox;
      if (box.size.height > MediaQuery.of(context).size.height * 2) {
        widget.onFinished();
        return;
      }

      setState(() {
        _characters.add(element);
      });
    });
  }

  void _cancelTimer() {
    timer.cancel();
  }

  ShaderMask _getShaderMask(List<double> stops, List<Color> colors) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: stops,
          colors: colors,
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: _getCharacters(),
      ),
    );
  }

  List<Widget> _getCharacters() {
    List<Widget> textWidgets = [];
    for (var character in _characters) {
      textWidgets.add(
        Text(
          character,
          style: const TextStyle(color: Colors.white),
        ),
      );
    }
    return textWidgets;
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
