import 'package:flutter/material.dart';
import 'models.dart';
import 'passwords_entity.dart';
import 'package:my_commands/utils/styles.dart';
import 'package:logger/logger.dart';
var logger = Logger();

class PasswordsItemView extends StatelessWidget {
  final PasswordsItem data;
  final Function showItemEditor;
  final CategoryTabModel category;

  const PasswordsItemView({
    Key? key,
    required this.data,
    required this.showItemEditor,
    required this.category
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    List<Widget> entitiesList = [];

    entitiesList.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextHeader(data.name),
          Row(
            children: [

              GestureDetector(
                onTap: () {
                  //TODO экспорт в текстовый файл
                },
                // onTap: showItemEditor!,
                child: Icon(Icons.file_download_outlined, size: 20.0, color: Colors.grey[500]),
              ),
              const SizedBox(width: 20.0),
              GestureDetector(
                onTap: () {
                  //редактировать пароли сайта
                  showItemEditor(id: data.id, category: category);
                },
                // onTap: showItemEditor!,
                child: Icon(Icons.tune, size: 20.0, color: Colors.grey[500]),
              ),
            ],
          )

        ],
      )
    );
    entitiesList.add(marginBtm(30.0));

    data.entities.sort((a, b) => a.sort.compareTo(b.sort));

    for (PasswordsItemEntity entity in data.entities) {
      // logger.d(entity);
      entitiesList.add(
          PasswordsEntity(
          key: UniqueKey(),
          data: entity,
        // onEdit: _onEditEntity,
      ));
    }

    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: entitiesList,
        ),
    )
    ;
  }
}
