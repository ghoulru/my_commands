import 'package:flutter/material.dart';

// import 'package:contextmenu/contextmenu.dart';
import 'package:vertical_tabs/vertical_tabs.dart';
import 'package:logger/logger.dart';
import 'package:my_commands/objectbox.g.dart';
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

  late Map<int, int> categoryItemsSelectedIndex = {};

  @override
  void initState() {
    super.initState();

    // final Box passwordsItemsBox = widget.store.box<PasswordsItem>();
    //
    // final Map<int, PasswordsItem> passwordsItem4Tab = {};

    // logger.d('initState CategoryViewState');
    // for (var tab in widget.tabs) {
    //   categoryItemsSelectedIndex[ tab.id ] = 0;
    // }
  }
  @override
  void dispose() {
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
                    labelPadding: const EdgeInsets.only(left: 0, right: 0)
                ),
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

    //TODO сортировать по имени или как то иначе, елси будут кнопки
    for (PasswordsItem item in category.items) {
      itemTabs.add(Tab(child: Text(item.name)));
      itemTabsContent.add(Tab(
          child: PasswordsItemView(
            data: item,
            showItemEditor: widget.showItemEditor,
            category: category,
          )
      ));
    }
    logger.d(widget.activeTabAndItem[category.id], 'categoryPasswords init site index for catId ' + category.id.toString());

    return VerticalTabs(
        contentScrollAxis: Axis.vertical,
        tabs: itemTabs,
        contents: itemTabsContent,
        initialIndex: widget.activeTabAndItem[category.id],
        onSelect: (index) {
          if (widget.activeTabAndItem[category.id] != index) {
            widget.setActiveTabAndItem(
                tabId: category.id,
                siteIndex: index
            );
          }
        }
    );
  }
}
