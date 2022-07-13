import 'package:flutter/material.dart';
import 'package:my_commands/search/search_model.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
var logger = Logger();

class SearchField extends StatefulWidget {
  const SearchField({Key? key}) : super(key: key);

  @override
  State<SearchField> createState() => SearchFieldState();
}

class SearchFieldState extends State<SearchField> {
  // String _searchString = '';
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
      child: Row(children: [
        SizedBox(
          width: 200.0,
          height: 26.0,
          child: TextField(
            controller: _textController,
            decoration: const InputDecoration(
              hintText: "Поиск",
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color(0xFF455A64),
                  ),
              ),
              border: OutlineInputBorder(),
              focusedBorder:  OutlineInputBorder(),
            ),
            style: const TextStyle(
              fontSize: 14,
              // color: Colors.white,
            ),
          ),
        ),
        // TextField(
        //
        // ),

        // const SizedBox(width: 10.0),
        IconButton(
          iconSize: 20,
          icon: const Icon(Icons.search),
          color: Colors.white,
          onPressed: () {
            final model = Provider.of<SearchModel>(context, listen: false);
            // logger.d(_textController.text, 'searchString');
            model.searchString = _textController.text.trim();
          },
        ),
      ]),
    );
  }
}
