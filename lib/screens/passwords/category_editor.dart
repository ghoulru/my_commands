import 'package:flutter/material.dart';
import 'models.dart';


class CategoryEditor extends StatefulWidget {
  final CategoryTabModel? category;
  final Function onSave;

  const CategoryEditor({
    Key? key,
    required this.category,
    required this.onSave
  }) : super(key: key);

  @override
  State<CategoryEditor> createState() => CategoryEditorState();
}

class CategoryEditorState extends State<CategoryEditor> {
  final _formKey = GlobalKey<FormState>();

  late int _id;
  late String _name;
  late int _sort;


  @override
  void initState() {
    super.initState();

    _id = widget.category?.id ?? 0;
    _name = widget.category?.name ?? '';
    _sort = widget.category?.sort ?? 0;

    print(_id);
  }

  @override
  Widget build(BuildContext context) {
    // return Text('CategoryEditor');
    print("CategoryEditorState  build");
    print(widget.category?.id);

    // https://flutter.su/tutorial/4-forma-vvoda-proverka
    return Container(
        padding: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[

              Text(
                  _id == 0 ? 'Новая категория' : 'Редактирование категории'
              ),
              TextFormField(
                initialValue: _name,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Не заполнено';
                  }
                  _name = value.trim();
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Наименование категории*',
                ),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                initialValue: _sort.toString(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Не заполнено';
                  }
                  _sort = int.parse(value);
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Порядковый номер*',
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onSave(id: _id, name: _name, sort: _sort);
                      }
                    },
                    child: const Text('Сохранить'),
                  ),
                  const SizedBox(width: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      widget.onSave(id: null, name: _name, sort: _sort);
                    },
                    child: const Text('Закрыть'),
                  ),
                  //
                  // ElevatedButton(
                  //   onPressed: () {
                  //       widget.onSave(id: null, name: _name, sort: _sort);
                  //     }
                  //   },
                  //   child: const Text('Закрыть'),
                  // ),
                ],
              )

            ],
          ),
        )
    );

  }
}