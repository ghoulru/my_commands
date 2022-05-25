import 'package:flutter/material.dart';
import 'package:my_commands/utils/text_field_predefined_values.dart';
import 'models.dart';
import 'package:logger/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

var logger = Logger();

// enum ETypes {
//   entity,
//   title,
//   spacer,
// }

const Map<String, String> entityTypes = {
  "entry": "Запись",
  "title": 'Заголовок',
  "spacer": 'Разделитель (отступ снизу)',
};
const Map<String, String> titles = {
  "admin": "Панель администрирования",
  "ftp": "FTP",
  "ftpssh": "FTP/SSH",
  "db": "DB",
  // "admin1": "Панель администрирования 111",
  // "ftp1": "FTP 11",
  // "ftpssh1": "FTP/SSH 111",
  // "db1": "DB 11",
};

const Map<String, String> entryNames = {
  "login": "Логин",
  "pass": "Пароль",
  "url": "URL",
};

class PasswordEntityEditor extends StatefulWidget {
  final PasswordsItemEntity? data;
  // final PasswordsItem parent;



  const PasswordEntityEditor({
    Key? key,
    required this.data,
    // required this.parent
  }) : super(key: key);

  @override
  State<PasswordEntityEditor> createState() => PasswordEntityEditorState();
}

class PasswordEntityEditorState extends State<PasswordEntityEditor> {
  final _formKey = GlobalKey<FormState>();

  late String _type;
  late String _name;
  late String _value;

  final _nameController = TextEditingController();
  final _valueController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _type = 'entry';
    _name = widget.data?.name ?? '';
    _value = widget.data?.value ?? '';

    // _nameController.addListener((){
    //   logger.d(_nameController.text);
    // });
  }
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    // final bool editable = widget.editable;

    final List<DropdownMenuItem<String>> eTypes = [];
    entityTypes.forEach((String key, String value) {
      eTypes.add(
          DropdownMenuItem(
          value: key,
          child: Text(value)
      ));
    });

    final List<Widget> fields = [
      Row(
        children: [
          const Text("Тип"),
          const SizedBox(width: 20.0),
          DropdownButton<String>(
              value: _type,
              icon: const Icon(Icons.chevron_right, size: 20.0),
              elevation: 16,
              onChanged: (String? val) {
                setState(() {
                  _type = val ?? 'entry';
                });
              },
              items: eTypes
          ),
        ]
      )
    ];


    const String defaultSpacer = '20';

    // NAME
    if (_type == 'title' || _type == 'entry') {
      fields.add(
        TextFormField(
          // initialValue: _name,
          controller: _nameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Не заполнено';
            }
            _name = value.trim();
            return null;
          },
          decoration: InputDecoration(
            labelText: _type == 'title' ? 'Текст заголовка' : 'Наименование поля'
          ),
        ),
      );

      if (_type == 'entry') fields.add(TextFieldPredefinedValues(data: entryNames, controller: _nameController));
      if (_type == 'title') fields.add(TextFieldPredefinedValues(data: titles, controller: _nameController));
    }
    // VALUE
    if (_type == 'spacer' || _type == 'entry') {
      fields.add(
        TextFormField(
          // initialValue: _name,
          controller: _valueController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Не заполнено';
            }
            _name = value.trim();
            return null;
          },
          decoration: InputDecoration(
            labelText: _type == 'spacer' ? 'Значение в ед. изм., например ' + defaultSpacer : 'Значение',
          ),
        ),
      );
    }

    fields.addAll([
      const SizedBox(height: 20.0),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {

                  // widget.onSave();
                }
              },
              child: const Text('Сохранить'),
            ),
            const SizedBox(width: 20.0),
            ElevatedButton(
              onPressed: () {
                // widget.onClose(currentTabId: widget.category.id);
              },
              child: const Text('Закрыть'),
            ),

          ],
        )
   ] );





    return Container(
        padding: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: fields





          ),
        )
    );
  }
}