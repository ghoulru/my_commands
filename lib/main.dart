// import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:process_run/shell.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

/*
 *
 * Билдим
 * flutter build windows
 *  создает пакет https://levelup.gitconnected.com/create-windows-apps-with-flutter-cd287c9a029c
 * flutter pub run msix:create
 *
 * работа с окном
 * https://github.com/leanflutter/window_manager
 *
 *
 */
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowManager.instance.waitUntilReadyToShow().then((_) async {
    // Set to frameless window
    // await WindowManager.instance.setAsFrameless();
    // await windowManager.setTitleBarStyle('hidden');
    await windowManager.setSize(Size(800, 600));
    await windowManager.center();
    // await windowManager.show();
    await windowManager.hide();
    await windowManager.setSkipTaskbar(true);
  });

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  final SystemTray _systemTray = SystemTray();
  // final AppWindow _appWindow = AppWindow();

  static const _nodeVersions = <String>['17.5.0', '16.14.0', '13.14.0'];
  String _currentNodeVersion = '';

  // String _trayInfo = "";

  @override
  void initState() {
    windowManager.addListener(this);
    init();

    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);

    super.dispose();
  }

  @override
  void onWindowClose() async {

    bool _isPreventClose = await windowManager.isPreventClose();
    // debugPrint("onWindowClose prevented=$_isPreventClose");
    if (_isPreventClose) {
      // debugPrint("onWindowClose prevented");
      await windowManager.hide();

    }
  }

  void init() async {
    debugPrint("init");
    await windowManager.setPreventClose(true);
    setState(() {});

    var controller = ShellLinesController();
    var shell = Shell(stdout: controller.sink, verbose: false);
    controller.stream.listen((event) async {
      // Handle output
      String version = event.replaceFirst(RegExp("v"), "");
      // print(">$event< $version");

      setState(() {
        _currentNodeVersion = version;
      });

      await initSystemTray();
      setInfo(1);
    });
    await shell.run('nvm current');
    // setInfo(2);
  }

  setInfo(int i) {
    String tip = "Node - $_currentNodeVersion";
    debugPrint("$i = $tip");
    _systemTray.setToolTip(tip);
  }

  //async
  changeNodeVersion(String version) async {
    debugPrint("changeNodeVersion to $version");
    var shell = Shell(verbose: false);
    // await shell.run('echo 321');
    await shell.run("nvm use $version");
    setState(() {
      _currentNodeVersion = version;
    });
    setInfo(5);
    _systemTray.setContextMenu(getMenu());
  }

  getMenu() {
    final nodeVersionsItems = <MenuItem>[];
    _nodeVersions.forEach((v) => nodeVersionsItems.add(MenuItem(
        label: v + (_currentNodeVersion == v ? " - current" : ""),
        onClicked: () => changeNodeVersion(v),
        enabled: _currentNodeVersion != v)));

    final menu = [
      SubMenu(label: 'Node.js версии', children: nodeVersionsItems),
      // MenuItem(label: 'Show', onClicked: _appWindow.show),
      // MenuItem(label: 'Hide', onClicked: _appWindow.hide),
      MenuSeparator(),
      // MenuItem(label: 'Закрыть', onClicked: _appWindow.close),
      MenuItem(
          label: 'Закрыть',
          onClicked: () async {
            await windowManager.setPreventClose(false);
            await windowManager.close();
          }),
    ];

    return menu;
  }

  Future<void> initSystemTray() async {
    debugPrint("initSystemTray $_currentNodeVersion");

    const String path = 'assets/zombie.ico';

    // We first init the systray menu and then add the menu entries
    await _systemTray.initSystemTray(
      title: "My Commands",
      // toolTip: _trayInfo,
      iconPath: path,
    );

    await _systemTray.setContextMenu(getMenu());

    // handle system tray event
    _systemTray.registerSystemTrayEventHandler((eventName) async {
      // debugPrint("eventName: $eventName");
      if (eventName == "leftMouseDown") {
      } else if (eventName == "leftMouseUp") {
        // await windowManager.show();
      } else if (eventName == "rightMouseDown") {
      } else if (eventName == "rightMouseUp") {
        _systemTray.popUpContextMenu();
        // _appWindow.show();

      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
            child: Text(
          'Hello World',
        )),
      ),
    );
  }

  // @override
  // void onWindowFocus() {
  //   // Make sure to call once.
  //   // setState(() {});
  //   // do something
  //   // init();
  //
  // }
}
