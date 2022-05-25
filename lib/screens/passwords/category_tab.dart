import 'package:flutter/material.dart';
import 'package:contextmenu/contextmenu.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'models.dart';
import 'package:logger/logger.dart';
var logger = Logger();

class CategoryTab extends StatelessWidget {

  CategoryTab({
    Key? key,
    required this.tab,
    required this.onEdit,
    required this.onDelete,
    required this.onAddItem,
  }) : super(key: key);

  CategoryTabModel tab;
  final Function onEdit;
  final Function onDelete;
  final Function onAddItem;


  @override
  Widget build(BuildContext context) {

    // print("build tab=");
    // print(tab?.name);
    // logger.d('onEdit type', onEdit.runtimeType);
    // logger.d('onDelete type', onDelete.runtimeType);

    return ContextMenuArea(items: [

      ListTile(
        title: const Text('Добавить элемент'),
        onTap: () {
          onAddItem(id: 0, category: tab);
        },
      ),
      Divider(
        height: 20,
        thickness: 1,
        indent: 0,
        endIndent: 0,
        color: Colors.grey[400],
      ),
      ListTile(
        title: const Text('Редактировать вкладку'),
        // contentPadding: EdgeInsets.all(2.0),
        minVerticalPadding: 0,
        horizontalTitleGap: 0,
        // onTap: onEdit(tab.id),
        onTap: () {
          debugPrint("Option Редактировать " + tab.id.toString());
          onEdit(tab.id);
        },
      ),

      ListTile(
        // leading: Icon(Icons.model_training),
        title: const Text('Удалить вкладку'),
        enabled: tab.items.isEmpty,
        onTap: () async {
          if (await confirm(
              context,
            title: null,//const Text(''),
            content: const Text('Подтвердите удаление'),
            textOK: const Text('Да'),
            textCancel: const Text('Нет'),
          )) {
            debugPrint("ontap delete");

            onDelete(tab.id);
          }
        },
      )
    ],
        width: 300,
        // child: Text(title)
        child: Padding(
          padding: EdgeInsets.only(left: 8, right: 15, top: 10, bottom: 10),
          child:
            // Text('tab')
          Row(
            children: [
              Text(tab.id.toString()),
              Text(tab.name),
              const SizedBox(width: 5.0),
              Text(
                '(' + tab.items.length.toString() + ')',
                style: TextStyle(color: Colors.grey[400])
              ),
            ],
          )
        )
    );
  }
}