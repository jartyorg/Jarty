import 'dart:io';

import 'package:clipboard_watcher/clipboard_watcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:jarty/models/clipboard_history.dart';
import 'package:jarty/pages/clipboard/main.dart';
import 'package:jarty/utils/isarUtil.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';

void main() async {
  await _initWindowsManger();
  await _initHotKey();
  await _initTray();
  await IsarUtil.instance.init();
  runApp(const MyApp());
}

Future<void> _initWindowsManger() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    MenuItem(
      label: 'show_window',
    ),
    MenuItem.separator(),
    MenuItem(
      label: 'exit_app',
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
      await windowManager.show();
      await windowManager.focus();
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

class _MyAppState extends State<MyApp> with ClipboardListener, TrayListener ,WindowListener{
  @override
  void initState() {
    // TODO: implement initState
    windowManager.addListener(this);
    trayManager.addListener(this);
    clipboardWatcher.addListener(this);
    // start watch
    clipboardWatcher.start();

    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    trayManager.removeListener(this);
    clipboardWatcher.stop();
    clipboardWatcher.removeListener(this);
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const ClipboardPage(),
    );
  }

  @override
  void onClipboardChanged() async {
    ClipboardData? newClipboardData =
        await Clipboard.getData(Clipboard.kTextPlain);

    if (newClipboardData != null &&
        newClipboardData.text != null &&
        newClipboardData.text!.trim() != "") {
      final history = ClipboardHistory()
        ..content = newClipboardData!.text
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
