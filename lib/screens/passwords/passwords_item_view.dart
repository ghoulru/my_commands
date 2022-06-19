import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
//import 'package:my_commands/utils/widget_context_menu.dart';
import 'models.dart';
import 'passwords_entity.dart';
import 'package:my_commands/utils/styles.dart';
import 'package:logger/logger.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

var logger = Logger();

class PasswordsItemView extends StatelessWidget {
  final PasswordsItem data;
  final Function showItemEditor;
  final CategoryTabModel category;
  final int tabIndex; //индекс во вкладках
  final encrypt.Encrypter? encrypter;
  final encrypt.IV? encrypterIV;

  const PasswordsItemView({
    Key? key,
    required this.data,
    required this.showItemEditor,
    required this.category,
    required this.tabIndex,
    this.encrypter,
    this.encrypterIV,
  }) : super(key: key);

  // final ListViewController = new ScrollController()
  // final ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    // logger.d(data);

    late Widget imgWrap;
    if (data.logoURL != '') {
      late Widget img;
      if (data.logoURL.indexOf('http') == 0) {
        img = CachedNetworkImage(
          imageUrl: data.logoURL,
          height: 30.0,
        );
      }
      else {
        img = Image.file(
          File(data.logoURL),
          height: 30.0
        );
      }
      imgWrap = Row(children: [
        img,
        const SizedBox(width: 10.0),
      ]);
    }
    else {
      imgWrap = Container();
    }

    Widget header = Row(
      key: UniqueKey(),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            imgWrap,
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
                onTap: () async {
                  //TODO экспорт в текстовый файл
                  exportToFile();
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
        ),

      ],

    );
    // entitiesList.add(marginBtm(30.0));

    data.entities.sort((a, b) => a.sort.compareTo(b.sort));

    List<Widget> entitiesList = [];
    for (PasswordsItemEntity entity in data.entities) {

      entitiesList.add(PasswordsEntity(
        key: UniqueKey(),
        data: entity,
        encrypter: encrypter,
        encrypterIV: encrypterIV,
        // onEdit: _onEditEntity,
      ));
    }

    entitiesList.add(
        Divider(
            height: 50.0,
            thickness: 5.0,
            color: Colors.blue[200]
        )
    );
    // entitiesList.add(
    //   Column(
    //     children: [
    //       marginBtm(10.0),
    //       Divider(
    //         height: 5.0,
    //           thickness: 10.0,
    //         color: Colors.blue[200]
    //       )
    //     ],
    //   )
    // );

    // WidgetContextMenu testSubmenu = WidgetContextMenu(
    //   key: UniqueKey(),
    //   child: const Text('test context menu'),
    //   // width: 300,
    //   menu: [
    //     WidgetContextMenuItem(
    //         key: UniqueKey(),
    //         title: 'Редактировать',
    //         onTap: (){
    //           logger.d('tap submenu Редактировать');
    //         }
    //     ),
    //     WidgetContextMenuItem(
    //         key: UniqueKey(),
    //         title: 'Удалить',
    //         onTap: (){
    //           logger.d('tap submenu Удалить');
    //           // Navigator.pop(context);
    //         },
    //         disabled: true
    //     ),
    //
    //   ],
    // );
    ScrollController scrollController = ScrollController(keepScrollOffset: true);


    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          marginBtm(20.0),
          Divider(
              height: 0.0,
              thickness: 2.0,
              color: Colors.blue[200]
          ),
          // marginBtm(30.0),
          Expanded(
              flex: 1,
              child: SingleChildScrollView(
                controller: scrollController,
                primary: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: entitiesList,
                ),
              ),
          ),
          // testSubmenu,
        ],
      ),
      // child: SingleChildScrollView(
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.stretch,
      //     children: entitiesList,
      //   ),
      // )
    );
  }

  void exportToFile() async {

    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Выберите путь для загрузки:',
      fileName: data.name + '.txt',
    );


    if (outputFile != null && outputFile != "") {
      try {
        final file = File(outputFile);
        file.writeAsString(exportFileContent());
      }
      catch(ex){
        logger.d(ex);
      }
    }
  }
  String exportFileContent() {
    String c = '';

    if (data.entities.isNotEmpty) {
      data.entities.sort((a, b) => a.sort.compareTo(b.sort));

      // List<String> entitiesList = [];
      for (PasswordsItemEntity entity in data.entities) {
        switch (entity.type) {
          case "spacer":
            c += "\n\n";
            break;
          case "title":
            c += entity.name + "\n";
            break;
          case "entry":
            late String val;
            if (entity.subtype == PasswordsItemEntitySubtype.password ) {
              val = encrypter?.decrypt(encrypt.Encrypted.fromBase16(entity.value), iv: encrypterIV!) ?? entity.value;
            }
            else {
              val = entity.value;
            }
            c += entity.name + ": " + val  + "\n";
            break;
        }
      }
    }

    return c;
  }
}
