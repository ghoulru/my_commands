import 'package:flutter/material.dart';

const String srcRootPath = "d:\\react_projects\\teplo-inform\\TIWorkSite2\\ClientApp\\src\\";
const String destRootPath = "j:\\_backups\\teplo-inform\\";

class FilesDb {
  String srcDir;
  String srcFilename;
  // String? destDir;
  // String destDir;

  FilesDb(this.srcDir, this.srcFilename);

  @override
  String toString() {
    return 'FilesDb';
    // return "from '${srcDir}'";
    // return "from '${srcRootPath}srcDir${srcFilename}' to '${destRootPath}${srcDir}${srcFilename}'";
  }
}


class CopyFiles {
  List copyFiles = <FilesDb>[];

  CopyFiles() {
    // var f1 = FilesDb(
    //     "components\\Analysis\\",
    //     "AnalysisForm.tsx"
    // );
    copyFiles.add(FilesDb(
        "components\\Analysis\\",
        "AnalysisForm.tsx",
    ));

    // print(copyFiles);
  }

}



// const String srcAnalysisComponentPath = "components\\Analysis\\";
// const String bakAnalysisComponentPath = "components\\analysis\\";

// List srcFiles = [];
// srcFiles.add(f1);
// const Map<String, String> srcFiles = {
//   srcAnalysisComponentPath + 'AnalysisResults.tsx': bakAnalysisComponentPath + 'AnalysisResults.tsx',
// }


class TeploinformForm extends StatefulWidget {
  const TeploinformForm({Key? key}) : super(key: key);

  @override
  TeploinformFormState createState() {
    return TeploinformFormState();
  }
}

class TeploinformFormState extends State<TeploinformForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.








    return Padding(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                // The validator receives the text that the user has entered.
                validator: (value) {
                  // if (value == null || value.isEmpty) {
                  //   return 'Please enter some text';
                  // }
                  return null;
                },
                maxLines: 8,
                // expands: true,
                decoration: const InputDecoration(
                  hintText: 'Пути к файлам, через перевод строки',
                  contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                  border: OutlineInputBorder(
                      // borderRadius: BorderRadius.circular(32.0)
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Processing Data')),
                    );
                  }
                },
                child: const Text('Сохранить'),
              ),
            ],
          ),
        ));
  }
}
