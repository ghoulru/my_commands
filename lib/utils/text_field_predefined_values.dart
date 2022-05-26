import 'package:flutter/material.dart';

class TextFieldPredefinedValues extends StatelessWidget {
  final Map<String, String> data;
  // final TextEditingController controller;
  final Function onClick;

  const TextFieldPredefinedValues({
    Key? key,
    required this.data,
    required this.onClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> datalist = [];

    data.forEach((String key, String value) {
      datalist.add(GestureDetector(
        key: ObjectKey(key),
        onTap: () {
          // controller.text = value;
          onClick(key, value);
        },
        child: Text(value,
            style: TextStyle(
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dashed,
              fontSize: 12.0,
              color: Colors.grey[400]
            )),
      ));
      datalist.add(
        const SizedBox(width: 10.0),
      );
    });
    return Wrap(

      children: datalist,
    );
  }
}
