import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:my_commands/objectbox.g.dart';
import 'package:logger/logger.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'models.dart';
import 'password_entity_editor.dart';
import 'passwords_entity.dart';
import 'package:my_commands/utils/app_models.dart';

var logger = Logger();

class PasswordItemEditor extends StatefulWidget {
  final PasswordsItem? data;
  final CategoryTabModel category;
  final Function onSave;
  final Function onClose;
  final bool editable;
  final Store store;
  final int tabIndex; //индекс во вкладках

  const PasswordItemEditor({
    Key? key,
    required this.data,
    required this.category,
    required this.onSave,
    required this.onClose,
    required this.editable,
    required this.store,
    this.tabIndex = 0,
  }) : super(key: key);

  @override
  State<PasswordItemEditor> createState() => PasswordItemEditorState();
}

class PasswordItemEditorState extends State<PasswordItemEditor> {
  final _formKey = GlobalKey<FormState>();
  late int _id;
  late String _name;
  late String _logoURL;

  late List<PasswordsItemEntity> _entities;
  late Map<Key, PasswordsItemEntity> _entitiesSet;

  late encrypt.Encrypter _encrypter;
  late encrypt.IV _encrypterIV;

  @override
  void initState() {
    super.initState();

    _id = widget.data?.id ?? 0;
    _name = widget.data?.name ?? '';
    _logoURL = widget.data?.logoURL ?? '';
    _entities = widget.data?.entities ?? [];
    _entitiesSet = {};
    if (_entities.isNotEmpty) {
      for (PasswordsItemEntity entity in _entities) {
        _entitiesSet[UniqueKey()] = entity;
      }
    }

    final key = encrypt.Key.fromUtf8(appEncryptSecretKey);
    _encrypterIV = encrypt.IV.fromLength(appEncryptSecretKeyIV);
    _encrypter = encrypt.Encrypter(encrypt.AES(key));

  }

