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

  @override
  void initState() {
    super.initState();

    _id = widget.data?.id ?? 0;
    _name = widget.data?.name ?? '';
    _entities = [];
  }

  @override
  Widget build(BuildContext context) {
    logger.d(widget.category);

    final bool editable = widget.editable;
    // void _onSave() {
    //   logger.d('save passwords item');
    // }
    //
    // void _onClose() {
    //   logger.d('close passwords item');
    //
    //   // widget.onClose(currentTabId: widget.category.id);
    // }

    final List<Widget> buttons = [
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // _onSave();
            logger.d('save passwords item');
            final item = PasswordsItem()
              ..id = _id
              ..name = _name;

            item.category.target = widget.category;
            item.entities.addAll(_entities);

            logger.d(item);

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

    List<Widget> entitiesList = [];
    for(PasswordsItemEntity entity in _entities) {
      entitiesList.add(
          PasswordsEntity(
            key: UniqueKey(),
            data: entity,
            onEdit: _onEditEntity,
          )
      );
    }

    return Container(
        padding: EdgeInsets.all(10.0),
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
                  _onEditEntity(id: 0);
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: buttons,
              )
            ],
          ),
        ));
  }

  late Alert alert;
  _onEntitySave(PasswordsItemEntity entity) {
    logger.d(entity, '_onEntitySave');
    // List
    // _entities.add(entity);
    setState((){
      _entities = [..._entities, entity];
    });

    try {
      alert.dismiss();
    } catch (ex){
      logger.e('try to dismiss alert');
    }

    //TODO сортировать по sort - потом на выводе
  }

  _onEditEntity({required int id}) {

    int lastSort = 0;
    if (_entities.isNotEmpty) {
      PasswordsItemEntity lastEntity = _entities.last;
      lastSort = lastEntity.sort + 1;
    }

    alert = Alert(
      context: context,
      closeIcon: const Icon(Icons.close),
      title: "Элемент",
      content: PasswordEntityEditor(
          data: null,
          // parent: widget.data,
          onSave: _onEntitySave,
          onClose: () {
            logger.w('close ent editor');
            // Navigator.pop(context);
            alert.dismiss();
            // widget.onClose(currentTabId: widget.category.id);
          }),
      buttons: [],
    );

    alert.show();
  }


}
