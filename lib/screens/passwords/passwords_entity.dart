import 'package:flutter/material.dart';
import 'models.dart';


class PasswordsEntity extends StatelessWidget {
  final PasswordsItemEntity data;
  final Function? onEdit;

  const PasswordsEntity({
    Key? key,
    required this.data,
    this.onEdit,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {

    //{double height= 20.0}
    SizedBox marginBtm([double? height = 20.0]) => SizedBox(height: height);

    final TextStyle labelStyle = TextStyle(
        color: Colors.grey[700],
        //fontSize: 14,
        fontWeight: FontWeight.bold
    );

    Widget content;

    switch(data.type) {
      case "title":
        content = Column(
          children: [
            Text(
                data.name,
                style: TextStyle(
                    color: Colors.grey[900],
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                )
            ),
            marginBtm(5)
          ],
            // mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start
        );
        break;
      case "entry":
        content= Column(
            children: [
              Row(
                children: [
                  Text(data.name + ':', style: labelStyle),
                  const SizedBox(width: 10.0),
                  Text(data.value),
                ]
              ),
              marginBtm(5)
            ],
            // mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start
        );
        break;
      default:
        content = Column(
          children: [
            Text("нет обработчика для блока типа " + data.type),
            marginBtm()
          ],
        );
        break;
    }

    //
    // if (onEdit == null) {
    //
    // }

    if (onEdit != null) {
      return Row(
        children: [
          content,
          GestureDetector(
            key: ObjectKey(key),
            onTap: (){
              onEdit!(data.id);
            },
            child: Text('редактировать',
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 12.0,
                    color: Colors.grey[400]
                )),
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
      );
    }
    else {
      return content;
    }
    return content;
  }
}