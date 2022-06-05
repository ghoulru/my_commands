import 'package:flutter/material.dart' hide MenuItem;
import 'package:process_run/shell.dart';
import 'package:system_tray/system_tray.dart' as system_tray;
import 'package:window_manager/window_manager.dart';
import 'screens/passwords/passwords.dart';
import 'objectbox.dart';
// import 'objectbox.g.dart';
// import 'utils/app_models.dart';

enum ScreenType {
  passwords,
  teplo,
}

// ignore: constant_identifier_names
const bool DEBUG = true;

late ObjectBox objectbox;
late List<dynamic> settings;

/*
 *
 * Билдим
 * flutter build windows --no-sound-null-safety
 *  изза вертикальных табов
 *  создает пакет https://levelup.gitconnected.com/create-windows-apps-with-flutter-cd287c9a029c
 * flutter pub run msix:create
 *
 * работа с окном
 * https://github.com/leanflutter/window_manager
 *
 *
 *
 */
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  objectbox = await ObjectBox.create();
  // final Box settingsBox = objectbox.store.box<Settings>();
  // settings = settingsBox.getAll();



  WindowManager.instance.waitUntilReadyToShow().then((_) async {
    // Set to frameless window
    // await WindowManager.instance.setAsFrameless();
    // await windowManager.setTitleBarStyle('hidden');
    await windowManager.setSize(const Size(1200, 1000));
    await windowManager.center();
    // await windowManager.show();
    await windowManager.hide();
    // await windowManager.setSkipTaskbar(true);
  });


  // print("---main start---");
  // print(objectbox.store);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener, SingleTickerProviderStateMixin {
  final system_tray.SystemTray _systemTray = system_tray.SystemTray();
  // final CopyFiles _copyFiles = CopyFiles();

  static const _nodeVersions = <String>['17.5.0', '16.14.0', '13.14.0'];
  String _currentNodeVersion = '';

  late TabController _mainTabsController;
  final Map<String, dynamic> _currentScreen = {
    "type": ScreenType.passwords,
    "title": Passwords.title,
  };

  // String _trayInfo = "";

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    init();

    _mainTabsController = TabController(vsync: this, length: 2);


  }

  @override
  void dispose() {
    // print('---main dispose---');
    windowManager.removeListener(this);
    _mainTabsController.dispose();
    objectbox.store.close();


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


    debugPrint("main init");
    await windowManager.setPreventClose(true);
    windowManager.setTitle(_currentScreen['title']);
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



      // final categoryTabsBox = objectbox.store.box<CategoryTabModel>();
      // final tabMy = CategoryTabModel()
      //   ..name = 'my'
      //   ..sort = 1;
      // categoryTabsBox.put(tabMy);
      //
      // final tabs = categoryTabsBox.getAll();
      // print(tabs);
    });
    await shell.run('nvm current');
    // debugPrint("init 2");

    // switch (_currentScreen) {
    //   case ScreenType.passwords:
    //     await windowManager.setTitle(Passwords.title);
    //     break;
    //   default:
    //
    //     break;
    // }

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
    final nodeVersionsItems = <system_tray.MenuItem>[];
    for (String v in _nodeVersions) {
      nodeVersionsItems.add(
          system_tray.MenuItem(
            label: v + (_currentNodeVersion == v ? " - current" : ""),
            onClicked: () => changeNodeVersion(v),
            enabled: _currentNodeVersion != v,
          )
      );
    }

    final menu = [
      system_tray.SubMenu(label: 'Node.js версии', children: nodeVersionsItems),
      // MenuItem(
      //     label: 'Закрыть',
      //     onClicked: () async {
      //       var shell = Shell(verbose: false);
      //       await shell.run('cd "C:\Users\LouD\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup" && start .');
      //
      //     }),
      // MenuItem(label: 'Show', onClicked: _appWindow.show),
      // MenuItem(label: 'Hide', onClicked: _appWindow.hide),

      system_tray.MenuSeparator(),
      // MenuItem(label: 'Закрыть', onClicked: _appWindow.close),
      system_tray.MenuItem(
          label: 'Выход',
          onClicked: () async {
            await windowManager.setPreventClose(false);
            await windowManager.close();
          }),
    ];

    return menu;
  }

  Future<void> initSystemTray() async {
    debugPrint("initSystemTray $_currentNodeVersion");

    // const String path = DEBUG ? 'assets/process.ico' : 'assets/zombie.ico';
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
        await windowManager.show();
        // await windowManager.center();
      } else if (eventName == "rightMouseDown") {
      } else if (eventName == "rightMouseUp") {
        _systemTray.popUpContextMenu();
        // _appWindow.show();

      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Widget screen = Passwords();
    // TeploinformForm()
    // debugPrint("main build " + _currentScreen.toString());
    // debugPrintStack(label: '123', maxFrames: 2);
    // print(StackTrace.current.toString());

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(34.0),
          child: AppBar(
            // title: const Text("Name"),
            elevation: 0,
            backgroundColor: Colors.blueGrey[500],
            bottom: TabBar(
                controller: _mainTabsController,
                isScrollable: true,
                indicatorColor: Colors.black,
                tabs: [
                  Tab(text: Passwords.title, height: 30),
                  const Tab(text: "Чето еще", height: 30),
                ]
            ),
          ),
        ),
        body: TabBarView(
            controller: _mainTabsController,
            children: [
              Passwords(store: objectbox.store),
              const Text("Чето еще вывод")
            ]
        ),
        // body: const Center(
        //   child: Passwords(), //Text('Hello World')
        // ),
      ),
    );
  }

  @override
  void onWindowFocus() {
    // Make sure to call once.
    setState(() {});
    // do something
    // init();
  }

  // @override
  // void onWindowResize() async {
  //   Size sizes = await windowManager.getSize();
  //   print(sizes.width);
  //
  //   // settingsBox.put()
  // }
}
