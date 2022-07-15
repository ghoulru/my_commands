import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hovering/hovering.dart';
import 'package:my_commands/utils/styles.dart';
import 'models.dart';
import 'package:url_launcher/url_launcher.dart';
import 'password_entity_editor.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:my_commands/utils/widget_context_menu.dart';
// import 'package:rflutter_alert/rflutter_alert.dart';

class PasswordsEntity extends StatelessWidget {
  final PasswordsItemEntity data;
  final Function? onEdit;
  final Function? onDelete;
  final Key key;
  final encrypt.Encrypter? encrypter;
  final encrypt.IV? encrypterIV;

  const PasswordsEntity({
    // Key? key,
    required this.key,
    required this.data,
    this.encrypter,
    this.encrypterIV,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //{double height= 20.0}
    // print(key);

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

        // URL
        if (data.subtype == PasswordsItemEntitySubtype.url) {
          Widget linkedText = MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () async {
                final Uri _url = Uri.parse(data.value);
                if (await canLaunchUrl(_url)) {
                  await launchUrl(_url);
                } else {
                  throw 'Could not launch ' + data.value;
                }
              },
              child: Text(data.value),
            )
          );

          valueWidget = Row(
            children: [
              linkedText,
              copiedText(context, "", data.value)
            ],
          );
        }
        else {
          // logger.d(data);
          late String val;
          if (data.subtype == PasswordsItemEntitySubtype.password ) {
            val = encrypter?.decrypt(encrypt.Encrypted.fromBase16(data.value), iv: encrypterIV!) ?? data.value;
          }
          else {
            val = data.value;
          }
          // val = val + ' / ' + data.subtype.toString();

          valueWidget = copiedText(context, val);
        }

        late Widget contentWidget;
        // if (data.subtype == PasswordsItemEntitySubtype.text) {
        //   contentWidget = Column(
        //     children: [
        //       Text(data.name + ':', style: labelStyle),
        //       const SizedBox(height: 5.0),
        //       valueWidget,
        //     ]
        //   );
        // }
        // else {
        //   contentWidget = Row(
        //       children: [
        //         Text(data.name + ':', style: labelStyle),
        //         const SizedBox(width: 10.0),
        //         valueWidget,
        //       ]
        //   );
        // }

        // contentWidget = Row(
        //     children: [
        //       Text(data.name + ':', style: labelStyle),
        //       const SizedBox(width: 10.0),
        //       valueWidget,
        //     ]
        // );
        // contentWidget = valueWidget;
        contentWidget = Expanded(
          child: valueWidget
        );

        content = Column(
            children: [
              Row(
                  children: [
                    Text(data.name + ':', style: labelStyle),
                    const SizedBox(width: 10.0),
                    // valueWidget,
                    contentWidget,
                  ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
              marginBtm(5)
            ],
            crossAxisAlignment: CrossAxisAlignment.start
        );
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

      return WidgetContextMenu(
        key: UniqueKey(),
        width: 200,
          child:content,
        menu: [
          WidgetContextMenuItem(
              key: UniqueKey(),
              title: 'Редактировать',
              onTap: (){
                onEdit!(key, data);
              }
          ),
          WidgetContextMenuItem(
              key: UniqueKey(),
              title: 'Удалить',
              onTap: (){
                onDelete!(data, key);
              }
          ),
        ]
      );

      return Row(
        children: [
          content,
          Row(
            children: [
              // РЕДАКТИРОВАТЬ
              GestureDetector(
                key: UniqueKey(),
                onTap: () {
                  onEdit!(key, data);
                },
                child: const Icon(Icons.edit, size: icoSize, color: Colors.green),
              ),
              const SizedBox(width: 10.0),
              // УДАЛИТЬ
              GestureDetector(
                key: UniqueKey(),
                onTap: () {
                  onDelete!(data, key);
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

  Widget copiedText(context, String value, [String text2copy = '']) {

    Widget content = Text(value);
    // Widget content = Row(
    //   children: [
    //     Expanded(
    //         child: Text(value)
    //     ),
    //     const SizedBox(width: 20.0)
    //   ],
    // );


    return GestureDetector(
      onTap: () {

        String txt = text2copy != '' ? text2copy : value;
        String txtTip = txt;
        if (txt.length > 100) txtTip = txt.substring(0, 50) + '...';

        Clipboard.setData(ClipboardData(text: txt)).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Скопировано в буфер обмена: ' + txtTip),
            duration: const Duration(milliseconds: 1000),
          ));
        });
      },
      child: HoverWidget(
          onHover: (e) {},
          // child: Text(value + '       '),
          child: content,
          // child: Row(
          //   children: [
          //     Flexible(
          //         flex: 1,
          //         child:  Text("value here")
          //     )
          //   ],
          // ),
          // child: Expanded(
          //     flex: 1,
          //     child:  Text("value here")
          // ),
          hoverChild: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(child: Text(value)),
              // Text(value),
              // content,
              const SizedBox(width: 10.0),
              Icon(
                Icons.copy,
                color: Colors.grey[600],
                size: 16.0,
              ),
            ],
          )
      )
    );
    // return HoverWidget(
    //     onHover: (e) {},
    //     child: Text(value + '       '),
    //     hoverChild: Row(
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       children: [
    //         Text(value),
    //         const SizedBox(width: 10.0),
    //         GestureDetector(
    //             onTap: () {
    //               Clipboard.setData(ClipboardData(text: value)).then((_) {
    //                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //                     content: Text('Скопировано в буфер обмена: ' + value),
    //                     duration: Duration(milliseconds: 1000),
    //                 ));
    //               });
    //             },
    //             child: Icon(
    //               Icons.copy,
    //               color: Colors.grey[600],
    //               size: 16.0,
    //             ),
    //         ),
    //       ],
    //     )
    // );
  }


}
