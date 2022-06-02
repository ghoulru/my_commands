import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:vertical_tabs/vertical_tabs.dart';
import 'package:logger/logger.dart';
import 'package:my_commands/objectbox.g.dart';
import 'package:my_commands/utils/app_models.dart';
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
    // required this.activeTabAndItem,
    // required this.setActiveTabAndItem,
  }) : super(key: key);

  final List<CategoryTab> categoryTabs;
  final dynamic categoryTabsController;
  final dynamic doEditCategoryTab;
  final Store store;
  final List tabs;
  final Function showItemEditor;

  // final Map<int, int> activeTabAndItem;
  // final Function setActiveTabAndItem;

  @override
  State<CategoryView> createState() => CategoryViewState();
}

class CategoryViewState extends State<CategoryView> {
  late Map<int, int> activeTabAndItem = {};
  late encrypt.Encrypter _encrypter;
  late encrypt.IV _encrypterIV;

  @override
  void initState() {
    super.initState();

    // final Box passwordsItemsBox = widget.store.box<PasswordsItem>();
    //
    // final Map<int, PasswordsItem> passwordsItem4Tab = {};

    logger.d('initState CategoryViewState');
    logger.d(widget.tabs);
    for (var tab in widget.tabs) {
      activeTabAndItem[tab.id] = 0;
    }

    final key = encrypt.Key.fromUtf8(appEncryptSecretKey);
    _encrypterIV = encrypt.IV.fromLength(appEncryptSecretKeyIV);
    _encrypter = encrypt.Encrypter(encrypt.AES(key));
  }

  @override
  void dispose() {
    // final Box categoryTabsBox = widget.store.box<CategoryTabModel>();
    // final Box passwordsItemsBox = widget.store.box<PasswordsItem>();
    // for (PasswordsItem item in category.items)
    // logger.d('dispose cat CategoryView');
    // activeTabAndItem.forEach((catId, siteIndex) {
    //   print("$catId, $siteIndex");
    //   // if ()
    // });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabsContent = [];

    for (var tab in widget.tabs) {
      // logger.d(categoryTab.tab);
      // tabsContent.add(Text("tab content: " + categoryTab.tab.name));
      if (tab.items.length == 0) {
        tabsContent.add(const Text("no items"));
      } else {
        tabsContent.add(categoryPasswords(tab));
      }
    }

    // logger.d(activeTabAndItem, 'CategoryView build activeTabAndItem');

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
                children: tabsContent)),
      ],
    ));
  }

  // void onSelectSite(index, category) {
  //   logger.d(index, 'VerticalTabs onSelect ' + category.id.toString());
  //
  //   Map<int,int> cisi = {...categoryItemsSelectedIndex};
  //   cisi[ category.id ] = index;
  //
  //   WidgetsBinding.instance!.addPostFrameCallback((_){
  //     setState(() {
  //       categoryItemsSelectedIndex = cisi;
  //     });
  //   });
  //
  // }

  Widget categoryPasswords(category) {
    // logger.d(category.items);

    final List<Tab> itemTabs = [];
    final List<Widget> itemTabsContent = [];
    // logger.d(widget.showItemEditor.runtimeType);

    //TODO добавить строку быстрого поиска, наверное лучше в шапку, т.е. надо использовать редукс= Bloc

    //TODO сортировать по имени или как то иначе, если будут кнопки
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

    return VerticalTabs(
        contentScrollAxis: Axis.vertical,
        tabs: itemTabs,
        contents: itemTabsContent,
        initialIndex: activeTabAndItem[category.id],
        onSelect: (index) {
          // logger.d(
          //     index,
          //     'VerticalTabs onSelect =' +
          //         activeTabAndItem[category.id].toString());

          Map<int, int> atai = {...activeTabAndItem};
          atai[category.id] = index;
          logger.d(atai);

          WidgetsBinding.instance!.addPostFrameCallback((_) {
            // logger.d('setState activeTabAndItem');
            setState(() {
              activeTabAndItem = atai;
            });
          });
        });
  }
}
