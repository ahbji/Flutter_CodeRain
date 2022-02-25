import 'package:flutter/material.dart';

class VerticalTextLine extends StatefulWidget {
  const VerticalTextLine({
    this.speed = 12.0,
    this.maxLength = 10,
    Key? key,
  }) : super(key: key);

  final double speed;
  final int maxLength;

  @override
  _VerticalTextLineState createState() => _VerticalTextLineState();
}

class _VerticalTextLineState extends State<VerticalTextLine> {
  List<String> _characters = ['T', 'E', 'S', 'T'];

  late int _maxLength;

  @override
  void initState() {
    _maxLength = widget.maxLength;
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
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    return textWidgets;
  }
}
