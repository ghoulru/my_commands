import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'models.dart';
import 'password_entity_editor.dart';
import 'package:my_commands/objectbox.g.dart';

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
    required this.store
  }) : super(key: key);

  @override
  State<PasswordItemEditor> createState() => PasswordItemEditorState();
}

class PasswordItemEditorState extends State<PasswordItemEditor> {
  final _formKey = GlobalKey<FormState>();
  late int _id;
  late String _name;

  late List<PasswordsItemEntity> entities;

  @override
  void initState() {
    super.initState();

    _id = widget.data?.id ?? 0;
    _name = widget.data?.name ?? '';
  }

  @override
  Widget build(BuildContext context) {
    logger.d(widget.category);

    final bool editable = widget.editable;
    void _onSave() {
      logger.d('save passwords item');
    }

    void _onClose() {
      logger.d('close passwords item');

      // widget.onClose(currentTabId: widget.category.id);
    }

    final List<Widget> buttons = [
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // _onSave();
            logger.d('save passwords item');
          }
        },
        child: const Text('Сохранить'),
      ),
      const SizedBox(width: 20.0),
      ElevatedButton(
          onPressed: (){
            logger.d('close passwords item');
            // logger.d(widget.category);
            widget.onClose(currentTabId: widget.category.id);
          },
          child: const Text('Закрыть'),
          style: ElevatedButton.styleFrom(primary: Colors.grey[400])
          // style: ButtonStyle(
          //     backgroundColor: Colors.grey![400]
          // )
          ),
    ];

    return Container(
        padding: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
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

              IconButton(
                iconSize: 16,
                icon: const Icon(Icons.add),
                onPressed: () {
                  // print("Добавить запись/заголовок/разделитель");
                  _onEditEntity(id: 0);
                },
              ),

              const PasswordEntityEditor(data: null),,
              // )

              const SizedBox(height: 20.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: buttons,
              )
            ],
          ),
        ));
  }

  _onEntitySave() {

  }

  _onEditEntity({required int id}) {
    Alert(
        context: context,
        closeIcon: Icon(Icons.close),
        title: "Элемент",
        content: const PasswordEntityEditor(data: null),
        buttons: []).show();
  }
}
