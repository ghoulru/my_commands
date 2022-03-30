// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vertical_tabs/vertical_tabs.dart';


/**
 * Как сохранить состояние при переключении табов
 * https://blog.logrocket.com/flutter-tabbar-a-complete-tutorial-with-examples/#preservingthestateoftabs
 *
 */

class Passwords extends StatelessWidget {
  const Passwords({Key? key}) : super(key: key);

  static String title = 'Пароли';

  @override
  Widget build(BuildContext context) {
   // return const Center(
   //    child: Text('passwords passwords passwords passwords '),
   //  );

    return Container(
      color: Colors.blue,
      child: VerticalTabs(
        contentScrollAxis: Axis.vertical,
          tabs: <Tab>[
            Tab(child: Text('Flutter'), icon: Icon(Icons.phone)),
            Tab(child: Text('Dart')),
          ],
          contents: <Widget>[
            Text('123123'),
            Text('sdfsdfs'),
          ],
      )
    );
  }
  
}