// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:contextmenu/contextmenu.dart';
import 'package:vertical_tabs/vertical_tabs.dart';
import 'category_tab.dart';
import 'package:logger/logger.dart';
var logger = Logger();


class CategoryView extends StatefulWidget {

  const CategoryView({
    Key? key,
    required this.categoryTabs,
    required this.categoryTabsController,
    required this.doEditCategoryTab,
    // required this.tabs,
    // required this.deleteCategory
  }) : super(key: key);

  final List<CategoryTab> categoryTabs;
  final dynamic categoryTabsController;
  final dynamic doEditCategoryTab;
  // final dynamic tabs;
  // final Function deleteCategory;

  @override
  State<CategoryView> createState() => CategoryViewState();
}

class CategoryViewState extends State<CategoryView> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final List<Widget> tabsContent = [];

    for (var categoryTab in widget.categoryTabs) {
      // logger.d(categoryTab.tab);

      tabsContent.add(Text("tab content: " + categoryTab.tab.name));
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
                      labelPadding: EdgeInsets.only(left: 0, right: 0)
                  ),
                  IconButton(
                    iconSize: 16,
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      print("add tab");
                      if (widget.doEditCategoryTab.runtimeType != Null) {
                        widget.doEditCategoryTab(0);
                      }
                    },
                  )
                ],
              )
            ),
              Flexible(
                fit: FlexFit.tight,
                flex: 1,
                // child: Text('888'),
                  child:TabBarView(
                      controller: widget.categoryTabsController,
                      children: tabsContent
                  )
              ),


          ],
        )
     );

  }
}
