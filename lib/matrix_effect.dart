import 'dart:async';
import 'dart:math';

import 'package:coderain/LifecycleState.dart';
import 'package:coderain/vertical_text_line.dart';
import 'package:flutter/material.dart';

class MatrixEffect extends StatefulWidget {
  const MatrixEffect({Key? key}) : super(key: key);

  @override
  _MatrixEffectState createState() => _MatrixEffectState();
}

class _MatrixEffectState extends LifecycleState<MatrixEffect> {
  final List<Widget> _verticalLines = [];
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
    _startTimer();
    super.initState();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      setState(() {
        _verticalLines.add(
            _getVerticalTextLine(context)
        );
      });
    });
  }

  void _cancelTimer() {
    timer.cancel();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: _verticalLines
    );
  }

  Widget _getVerticalTextLine(BuildContext context) {
    Key key = GlobalKey();
    return Positioned(
      key: key,
      left: Random().nextDouble() * MediaQuery.of(context).size.width,
      child: VerticalTextLine(
          onFinished: () {
            setState(() {
              _verticalLines.removeWhere((element) {
                return element.key == key;
              });
            });
          },
          speed: 1 + Random().nextDouble() * 9,
          maxLength: Random().nextInt(10) + 5
      ),
    );
  }
}
