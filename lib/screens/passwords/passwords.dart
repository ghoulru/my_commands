import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vertical_tabs/vertical_tabs.dart';
import 'category_view.dart';
import 'category_tab.dart';
import 'category_editor.dart';
import 'models.dart';
import '../../objectbox.dart';
import 'package:my_commands/objectbox.g.dart';



/**
 * Как сохранить состояние при переключении табов
 * https://blog.logrocket.com/flutter-tabbar-a-complete-tutorial-with-examples/#preservingthestateoftabs
 *
 */
class Passwords extends StatefulWidget {
  final Store store;
  late final Box categoryTabsBox;

  Passwords({
    Key? key,
    required this.store
  }) : super(key: key) {
    print('Passwords constructor');
    categoryTabsBox = store.box<CategoryTabModel>();

    // final tabMy = CategoryTabModel()
    //   ..name = 'Мои сайты и прочее'
    //   ..sort = 1;
    // categoryTabsBox.put(tabMy);


  }

  static String title = 'Пароли';

  @override
  State<Passwords> createState() => PasswordsState();
}
// SingleTickerProviderStateMixin
class PasswordsState extends State<Passwords> with TickerProviderStateMixin {


  late List<Widget> _categoryTabs;
  late TabController _categoryTabsController;
  Widget view = const Center(
    child: CircularProgressIndicator(
      value: null,
      strokeWidth: 7.0,
    )
  );



  void doEditCategoryTab(int id) {
    debugPrint('doEditCategoryTab ' + id.toString());
    final category = id != 0 ? widget.categoryTabsBox.get(id) : null;
    setState(() {
      view = CategoryEditor(category: category, onSave: saveCategory);
    });
  }

  void showTabs() {
    final tabs = widget.categoryTabsBox.getAll();
    print(tabs.length);

    List<Widget> ct = [];

    //TODO sort tabs
    tabs.sort((a, b) => a.sort.compareTo(b.sort));

    tabs.forEach((tab) {
      print("tab name " + tab.name + " id=" + tab.id.toString());
      if (tab != null) {
        ct.add(
            CategoryTab(
                key: UniqueKey(),
                tab: tab,
                onEdit: doEditCategoryTab
              // onEdit: () {
              //   doEditCategoryTab(tab.id);
              // }
            )
        );
      }
    });
    _categoryTabs = ct;
    _categoryTabsController = TabController(vsync: this, length: ct.length);


    setState(() {
      view = CategoryView(
        categoryTabs: _categoryTabs,
        categoryTabsController: _categoryTabsController,
        doEditCategoryTab: doEditCategoryTab,
      );
    });
  }

  void saveCategory({
  required int? id,
  required String name,
  required int sort
  }) {
    // print('saveCategory');
    if (id == null) {
      showTabs();
      return;
    }
    final cat = CategoryTabModel()
        ..name = name
        ..sort = sort;
    if (id == 0) {
      widget.categoryTabsBox.put(cat);
    }
    else {
      cat.id = id;
      widget.categoryTabsBox.put(cat);
    }

    showTabs();
  }
  void deleteCategory({required id}) {

  }

  @override
  void initState() {
    // print("init state PasswordsState");
    super.initState();

    showTabs();
    // view = CategoryEditor(category: null, onSave: saveCategory);

    // widget.categoryTabsBox.remove(1);



    // if (_categoryTabs.isNotEmpty) {
    //   view = CategoryView(
    //       categoryTabs: _categoryTabs,
    //       categoryTabsController: _categoryTabsController,
    //       doEditCategoryTab: doEditCategoryTab,
    //   );
    // }
    // else {
    //   view = const Center(
    //     child: Text('passwords passwords passwords passwords '),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint("--passwords build--");
    // print(objectbox);
    // debugPrint(_categoryTabs.length.toString());
    // debugPrint("view type");
    // print(view.runtimeType);
    return view;
   return const Center(
      child: Text('passwords passwords passwords passwords '),
    );

    // if (_categoryTabs) {
    //   return Null;
    // }
   // if (_categoryTabs.isNotEmpty) {
   //   return CategoryView(
   //       categoryTabs: _categoryTabs,
   //       categoryTabsController: _categoryTabsController
   //   );
   // }
   // else
   //   return Center(
   //        child: Text('passwords passwords passwords passwords '),
   //      );

    // return Container(
    //   color: Colors.blue,
    //   child: VerticalTabs(
    //     contentScrollAxis: Axis.vertical,
    //       tabs: <Tab>[
    //         Tab(child: Text('Flutter'), icon: Icon(Icons.phone)),
    //         Tab(
    //             child: Text('Dart')
    //           // child: CategoryTab(title: 'asd')
    //         ),
    //       ],
    //       contents: <Widget>[
    //         Text('123123'),
    //         Text('sdfsdfs'),
    //       ],
    //   )
    // );
  }
  
}

