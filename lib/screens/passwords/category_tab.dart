import 'package:flutter/material.dart';
import 'package:contextmenu/contextmenu.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'models.dart';


class CategoryTab extends StatelessWidget {
  // final String title;
  final Function onEdit;
  final CategoryTabModel tab;

  const CategoryTab({
    Key? key,
    required this.tab,
    required this.onEdit
    // required this.onTap,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {

    // print("build tab=");
    // print(tab?.name);

    return ContextMenuArea(items: [

      ListTile(
        title: const Text('Редактировать'),
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
        title: Text('Удалить'),
        enabled: tab.items.isEmpty,
        onTap: () async {
          // debugPrint("Option 2 action");
          if (await confirm(context)) {
            debugPrint("Option 2 action");
          }
        },
      )
    ],
        width: 200,
        // child: Text(title)
        child: Padding(
          padding: EdgeInsets.only(left: 8, right: 15, top: 10, bottom: 10),
          child:
            // Text('tab')
          Row(
            children: [
              Text(tab.name),
              const SizedBox(width: 5.0),
              Text(
                '(' + tab.items.length.toString() + ')',
                style: TextStyle(color: Colors.grey[400])
              ),
            ],
          )

          // Tab(text: title, height: 30)
          //Tab(text: title, height: 30)
        )
    );
  }
}