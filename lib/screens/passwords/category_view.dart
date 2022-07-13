import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:vertical_tabs/vertical_tabs.dart';
import 'package:logger/logger.dart';
import 'package:my_commands/objectbox.g.dart';
import 'package:my_commands/utils/secret_key.dart';
import 'models.dart';
import 'category_tab.dart';
import 'passwords_item_view.dart';

var logger = Logger();

class CategoryView extends StatefulWidget {
  const CategoryView({
    Key? key,
    required this.categoryTabs,
    required this.categoryTabsController,
    required this.doEditCategoryTab,
    required this.store,
    required this.tabs,
    required this.showItemEditor,
    required this.activeTabAndItem,
    required this.setActiveTabAndItem,
  }) : super(key: key);

  final List<CategoryTab> categoryTabs;
  final dynamic categoryTabsController;
  final dynamic doEditCategoryTab;
  final Store store;
  final List tabs;
  final Function showItemEditor;

  final Map<int, int> activeTabAndItem;
  final Function setActiveTabAndItem;

  @override
  State<CategoryView> createState() => CategoryViewState();
}

class CategoryViewState extends State<CategoryView> {
  late Map<int, int> _thisActiveTabAndItem = {};
  late encrypt.Encrypter _encrypter;
  late encrypt.IV _encrypterIV;

  // late List<VerticalTabs> tabsContent;

  @override
  void initState() {
    super.initState();

    // final Box passwordsItemsBox = widget.store.box<PasswordsItem>();
    //
    // final Map<int, PasswordsItem> passwordsItem4Tab = {};

    // logger.d('initState CategoryViewState');
    // logger.d(widget.tabs, 'initState CategoryViewState');
    // logger.d(widget.activeTabAndItem, 'initState CategoryViewState');
    // for (var tab in widget.tabs) {
    //   _thisActiveTabAndItem[tab.id] = 0;
    // }
    _thisActiveTabAndItem = widget.activeTabAndItem;
    // logger.d(_thisActiveTabAndItem, '_thisActiveTabAndItem CategoryViewState initState');

    final key = encrypt.Key.fromUtf8(appEncryptSecretKey);
    _encrypterIV = encrypt.IV.fromLength(appEncryptSecretKeyIV);
    _encrypter = encrypt.Encrypter(encrypt.AES(key));

    // tabsContent = [];
  }

  @override
  void dispose() {

    //
    // for (VerticalTabs tc in tabsContent) {
    //   logger.d(tc.runtimeType);
    //   if (tc.runtimeType == VerticalTabs)
    //     tc.dispose();
    // }
    // tabsContent = [];

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabsContent = [];

    // tabsContent = [];

    for (var tab in widget.tabs) {

      if (tab.items.length == 0) {
        tabsContent.add(Text(tab.name + " has no items"));
      } else {
        tabsContent.add(categoryPasswords(tab));
      }
    }

    return Center(
        // child: Text('passwords passwords passwords passwords '),
        child: Column(
      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                TabBar(
                    controller: widget.categoryTabsController,
                    isScrollable: true,
                    indicatorColor: Colors.black,
                    labelColor: Colors.black,
                    tabs: widget.categoryTabs,
                    labelPadding: const EdgeInsets.only(left: 0, right: 0)),
                IconButton(
                  iconSize: 16,
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (widget.doEditCategoryTab.runtimeType != Null) {
                      widget.doEditCategoryTab(0);
                    }
                  },
                )
              ],
            )),
        Flexible(
            fit: FlexFit.tight,
            flex: 1,
            // child: Text('888'),
            child: TabBarView(
                controller: widget.categoryTabsController,
                children: tabsContent,
            ),
        ),
      ],
    ));
  }



  Widget categoryPasswords(category) {

    final List<Tab> itemTabs = [];
    final List<Widget> itemTabsContent = [];

    //сортировка по имени или как то иначе, если будут кнопки
    final List<PasswordsItem> categoryItems = category.items;
    categoryItems.sort((a, b) => a.name.compareTo(b.name));



    int i = 0;
    for (PasswordsItem item in categoryItems) {
      itemTabs.add(Tab(child: Text(item.name)));
      itemTabsContent.add(Tab(
          child: PasswordsItemView(
              data: item,
              showItemEditor: widget.showItemEditor,
              category: category,
              tabIndex: i++,
              encrypter: _encrypter,
              encrypterIV: _encrypterIV,
          )));
    }
    // logger.d(
    //     activeTabAndItem[category.id],
    //     'categoryPasswords init site index for catId ' +
    //         category.id.toString());

    int initIndex = _thisActiveTabAndItem[category.id] ?? 0;
    if (initIndex > categoryItems.length) {
      initIndex = 0;
    }


    // logger.d(initIndex, 'initIndex for tabid= ' + category.id.toString());
    // logger.d(_thisActiveTabAndItem);

    return VerticalTabs(
        contentScrollAxis: Axis.vertical,
        tabs: itemTabs,
        contents: itemTabsContent,
        initialIndex: initIndex,
        onSelect: (index) {

          // int lastIndex = widget.activeTabAndItem[category.id] ?? 0;
          int lastIndex = _thisActiveTabAndItem[category.id] ?? 0;

          // logger.d(
          //     'index=' + index.toString()
          //     + ' / lastIndex='
          //     + lastIndex.toString(),
          //     'VerticalTabs onSelect tabId=' + category.id.toString()
          // );
          // logger.d(_thisActiveTabAndItem);

          Map<int, int> atai = {..._thisActiveTabAndItem};
          atai[category.id] = index;
          // logger.d(atai);

          WidgetsBinding.instance!.addPostFrameCallback((_) {
            // logger.d('setState activeTabAndItem');
            setState(() {
              _thisActiveTabAndItem = atai;
            });
            widget.setActiveTabAndItem(tabId:category.id, siteIndex: index);
          });

        });
  }
}
