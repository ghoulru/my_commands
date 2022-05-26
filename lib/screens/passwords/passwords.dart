import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vertical_tabs/vertical_tabs.dart';
import 'models.dart';
import 'category_view.dart';
import 'category_tab.dart';
import 'category_editor.dart';
import 'password_item_editor.dart';

// import '../../objectbox.dart';
import 'package:my_commands/objectbox.g.dart';
import 'package:logger/logger.dart';

var logger = Logger();

/**
 * Как сохранить состояние при переключении табов
 * https://blog.logrocket.com/flutter-tabbar-a-complete-tutorial-with-examples/#preservingthestateoftabs
 *
 */
class Passwords extends StatefulWidget {
  final Store store;
  late final Box categoryTabsBox;
  late final Box passwordsItemsBox;

  Passwords({Key? key, required this.store}) : super(key: key) {
    // print('Passwords constructor');
    // logger.d('Passwords constructor');
    categoryTabsBox = store.box<CategoryTabModel>();
    passwordsItemsBox = store.box<PasswordsItem>();
  }

  static String title = 'Пароли';

  @override
  State<Passwords> createState() => PasswordsState();
}

// SingleTickerProviderStateMixin
class PasswordsState extends State<Passwords> with TickerProviderStateMixin {
  late List<CategoryTab> _categoryTabs;
  late TabController _categoryTabsController;


  Widget view = const Center(
        child: CircularProgressIndicator(
          value: null,
          strokeWidth: 7.0,
        ));

  void doEditCategoryTab(int id) {
    debugPrint('doEditCategoryTab ' + id.toString());
    final category = id != 0 ? widget.categoryTabsBox.get(id) : null;
    setState(() {
      view = CategoryEditor(category: category, onSave: saveCategory);
    });
  }

  //{int currentTabId = 0}
  void showTabs({int currentTabId = 0}) {
    final tabs = widget.categoryTabsBox.getAll();

    // List<Widget> ct = [];
    List<CategoryTab> ct = [];

    //sort tabs
    tabs.sort((a, b) => a.sort.compareTo(b.sort));

    int tabIndex = 0;
    int i = 0;
    for (CategoryTabModel tab in tabs) {
      ct.add(CategoryTab(
          key: UniqueKey(),
          tab: tab,
          onEdit: doEditCategoryTab,
          onDelete: deleteCategory,
          onAddItem: showItemEditor)
      );

      if (tab.id == currentTabId) tabIndex = i;
      i++;
    }

    _categoryTabs = ct;
    _categoryTabsController = TabController(vsync: this, length: ct.length, initialIndex: tabIndex);

    setState(() {
      view = CategoryView(
          categoryTabs: _categoryTabs,
          categoryTabsController: _categoryTabsController,
          doEditCategoryTab: doEditCategoryTab
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
    } else {
      cat.id = id;
      widget.categoryTabsBox.put(cat);
    }

    showTabs(currentTabId: id);
  }

  void deleteCategory(int id) {
    widget.categoryTabsBox.remove(id);
    showTabs();
  }

  void showItemEditor({required int id, required CategoryTabModel category}) {
    logger.i('showItemEditor ' + id.toString());
    // logger.i(category.toString());

    setState(() {
      view = PasswordItemEditor(
          data: null,
          category: category,
          onSave: saveItem,
          onClose: showTabs,
          editable: true,
          store: widget.store
      );
    });
  }
  void saveItem(data) {
    logger.d(data);
  }

  @override
  void initState() {
    super.initState();

    showTabs();
  }
  @override
  void dispose() {
    super.dispose();
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
