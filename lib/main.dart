import 'dart:io';

import 'package:clipboard_watcher/clipboard_watcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:jarty/models/clipboard_history.dart';
import 'package:jarty/pages/clipboard/main.dart';
import 'package:jarty/pages/home/main.dart';
import 'package:jarty/plugin/floating_window/floating_window.dart';
import 'package:jarty/plugin/floating_window/window_controller.dart';
import 'package:jarty/utils/isar_util.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarUtil.instance.init();
  if (args.isNotEmpty && args.first == "floating_window") {
    final windowId = int.parse(args[1]);
    runApp(ClipboardPage(
        windowController: WindowController.fromWindowId(windowId)));
  } else {
    await _initHotKey();
    await _initWindowsManger();
    await _initTray();
    runApp(const MyApp());
  }
}

Future<void> _initWindowsManger() async {
  // Must add this line.
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(633, 463),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: true,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.hide();
    await windowManager.setAsFrameless();
  });
}

Future<void> _initTray() async {
  await trayManager.setIcon(
    Platform.isWindows ? 'images/logo.ico' : 'images/logo.png',
  );
  List<MenuItem> items = [
    MenuItem.separator(),
    MenuItem(
      label: 'Quit',
      onClick: (MenuItem menuItem){
        SystemNavigator.pop();
      }
    ),
  ];
  await trayManager.setContextMenu(Menu(items: items));
}

Future<void> _initHotKey() async {
  // For hot reload, `unregisterAll()` needs to be called.
  await hotKeyManager.unregisterAll();

  HotKey clipboardHistoryKey = HotKey(
    KeyCode.keyC,
    modifiers: [KeyModifier.alt, KeyModifier.meta],
    scope: HotKeyScope.system, // Set as inapp-wide hotkey.
  );

  await hotKeyManager.register(
    clipboardHistoryKey,
    keyDownHandler: (hotKey) async {
      final window = await FloatingWindow.createWindow();
      window
        ..setFrame(const Offset(0, 0) & const Size(633, 463))
        ..center()
        ..show();
      // await windowManager.show();
      // await windowManager.focus();
    },
    // Only works on macOS.
    keyUpHandler: (hotKey) {},
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>
    with ClipboardListener, TrayListener, WindowListener {
  String jartyClipboardSetData = "";

  @override
  void initState() {
    // TODO: implement initState
    windowManager.addListener(this);
    trayManager.addListener(this);
    clipboardWatcher.addListener(this);
    // start watch
    clipboardWatcher.start();
    FloatingWindow.setMethodHandler(_handleMethodCallback);
    super.initState();
  }

  Future<dynamic> _handleMethodCallback(MethodCall call,
      int fromWindowId) async {
    if (call.arguments.toString() == "ping") {
      return "pong";
    }

    if (call.method == "onClipboardSetData") {
      setState(() {
        jartyClipboardSetData = call.arguments.toString();
      });
    }
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    trayManager.removeListener(this);
    clipboardWatcher.stop();
    clipboardWatcher.removeListener(this);
    FloatingWindow.setMethodHandler(null);
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(
        title: "1111",
      ),
    );
  }

  @override
  void onClipboardChanged() async {
    ClipboardData? newClipboardData =
    await Clipboard.getData(Clipboard.kTextPlain);

    if (newClipboardData?.text?.trim() == jartyClipboardSetData) {
      setState(() {
        jartyClipboardSetData = "";
      });
      return;
    }

    if (newClipboardData != null &&
        newClipboardData.text != null &&
        newClipboardData.text!.trim() != "") {
      final history = ClipboardHistory()
        ..content = newClipboardData!.text!.trim()
        ..createTime = DateTime.now();
      await IsarUtil.instance.isar.writeTxn(() async {
        await IsarUtil.instance.isar.clipboardHistorys
            .put(history); // 将新用户数据写入到 Isar
      });
    }
  }

  @override
  void onWindowBlur() {
    windowManager.hide();
  }

  @override
  void onTrayIconMouseDown() {
    // do something, for example pop up the menu
    trayManager.popUpContextMenu();
  }


}
