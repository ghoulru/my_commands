import 'package:flutter/material.dart';
import 'package:my_commands/utils/text_field_predefined_values.dart';
import 'models.dart';
import 'package:logger/logger.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:my_commands/utils/app_models.dart';

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
  "ssh": "SSH",
  "db": "DB",
  "hostpanel": "Панель хостинга",
};

const Map<String, String> entryNames = {
  "login": "Логин",
  "password": "Пароль",
  "url": "URL",
  "address": "Адрес",
  "host": "Host",
  "dbname": "Имя БД"
};

class PasswordEntityEditor extends StatefulWidget {
  final Key key;
  final PasswordsItemEntity? data;
  final Function onSave;
  final Function onClose;
  final PasswordsItem? parent;
  //
  // final encrypt.Encrypter encrypter;
  // final encrypt.IV encrypterIV;

  // final int sort;

  const PasswordEntityEditor({
    // Key? key,
    required this.key,
    required this.data,
    required this.onSave,
    required this.onClose,
    // required this.encrypter,
    // required this.encrypterIV,
    // required this.sort,
    this.parent,
  }) : super(key: key);

  @override
  State<PasswordEntityEditor> createState() => PasswordEntityEditorState();
}

class PasswordEntityEditorState extends State<PasswordEntityEditor> {
  final _formKey = GlobalKey<FormState>();

  late String _type;
  late PasswordsItemEntitySubtype _subtype;
  late String _name;
  late String _value;
  late int _sort;

  final _nameController = TextEditingController();
  final _valueController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _type = widget.data?.type ?? 'entry';
    _subtype = widget.data?.subtype ?? PasswordsItemEntitySubtype.string;
    _name = widget.data?.name ?? '';
    _value = widget.data?.value ?? '';
    _sort = widget.data?.sort ?? 0;

    _nameController.text = _name;
    _valueController.text = _value;

    // logger.d(widget.data);
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
    // logger.d('sort in build=' + _sort.toString());

    final List<DropdownMenuItem<String>> eTypes = [];
    entityTypes.forEach((String key, String value) {
      eTypes.add(DropdownMenuItem(value: key, child: Text(value)));
    });

    final List<Widget> fields = [
      Row(children: [
        const Text("Тип"),
        const SizedBox(width: 20.0),
        DropdownButton<String>(
            value: _type,
            icon: const Icon(Icons.chevron_right, size: 20.0),
            elevation: 16,
            onChanged: (String? val) {
              String thisValue = '';
              if (val == 'spacer') {
                thisValue = '20';
              }

              setState(() {
                _type = val ?? 'entry';
                _subtype = PasswordsItemEntitySubtype.string;
                _name = '';
                _value = thisValue;
                _nameController.text = '';
                _valueController.text = thisValue;
              });
            },
            items: eTypes),
      ])
    ];

    const String defaultSpacer = '20';

    // NAME
    if (_type == 'title' || _type == 'entry') {
      fields.add(
        TextFormField(
          // key: UniqueKey(),
          controller: _nameController,
          validator: (value) {
            // logger.w(value, 'name validate');
            if (value == null || value.isEmpty) {
              return 'Не заполнено';
            }
            _name = value.trim();
            return null;
          },
          decoration: InputDecoration(
              labelText:
                  _type == 'title' ? 'Текст заголовка' : 'Наименование поля'),
        ),
      );

      if (_type == 'entry') {
        fields.add(
          TextFieldPredefinedValues(
              key: UniqueKey(),
              data: entryNames,
              onClick: (String key, String value) {
                _nameController.text = value;

                late PasswordsItemEntitySubtype subt;
                switch (key) {
                  case "url":
                    subt = PasswordsItemEntitySubtype.url;
                    break;
                  case "password":
                    subt = PasswordsItemEntitySubtype.password;
                    break;
                  default:
                    subt = PasswordsItemEntitySubtype.string;
                    break;
                }

                setState(() {
                  _subtype = subt;
                });
              }),
        );
      }
      if (_type == 'title') {
        fields.add(TextFieldPredefinedValues(
          key: UniqueKey(),
          data: titles,
          onClick: (String key, String value) {
            _nameController.text = value;
          },
        ));
      }
    }
    // VALUE
    if (_type == 'spacer' || _type == 'entry') {
      fields.add(
        TextFormField(
          // key: UniqueKey(),
          controller: _valueController,
          validator: (value) {
            logger.w(value, 'value validate');
            if (value == null || value.isEmpty) {
              return 'Не заполнено';
            }
            _value = value.trim();
            return null;
          },
          decoration: InputDecoration(
            labelText: _type == 'spacer'
                ? 'Значение в ед. изм., например ' + defaultSpacer
                : 'Значение',
          ),
        ),
      );
    }

    fields.add(
      TextFormField(
        // key: UniqueKey(),
        initialValue: _sort.toString(),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Не заполнено';
          }
          int s;
          try {
            s = int.parse(value.trim());
          } catch (ex) {
            s = 0;
          }
          _sort = s;

          return null;
        },
        decoration: const InputDecoration(
          labelText: 'Порядок сортировки (0 и более)',
        ),
      ),
    );

    fields.addAll([
      const SizedBox(height: 20.0),
      Row(
        children: [
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                String val = _value;
                if (_subtype == PasswordsItemEntitySubtype.password) {
                  final key = encrypt.Key.fromUtf8(appEncryptSecretKey);
                  final iv = encrypt.IV.fromLength(appEncryptSecretKeyIV);

                  final encrypter = encrypt.Encrypter(encrypt.AES(key));

                  final encrypted = encrypter.encrypt(val, iv: iv);
                  logger.d(encrypted.base16, _subtype);

                  val = encrypted.base16;
                }

                final entity = PasswordsItemEntity()
                  ..id = widget.data?.id ?? 0
                  ..type = _type
                  ..subtype = _subtype
                  ..name = _name
                  ..value = val
                  ..sort = _sort;
                // debugPrint('ent editor save>>>>');
                // debugPrint(_type);
                // print(_subtype);
                // debugPrint(_name);
                // debugPrint(_value);
                // logger.d(entity);

                widget.onSave(entity, widget.key);
              }
              // else
              //   print(' but cant');
            },
            child: const Text('Сохранить'),
          ),
          const SizedBox(width: 20.0),
          ElevatedButton(
            onPressed: () {
              widget.onClose();
            },
            child: const Text('Закрыть'),
          ),
        ],
      )
    ]);

    return Container(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(children: fields),
        ));
  }
}
