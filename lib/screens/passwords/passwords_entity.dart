import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hovering/hovering.dart';
import 'package:my_commands/utils/styles.dart';
import 'models.dart';
import 'package:url_launcher/url_launcher.dart';
import 'password_entity_editor.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class PasswordsEntity extends StatelessWidget {
  final PasswordsItemEntity data;
  final Function? onEdit;
  final Function? onDelete;

  const PasswordsEntity({
    Key? key,
    required this.data,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //{double height= 20.0}

    final bool isEdit = onEdit != null;

    final TextStyle labelStyle = TextStyle(
        color: Colors.grey[700],
        //fontSize: 14,
        fontWeight: FontWeight.bold);

    Widget content;

    switch (data.type) {
      case "title":
        content = Column(
            children: [
              Text(data.name,
                  style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              marginBtm(5)
            ],
            // mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start);
        break;
      case "entry":
        late Widget valueWidget;
        if (data.subtype == PasswordsItemEntitySubtype.url) {
          valueWidget = GestureDetector(
            onTap: () async {
              final Uri _url = Uri.parse(data.value);
              if (await canLaunchUrl(_url)) {
                await launchUrl(_url);
              } else {
                throw 'Could not launch ' + data.value;
              }
            },
            child: Text(data.value),
          );
        }
        else {
          valueWidget = copiedText(context, data.value);
        }


        content = Column(
            children: [
              Row(children: [
                Text(data.name + ':', style: labelStyle),
                const SizedBox(width: 10.0),
                valueWidget,
              ]),
              marginBtm(5)
            ],
            // mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start);
        break;


      case "spacer":
        final double margin = double.parse(data.value);
        if (isEdit) {
          content = Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: TextHeader(
                  (entityTypes['spacer'] ?? 'отступ') + '=' + data.value,
                  h: TextHeaderType.tip,
              ),
          );
        }
        else {
          content = marginBtm(margin);
        }
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


    if (isEdit) {
      const double icoSize = 20.0;
      return Row(
        children: [
          content,
          Row(
            children: [
              GestureDetector(
                key: UniqueKey(),
                onTap: () {
                  onEdit!(data);
                },
                child: const Icon(Icons.edit, size: icoSize, color: Colors.green),
              ),
              const SizedBox(width: 10.0),
              GestureDetector(
                key: UniqueKey(),
                onTap: () {
                  onDelete!(data);
                },
                child: const Icon(Icons.delete_forever, size: icoSize, color: Colors.red),
              ),
            ],
          )

        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
      );
    } else {
      return content;
    }
  }

  Widget copiedText(context, String value) {
    return HoverWidget(
        onHover: (e) {},
        child: Text(value + '       '),
        hoverChild: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(value),
            const SizedBox(width: 10.0),
            GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value)).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Скопировано в буфер обмена: ' + value)));
                  });
                },
                child: Icon(
                  Icons.copy,
                  color: Colors.grey[600],
                  size: 16.0,
                ))
          ],
        ));
  }


}
