import 'package:flutter/material.dart';

enum TextHeaderType {
  h1,
  h2,
  h3,
  tip
}

class TextHeader extends StatelessWidget {
  // final String text;
  final TextHeaderType? h;

  final String text;

  const TextHeader(this.text, {
        Key? key,
        this.h = TextHeaderType.h1
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late double fontSize = 18.0;
    late Color? color = Colors.black;
    late FontStyle fontStyle = FontStyle.normal;
    late FontWeight fontWeight =  FontWeight.bold;

    switch (h) {
      case TextHeaderType.h2:
        fontSize = 16.0;
        break;
      case TextHeaderType.h3:
        fontSize = 14.0;
        break;
      case TextHeaderType.tip:
        fontSize = 12.0;
        color = Colors.grey[500];
        fontStyle = FontStyle.italic;
        fontWeight =  FontWeight.w300;
        break;
      // default:
      //   fontSize = 18.0;
      //   break;
    }

    return Text(
        text,
        style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
            fontStyle: fontStyle
        )
    );
  }
}

SizedBox marginBtm([double? height = 20.0]) => SizedBox(height: height);

Widget loader = const Center(
    child: CircularProgressIndicator(
      value: null,
      strokeWidth: 7.0,
    ));