import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:hovering/hovering.dart';
import 'package:flutter/scheduler.dart';
import 'package:animations/animations.dart';

var logger = Logger();

const double widgetContextMenuItemPaddingHorizontal = 20.0;


class WidgetContextMenu extends StatefulWidget {
  final Widget child;
  final List<Widget> menu;
  final double width;
  final WidgetBuilder? builder;

  const WidgetContextMenu({
    Key? key,
    required this.child,
    required this.menu,
    this.builder,
    this.width = 200.0,
  }) : super(key: key);

  @override
  State<WidgetContextMenu> createState() => WidgetContextMenuState();
}

class WidgetContextMenuState extends State<WidgetContextMenu> {
  // late OverlayState _overlayState;
  late OverlayEntry? _overlayEntry;
  GlobalKey stickyKey = GlobalKey();
  late Key _menuKey;

  @override
  void initState() {
    super.initState();
    // _menuKey = UniqueKey();
    // if (_overlayEntry != null) {
    //   _overlayEntry.remove();
    //
    // }
    // _overlayEntry.remove();
    // _overlayEntry = _createOverlayEntry(context);

    // SchedulerBinding.instance!.addPostFrameCallback((_) {
    //   Overlay.of(context)!.insert(_overlayEntry);
    // });
    // _menuKey  = GlobalKey();
    // _overlayState = Overlay.of(context)!;
  }

  @override
  void dispose() {
    // _overlayEntry.remove();
    try {
      _overlayEntry!.remove();
    }catch(ex){
      1;
    }
    super.dispose();
  }

  Widget menuWrap () {
   return Container(
     key: stickyKey,
     width: widget.width,
     padding: const EdgeInsets.all(1),
     decoration: BoxDecoration(
       color: Colors.grey[200],
       border: Border.all(
         color: Colors.grey[300] ?? Colors.white,
         width: 0.0,
       ),
       borderRadius: BorderRadius.circular(2),
       
     ),
     child: Column(
       mainAxisAlignment: MainAxisAlignment.start,
       crossAxisAlignment: CrossAxisAlignment.stretch,
       children: widget.menu,
     ),
   );
  }

  OverlayEntry _createOverlayEntry(context, position) {

    Widget menu = menuWrap();

    // RenderBox renderBox = context.findRenderObject();
    // var size = renderBox.size;
    // var offset = renderBox.localToGlobal(Offset.zero);
    // logger.d(size, MediaQuery.of(context).size);
    // logger.d(position);
    // RenderBox renderBoxMenu = menu.currentContext;
    // final keyContext = stickyKey.currentContext;
    // logger.d(keyContext);
    // RenderObject menuBox = keyContext.findRenderObject();
    // if (keyContext != null) {
    //   RenderObject menuBox = keyContext.findRenderObject();// ?? SizedBox(width: 0, height, 0);
    //   // var menuSize = menuBox.size;
    //   // logger.d();
    // }
    // double left = 0;
    // double top = 0;

    double left = position.dx - widgetContextMenuItemPaddingHorizontal;
    double top = position.dy + 10;

    if (left < 0) left = 10;

    // logger.d(top);



    return OverlayEntry(
        builder: (context) {
          return Positioned(
            left: left,
            top: top,
            // width: widget.width,
            child: MouseRegion(
                onExit: (e) {
                  _overlayEntry!.remove();
                },
                child: menu
            ),
          );
        },
    );
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onSecondaryTapDown: (details) {
      // logger.d(details.globalPosition, 'tap right mouse');
      // if (_overlayEntry != null) {
      //   _overlayEntry!.remove();
      // }
        _overlayEntry = _createOverlayEntry(context, details.globalPosition);
        Overlay.of(context)!.insert(_overlayEntry!);
      },
      child: widget.child,
    );
  }
}

class WidgetContextMenuItem extends StatelessWidget {
  final String title;
  final Function onTap;
  final bool disabled;
  final double fontSize;

  const WidgetContextMenuItem({
    Key? key,
    required this.title,
    required this.onTap,
    this.disabled = false,
    this.fontSize = 14.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget item([bool onHover = false]) {
      return Container(
          padding: const EdgeInsets.symmetric(horizontal: widgetContextMenuItemPaddingHorizontal, vertical: 10.0),
          // child: Text(title,
          //     style: TextStyle(
          //         color: disabled ? Colors.grey[300] : Colors.grey[700],
          //         fontSize: 14,
          //         fontWeight: FontWeight.w400,
          //         fontStyle: FontStyle.normal
          //     ),
          // ),
          child: DefaultTextStyle(
            child: Text(title),
            style: TextStyle(
                color: disabled ? Colors.grey[400] : Colors.black,
                fontSize: fontSize,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal
            ),
          ),
          color: onHover ? Colors.grey[300] : Colors.transparent);
    }

    if (disabled) {
      return item();
    }

    return GestureDetector(
      onTap: () {
          onTap();
      },
      child: HoverWidget(
        onHover: (e) {
          // logger.d('menu item exit');
        },

        child: item(),
        hoverChild: item(true),
      ),
    );
  }
}
class WidgetContextMenuDivider extends StatelessWidget {
  const WidgetContextMenuDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 0,
      thickness: 1,
      indent: 0,
      endIndent: 0,
      color: Colors.grey[400],
    );
  }
}