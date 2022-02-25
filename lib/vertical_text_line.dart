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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: _getCharacters(),
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
