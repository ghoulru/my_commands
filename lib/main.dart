// import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:process_run/shell.dart';
import 'package:system_tray/system_tray.dart';
// import 'package:process_run/cmd_run.dart';

/*
 *
 * Билдим
 * flutter build windows
 *  создает пакет https://levelup.gitconnected.com/create-windows-apps-with-flutter-cd287c9a029c
 * flutter pub run msix:create
 *
 *
 *
 */
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}



class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SystemTray _systemTray = SystemTray();
  final AppWindow _appWindow = AppWindow();

  static const _nodeVersions = <String> ['17.5.0', '16.14.0', '13.14.0'];
  String _currentNodeVersion = '';

  // String _trayInfo = "";


  @override
  void initState() {
    super.initState();
    _appWindow.hide();

    init();


  }
  @override
  void dispose() {
    super.dispose();
  }

  init() async {
    debugPrint("init");
    var controller = ShellLinesController();
    var shell = Shell(stdout: controller.sink, verbose: false);
    controller.stream.listen((event) {
      // Handle output
      String version = event.replaceFirst(RegExp("v"), "");
      // print(">$event< $version");

      setState(() {
        _currentNodeVersion = version;
      });
      setInfo();
    });
    await shell.run('nvm current');

    initSystemTray();
  }

  setInfo() {
    String ti = "Node - $_currentNodeVersion";

    _systemTray.setToolTip(ti);
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
    setInfo();
    _systemTray.setContextMenu(getMenu());
  }

  getMenu() {
    final nodeVersionsItems = <MenuItem> [];
    _nodeVersions.forEach((v) => nodeVersionsItems.add(
        MenuItem(
            label: v,// + (_currentNodeVersion == v ? "* " : "" ),
            onClicked: () => changeNodeVersion(v),
            enabled: _currentNodeVersion != v
        )
    ));



    final menu = [
      SubMenu(label: 'Node.js версии', children: nodeVersionsItems),
      // MenuItem(label: 'Show', onClicked: _appWindow.show),
      // MenuItem(label: 'Hide', onClicked: _appWindow.hide),
      MenuSeparator(),
      MenuItem(label: 'Закрыть', onClicked: _appWindow.close),
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
    _systemTray.registerSystemTrayEventHandler((eventName) {
      // debugPrint("eventName: $eventName");
      if (eventName == "leftMouseDown") {
      } else if (eventName == "leftMouseUp") {
        _systemTray.popUpContextMenu();
      } else if (eventName == "rightMouseDown") {
      } else if (eventName == "rightMouseUp") {
        _appWindow.show();
      }
    });


  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
            child:
            Text (
              'Hello World',
            )
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();


}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times 2:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