  @override
  Widget build(BuildContext context) {
    // logger.d(widget.tabIndex);

    final bool editable = widget.editable;

    final List<Widget> buttons = [
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            final item = PasswordsItem()
              ..id = _id
              ..name = _name
              ..logoURL = _logoURL;

            item.category.target = widget.category;
            item.entities.addAll(_entities);

            logger.d(item, 'onPressed save passwords item');

            widget.onSave(item, widget.category, widget.tabIndex);
          }
        },
        child: const Text('Сохранить'),
      ),
      const SizedBox(width: 20.0),
      ElevatedButton(
          onPressed: () {
            widget.onClose(currentTabId: widget.category.id);
          },
          child: const Text('Закрыть'),
          style: ElevatedButton.styleFrom(primary: Colors.grey[400])),
    ];

    _entities.sort((a, b) => a.sort.compareTo(b.sort));

    List<Widget> entitiesList = [];
    // for (PasswordsItemEntity entity in _entities) {
    //   entitiesList.add(Row(
    //     key: UniqueKey(),
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Text(entity.sort.toString(),
    //           style: TextStyle(color: Colors.grey[300])),
    //       const SizedBox(width: 10.0),
    //       Expanded(
    //           flex: 1,
    //           child: PasswordsEntity(
    //               key: UniqueKey(),
    //               data: entity,
    //               onEdit: _entityEditor,
    //               onDelete: _onEntityDelete))
    //     ],
    //   ));
    // }
    // final key = encrypt.Key.fromUtf8(appEncryptSecretKey);
    // final iv = encrypt.IV.fromLength(appEncryptSecretKeyIV);
    // logger.d(key.runtimeType);
    // final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final entitiesSetSorted =
        SplayTreeMap<Key, dynamic>.from(_entitiesSet, (a, b) {
      int aSort = _entitiesSet[a]?.sort ?? 0;
      int bSort = _entitiesSet[b]?.sort ?? 0;
      return aSort > bSort ? 1 : -1;
    });
    // logger.d(_entitiesSetSorted, '_entitiesSetSorted');

    entitiesSetSorted.forEach((key, entity) {
      entitiesList.add(Row(
        key: UniqueKey(),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entity.sort.toString(),
              style: TextStyle(color: Colors.grey[300])),
          const SizedBox(width: 10.0),
          Expanded(
            flex: 1,
            child: PasswordsEntity(
              key: key,
              data: entity,
              onEdit: _entityEditor,
              onDelete: _onEntityDelete,
              encrypter: _encrypter,
              encrypterIV: _encrypterIV,
            ),
          )
        ],
      ));
    });

    return Container(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(widget.category.name +
                  ': ' +
                  (_id == 0 ? 'Добавление паролей' : 'Редактирование паролей')),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.end,
              //   children: buttons,
              // ),
              TextFormField(
                readOnly: !editable,
                initialValue: _name,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Не заполнено';
                  }
                  _name = value.trim();
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Наименование*',
                ),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                // readOnly: !editable,
                initialValue: _logoURL,
                validator: (value) {
                  _logoURL = value?.trim() ?? '';
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'URL логотипа/иконки',
                ),
              ),
              const SizedBox(height: 20.0),
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  primary: false,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      // children: [
                      //   ...entitiesList,

                      // ]
                      children: entitiesList),
                ),
              ),
              const SizedBox(height: 20.0),
              IconButton(
                iconSize: 16,
                icon: const Icon(Icons.add),
                onPressed: () {
                  // print("Добавить запись/заголовок/разделитель");
                  _entityEditor(UniqueKey(), null);
                },
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: buttons,
              )
            ],
          ),
        ));
  }

  late Alert alert;

  void _onEntitySave(PasswordsItemEntity entity, Key entityKey,
      [bool delete = false]) {
    logger.d(entity, '_onEntitySave ' + entityKey.toString());

    // _entitiesSet[ entityKey ] = entity
    Map<Key, PasswordsItemEntity> newSet = {..._entitiesSet};
    if (delete) {
      newSet.remove(entityKey);
      widget.store.box<PasswordsItemEntity>().remove(entity.id);
    } else {
      newSet[entityKey] = entity;
    }
    List<PasswordsItemEntity> newEntities = [];
    newSet.forEach((key, value) => newEntities.add(value));

    setState(() {
      _entitiesSet = newSet;
      _entities = newEntities;
    });

    // logger.d(alert.runtimeType);
    try {
      alert.dismiss();
    } catch (ex) {
      1;
    }
  }

  void _onEntitySaveOld(PasswordsItemEntity entity, [bool delete = false]) {
    logger.d(entity, '_onEntitySave ');

    logger.d(entity);
    List<PasswordsItemEntity> entitiesTmp = [..._entities];
    if (entity.id != 0) {
      // for( var ent in entitiesTmp) {
      //   if ()
      // }
      for (var i = 0; i < entitiesTmp.length; i++) {
        if (entitiesTmp[i].id == entity.id) {
          if (delete) {
            entitiesTmp.removeAt(i);
          } else {
            entitiesTmp[i] = entity;
          }
        }
      }
    } else {
      entitiesTmp.add(entity);
    }

    if (delete) {
      widget.store.box<PasswordsItemEntity>().remove(entity.id);
    }

    setState(() {
      _entities = entitiesTmp;
    });

    // logger.d(alert.runtimeType);
    try {
      alert.dismiss();
    } catch (ex) {
      // logger.e('try to dismiss alert');
    }
  }

  late Alert alertDelete;

  void _onEntityDelete(PasswordsItemEntity entity, Key key) {
    Widget btnText(String txt) =>
        Text(txt, style: const TextStyle(color: Colors.white, fontSize: 16.0));

    alertDelete = Alert(
      context: context,
      closeIcon: const Icon(Icons.close),
      title: 'Подтвердите удаление',
      // content: Text('Выхотите удалить '),
      buttons: [
        DialogButton(
          child: btnText('Да'),
          onPressed: () {
            _onEntitySave(entity, key, true);
            alertDelete.dismiss();
          },
          width: 50,
        ),
        DialogButton(
          child: btnText('Нет'),
          onPressed: () => alertDelete.dismiss(),
          color: Colors.red[300],
          width: 50,
        ),
      ],
    );
    // RawKeyboardListener(
    //   focusNode: FocusNode(),
    //   child: alertDelete
    // );
    alertDelete.show();
  }

  _entityEditor(Key key, [PasswordsItemEntity? entity]) {
    if (entity == null) {
      int lastSort = 0;
      if (_entities.isNotEmpty) {
        PasswordsItemEntity lastEntity = _entities.last;
        lastSort = lastEntity.sort + 10;
      }
      // logger.d(lastSort, 'lastSort');

      entity = PasswordsItemEntity()..sort = lastSort;
    }

    if (entity.subtype == PasswordsItemEntitySubtype.password) {
      entity.value = _encrypter.decrypt(encrypt.Encrypted.fromBase16(entity.value), iv: _encrypterIV);
    }

    alert = Alert(
      context: context,
      closeIcon: const Icon(Icons.close),
      title: "Элемент",
      content: PasswordEntityEditor(
        key: key,
        data: entity,
        onSave: _onEntitySave,
        onClose: () {
          alert.dismiss();
        },
        // encrypter: _encrypter,
        // encrypterIV: _encrypterIV,
      ),
      buttons: [],
    );

    alert.show();
  }
}
