import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_commands/utils/styles.dart';
import 'models.dart';
import 'category_view.dart';
import 'category_tab.dart';
import 'category_editor.dart';
import 'password_item_editor.dart';
import 'package:objectbox/objectbox.dart';
import 'package:my_commands/objectbox.g.dart';
import 'package:my_commands/search/search_model.dart';
import 'package:provider/provider.dart';
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
  late final String searchString;

  Passwords({Key? key, required this.store, required this.searchString})
      : super(key: key) {
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
  // TabController? _categoryTabsController = null;

  //запоминаем выбранный сайт для каждой вкладки
  late Map<int, int> activeTabAndItem = {};

  Widget view = loader;

  static const int searchTabId = 1000;

  void doEditCategoryTab(int id) {
    debugPrint('doEditCategoryTab ' + id.toString());
    final category = id != 0 ? widget.categoryTabsBox.get(id) : null;
    setState(() {
      view = CategoryEditor(category: category, onSave: saveCategory);
    });
  }

  void setActiveTabAndItem({required int tabId, required int siteIndex}) {
    // logger.d(siteIndex, 'setActiveTabAndItem tabId= ' + tabId.toString());
    Map<int, int> atai = {...activeTabAndItem};
    atai[tabId] = siteIndex;
    // logger.d(atai, 'setActiveTabAndItem');
    // setState(() {
    //   activeTabAndItem = atai;
    // });
    /**/
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      // logger.d('setState activeTabAndItem');
      setState(() {
        activeTabAndItem = atai;
      });
    });
    /**/
  }

  //{int currentTabId = 0}
  List showTabs({int currentTabId = 0}) {
    List tabs = widget.categoryTabsBox.getAll();

    List<CategoryTab> ct = [];

    //sort tabs
    tabs.sort((a, b) => a.sort.compareTo(b.sort));

    logger.d(widget.searchString + ' / currentTabId=' + currentTabId.toString(), 'searchString in showTabs');

    bool changeTab = true;
    // if (currentTabId == searchTabId) {
    //
    // }

    // if (widget.searchString != '')
    if (currentTabId == searchTabId) {

      ToMany<PasswordsItem> searchResult = ToMany<PasswordsItem>();
      if (widget.searchString != '') {
        for (CategoryTabModel tab in tabs) {
          if (tab.items.isNotEmpty) {
            for (PasswordsItem passItem in tab.items) {
              if (passItem.name.contains(widget.searchString)) {
                searchResult.add(passItem);
              }
            }
          }
        }

        // if (searchResult.isNotEmpty)
            {
          final CategoryTabModel searchTab = CategoryTabModel()
            ..id = searchTabId
            ..name = 'Результаты Поиска'
            ..sort = 1000
            ..editable = false
            ..items = searchResult;

          tabs.add(searchTab);
        }
      }
      if (searchResult.isEmpty) changeTab = false;

    }

    logger.d(tabs);

    int tabIndex = 0;
    int i = 0;
    for (CategoryTabModel tab in tabs) {
      ct.add(CategoryTab(
          key: UniqueKey(),
          tab: tab,
          onEdit: doEditCategoryTab,
          onDelete: deleteCategory,
          onAddItem: showItemEditor));

      if (tab.id == currentTabId) {
        tabIndex = i;
      }
      if (!activeTabAndItem.containsKey(tab.id)) {
        activeTabAndItem[tab.id] = 0;
      }
      i++;
    }
    logger.d(tabIndex, 'showTabs tabIndex');
    logger.d('ct.length='+ct.length.toString());


    _categoryTabs = ct;
    // _categoryTabsController.dispose();
    // int defIndex = _categoryTabsController.index;
    _categoryTabsController = TabController(initialIndex: _categoryTabsController.index, length: ct.length, vsync: this);

    // var rnd = Random();

    // _categoryTabsController.index(rnd.nextInt(4));



    setState(() {
      view = CategoryView(
        categoryTabs: _categoryTabs,
        categoryTabsController: _categoryTabsController,
        doEditCategoryTab: doEditCategoryTab,
        store: widget.store,
        tabs: tabs,
        showItemEditor: showItemEditor,
        activeTabAndItem: activeTabAndItem,
        setActiveTabAndItem: setActiveTabAndItem,
      );
    });

    if (changeTab) _categoryTabsController.animateTo(tabIndex);

    return tabs;
  }

  void saveCategory(
      {required int? id, required String name, required int sort}) {
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

  void showItemEditor(
      {required int id, required CategoryTabModel category, int index = 0}) {
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
          categoryTabs: widget.categoryTabsBox.getAll(),
          category: category,
          onSave: saveItem,
          onClose: showTabs,
          editable: true,
          store: widget.store,
          tabIndex: index);
    });
  }

  void saveItem(data, category, itemTabIndex) {
    logger.d(data, 'save  site passwords');
    // logger.d(itemTabIndex)

    final itemId = widget.passwordsItemsBox.put(data);

    // logger.d(itemId);
    showTabs(currentTabId: category.id);
  }

  @override
  void initState() {
    super.initState();
    _categoryTabs = [];
    _categoryTabsController = TabController(initialIndex: 0, length: 0, vsync: this);
    showTabs();
    // showTabs(currentTabId: 1);
  }

  @override
  void didUpdateWidget(covariant Passwords oldWidget) {
    super.didUpdateWidget(oldWidget);
    // logger.d(widget.searchString + '/ old=' + oldWidget.searchString,
    //     'change search didUpdateWidget');

    // var rnd = Random();
    // showTabs(currentTabId: rnd.nextInt(5));
    if (widget.searchString != oldWidget.searchString) {

      showTabs(currentTabId: searchTabId);
      // showTabs(currentTabId: rnd.nextInt(5));
      // showTabs();
    }
  }

  @override
  void dispose() {
    _categoryTabs = [];
    _categoryTabsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // logger.d(widget.searchString, 'searchString in passwords');

    return view;

  }
}
