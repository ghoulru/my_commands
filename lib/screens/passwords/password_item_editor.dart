import 'package:flutter/material.dart';
import 'package:my_commands/objectbox.g.dart';
import 'package:logger/logger.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'models.dart';
import 'password_entity_editor.dart';
import 'passwords_entity.dart';


var logger = Logger();

class PasswordItemEditor extends StatefulWidget {
  final PasswordsItem? data;
  final CategoryTabModel category;
  final Function onSave;
  final Function onClose;
  final bool editable;
  final Store store;

  const PasswordItemEditor({
    Key? key,
    required this.data,
    required this.category,
    required this.onSave,
    required this.onClose,
    required this.editable,
    required this.store,
  }) : super(key: key);

  @override
  State<PasswordItemEditor> createState() => PasswordItemEditorState();
}

class PasswordItemEditorState extends State<PasswordItemEditor> {
  final _formKey = GlobalKey<FormState>();
  late int _id;
  late String _name;

  late List<PasswordsItemEntity> _entities;
  // late Set<PasswordsItemEntity> _entities;

  @override
  void initState() {
    super.initState();

    _id = widget.data?.id ?? 0;
    _name = widget.data?.name ?? '';
    _entities = widget.data?.entities ?? [];
    // if (widget.data?.entities.isNotEmpty)
    // _entities = [];
  }

  @override
  Widget build(BuildContext context) {
    logger.d(widget.category);

    final bool editable = widget.editable;

    final List<Widget> buttons = [
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {

            final item = PasswordsItem()
              ..id = _id
              ..name = _name;

            item.category.target = widget.category;
            item.entities.addAll(_entities);

            // logger.d('onPressed save passwords item', item);

            widget.onSave(item, widget.category);
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

    // Widget entityEditor = PasswordEntityEditor(
    //     data: null,
    //     onSave: _onEntitySave,
    //     onClose: widget.onClose(currentTabId: widget.category.id)
    // );

    // final entitiesWidgets = Column(
    //   children: [],
    // );

    _entities.sort((a, b) => a.sort.compareTo(b.sort));
    List<Widget> entitiesList = [];
    for(PasswordsItemEntity entity in _entities) {
      entitiesList.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entity.sort.toString(), style: TextStyle(color: Colors.grey[300])),
              const SizedBox(width: 10.0),
              Expanded(
                flex: 1,
                child: PasswordsEntity(
                    key: UniqueKey(),
                    data: entity,
                    onEdit: _onEditEntity,
                    onDelete: _onEntityDelete
                )
              )

            ],
          )
      );
    }

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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: buttons,
              ),
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
              // Container(
              //   child: ,
              // ),
              // Row(
              //   children:
              // ),
              // Expanded(
              //   flex: 1,
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: entitiesList,
              //   ),
              // ),
            Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: entitiesList,
              ),
              const SizedBox(height: 20.0),
              IconButton(
                iconSize: 16,
                icon: const Icon(Icons.add),
                onPressed: () {
                  // print("Добавить запись/заголовок/разделитель");
                  _onEditEntity();
                },
              ),

              /*
              PasswordEntityEditor(
                  data: null,
                  // parent: widget.data,
                  onSave: _onEntitySave,
                  onClose: () {
                    logger.w('close ent editor');

                    // widget.onClose(currentTabId: widget.category.id);
                  }),
              */

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
  void _onEntitySave(PasswordsItemEntity entity, [bool delete = false]) {
    logger.d(entity, '_onEntitySave');

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
          }
          else {
            entitiesTmp[i] = entity;
          }
        }

      }
    }
    else {
      entitiesTmp.add(entity);
    }

    if (delete) {
      widget.store.box<PasswordsItemEntity>()
          .remove(entity.id);
    }

    setState((){
      _entities = entitiesTmp;
    });

    // logger.d(alert.runtimeType);
    try {
      alert.dismiss();
    } catch (ex){
      // logger.e('try to dismiss alert');
    }

  }

  late Alert alertDelete;
  void _onEntityDelete(PasswordsItemEntity entity) {

    Widget btnText(String txt) => Text(txt, style: const TextStyle(color: Colors.white, fontSize: 16.0));

    alertDelete = Alert(
      context: context,
      closeIcon: const Icon(Icons.close),
      title: 'Подтвердите удаление',
      // content: Text('Выхотите удалить '),
      buttons: [
        DialogButton(
          child: btnText('Да'),
          onPressed: () {
            _onEntitySave(entity, true);
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

  _onEditEntity([PasswordsItemEntity? entity]) {

    if (entity == null) {
      int lastSort = 0;
      if (_entities.isNotEmpty) {
        PasswordsItemEntity lastEntity = _entities.last;
        lastSort = lastEntity.sort + 10;
      }
      // logger.d(lastSort, 'lastSort');

      entity = PasswordsItemEntity()
        ..sort = lastSort;
    }

    alert = Alert(
      context: context,
      closeIcon: const Icon(Icons.close),
      title: "Элемент",
      content: PasswordEntityEditor(
          data: entity,
          onSave: _onEntitySave,
          onClose: () {
            alert.dismiss();
          }),
      buttons: [],
    );

    alert.show();
  }


}
