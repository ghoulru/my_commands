import 'package:flutter/material.dart';
import 'package:my_commands/utils/styles.dart';
import 'models.dart';
import 'category_view.dart';
import 'category_tab.dart';
import 'category_editor.dart';
import 'password_item_editor.dart';
import 'package:my_commands/objectbox.g.dart';
import 'package:logger/logger.dart';

var logger = Logger();

/// Как сохранить состояние при переключении табов
/// https://blog.logrocket.com/flutter-tabbar-a-complete-tutorial-with-examples/#preservingthestateoftabs
///
/// TODO поле с путем до логотипа, и выводить лого  рядом с названием
/// TODO открытие инфы о всех дотуспах к сату в новом окне, т.е. это запуск нового приложения
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

  Widget view = loader;

  void doEditCategoryTab(int id) {
    debugPrint('doEditCategoryTab ' + id.toString());
    final category = id != 0 ? widget.categoryTabsBox.get(id) : null;
    setState(() {
      view = CategoryEditor(category: category, onSave: saveCategory);
    });
  }

  //запоминаем выбранный сайт для каждой вкладки
  late Map<int, int> activeTabAndItem = {};

  void setActiveTabAndItem({required int tabId, required int siteIndex}) {
    logger.d(siteIndex, 'setActiveTabAndItem ' + tabId.toString());
    Map<int,int> atai = {...activeTabAndItem};
    atai[ tabId ] = siteIndex;
    logger.d(atai);

    // WidgetsBinding.instance!.addPostFrameCallback((_){
    //   logger.d('setState activeTabAndItem');
    //   setState(() {
    //     activeTabAndItem = atai;
    //   });
    // });

  }

  //{int currentTabId = 0}
  List showTabs({int currentTabId = 0}) {
    final List tabs = widget.categoryTabsBox.getAll();

    List<CategoryTab> ct = [];

    //sort tabs
    tabs.sort((a, b) => a.sort.compareTo(b.sort));

    // late CategoryTabModel currentTab;
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

      if (tab.id == currentTabId) {
        tabIndex = i;
        // currentTab = tab;
      }
      i++;
    }

    _categoryTabs = ct;
    _categoryTabsController = TabController(vsync: this, length: ct.length, initialIndex: tabIndex);


    setState(() {
      view = CategoryView(
          categoryTabs: _categoryTabs,
          categoryTabsController: _categoryTabsController,
          doEditCategoryTab: doEditCategoryTab,
          store: widget.store,
          tabs: tabs,
          showItemEditor: showItemEditor,
          // activeTabAndItem: activeTabAndItem,
          // setActiveTabAndItem: setActiveTabAndItem,
      );
    });

    return tabs;
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

  void showItemEditor({required int id, required CategoryTabModel category, int index = 0}) {
    // logger.i('showItemEditor ' + id.toString());
    // logger.i(category.toString());

    PasswordsItem? item;
    if (id != 0) {
      item = widget.passwordsItemsBox.get(id);
    } else {
      item = null;
    }

    setState(() {
      view = PasswordItemEditor(
          data: item,
          category: category,
          onSave: saveItem,
          onClose: showTabs,
          editable: true,
          store: widget.store,
          tabIndex: index
      );
    });
  }
  void saveItem(data, category, itemTabIndex) {
    logger.d(data, 'save  site passwords');

    final itemId = widget.passwordsItemsBox.put(data);

    logger.d(itemId);
    showTabs(currentTabId: category.id);
  }

  @override
  void initState() {
    super.initState();

    showTabs();

    // List tabs = showTabs();
    //
    // for (CategoryTabModel tab in tabs) {
    //   activeTabAndItem[ tab.id ] = 0;
    // }


  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

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
