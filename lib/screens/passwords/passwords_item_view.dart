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
  final int tabIndex; //индекс во вкладках

  const PasswordsItemView(
      {Key? key,
      required this.data,
      required this.showItemEditor,
      required this.category,
      required this.tabIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> entitiesList = [];

    logger.d(data);

    entitiesList.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            data.logoURL != ''
                ? Row(children: [
                    Image.network(
                      data.logoURL,
                      height: 30.0,
                    ),
                    const SizedBox(width: 10.0),
                  ])
                : Container(),
            TextHeader(data.name),
          ],
        ),
        //+ ' > ' + tabIndex.toString()
        Row(
          children: [
            Tooltip(
              message: 'Экспортировать в файл',
              waitDuration: const Duration(seconds: 1),
              child: GestureDetector(
                onTap: () {
                  //TODO экспорт в текстовый файл
                },
                // onTap: showItemEditor!,
                child: Icon(Icons.file_download_outlined,
                    size: 20.0, color: Colors.grey[500]),
              ),
            ),
            const SizedBox(width: 20.0),
            Tooltip(
              message: 'Редактировать поля',
              waitDuration: const Duration(seconds: 1),
              child: GestureDetector(
                onTap: () {
                  //редактировать пароли сайта
                  showItemEditor(
                      id: data.id, category: category, index: tabIndex);
                },
                child: Icon(Icons.tune, size: 20.0, color: Colors.grey[500]),
              ),
            ),
          ],
        )
      ],
    ));
    entitiesList.add(marginBtm(30.0));

    data.entities.sort((a, b) => a.sort.compareTo(b.sort));

    for (PasswordsItemEntity entity in data.entities) {
      // logger.d(entity);
      entitiesList.add(PasswordsEntity(
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
    );
  }
}
