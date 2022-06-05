import 'package:flutter/material.dart';
import 'package:contextmenu/contextmenu.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'models.dart';
import 'package:my_commands/utils/widget_context_menu.dart';
import 'package:logger/logger.dart';
var logger = Logger();

class CategoryTab extends StatelessWidget {

  const CategoryTab({
    Key? key,
    required this.tab,
    required this.onEdit,
    required this.onDelete,
    required this.onAddItem,
  }) : super(key: key);

  final CategoryTabModel tab;
  final Function onEdit;
  final Function onDelete;
  final Function onAddItem;


  @override
  Widget build(BuildContext context) {

    // print("build tab=");
    // print(tab?.name);
    // logger.d('onEdit type', onEdit.runtimeType);
    // logger.d('onDelete type', onDelete.runtimeType);

    return WidgetContextMenu(
      key: UniqueKey(),
      width: 200,
      child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 15, top: 10, bottom: 10),
          child:
          // Text('tab')
          Row(
            children: [
              // Text(tab.id.toString()),
              Text(tab.name),
              const SizedBox(width: 5.0),
              Text(
                  '(' + tab.items.length.toString() + ')',
                  style: TextStyle(color: Colors.grey[400])
              ),
            ],
          )
      ),
      menu: [
        WidgetContextMenuItem(
            key: UniqueKey(),
            title: 'Добавить элемент',
            onTap: (){
              onAddItem(id: 0, category: tab);
            }
        ),
        WidgetContextMenuDivider(),
        WidgetContextMenuItem(
            key: UniqueKey(),
            title: 'Редактировать вкладку',
            onTap: (){
              onEdit(tab.id);
            }
        ),
        WidgetContextMenuItem(
            key: UniqueKey(),
            title: 'Удалить вкладку',
            onTap: () async {
              if (await confirm(
                context,
                title: null,
                content: const Text('Подтвердите удаление'),
                textOK: const Text('Да'),
                textCancel: const Text('Нет'),
              )) {
                debugPrint("on tab delete delete");

                onDelete(tab.id);
              }
            },
          disabled: tab.items.isNotEmpty,
        ),
      ]
    );

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
          padding: const EdgeInsets.only(left: 8, right: 15, top: 10, bottom: 10),
          child:
            // Text('tab')
          Row(
            children: [
              // Text(tab.id.toString()),
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