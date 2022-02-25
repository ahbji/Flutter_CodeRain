import 'package:coderain/vertical_text_line.dart';
import 'package:flutter/material.dart';

class MatrixEffect extends StatefulWidget {
  const MatrixEffect({Key? key}) : super(key: key);

  @override
  _MatrixEffectState createState() => _MatrixEffectState();
}

class _MatrixEffectState extends State<MatrixEffect> {
  @override
  Widget build(BuildContext context) {
    return _getVerticalTextLine(context);
  }

  Widget _getVerticalTextLine(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      margin: const EdgeInsets.only(top: 50),
      child: VerticalTextLine(),
    );
  }
}
