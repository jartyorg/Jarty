import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:isar/isar.dart';
import 'package:jarty/models/clipboard_history.dart';
import 'package:jarty/plugin/floating_window/floating_window.dart';
import 'package:jarty/plugin/floating_window/window_controller.dart';
import 'package:jarty/utils/debounce.dart';
import 'package:jarty/utils/isar_util.dart';

class ClipboardPage extends StatefulWidget {
  const ClipboardPage({Key? key, required this.windowController})
      : super(key: key);

  final WindowController windowController;

  @override
  State<ClipboardPage> createState() => _ClipboardPageState();
}

class _ClipboardPageState extends State<ClipboardPage> {
  /// clipboard history
  List<ClipboardHistory> _histories = [];

  /// select index tell you which item is selected
  int _selectIndex = 0;

  /// keyBored  listener widget  Focus need
  final FocusNode _keyBordFocusNode = FocusNode();

  /// textField widget  Focus need
  final FocusNode _inputFocusNode = FocusNode();

  /// textField change event debounce
  final Debounce inputDebounce =
      Debounce(delay: const Duration(milliseconds: 100));

  /// listView controller
  final ScrollController _scrollController = ScrollController();

  /// listView key
  final GlobalKey _listviewKey = GlobalKey();

  /// listView item height
  final double _listItemHeight = 26.0;

  /// listView scroll animation duration
  static const int _animationDuration = 200;

  /// listView  animation curve
  static const Curve _animationCurve = Curves.easeInOut;

  /// generate history hot key
  List<HotKey> hotKeys = [
    KeyCode.digit1,
    KeyCode.digit2,
    KeyCode.digit3,
    KeyCode.digit4,
    KeyCode.digit5,
    KeyCode.digit6,
    KeyCode.digit7,
    KeyCode.digit8,
    KeyCode.digit9
  ]
      .map((keyCode) => HotKey(
            keyCode,
            modifiers: [KeyModifier.meta],
            scope: HotKeyScope.inapp, // Set as inapp-wide hotkey.
          ))
      .toList();

  /// esc hotkey
  HotKey escHotkey = HotKey(KeyCode.escape, scope: HotKeyScope.inapp);

  @override
  void initState() {
    _initHotKey();
    /// get all clipboard history order by create time desc
    IsarUtil.instance.isar.clipboardHistorys
        .where()
        .sortByCreateTimeDesc()
        .findAll()
        .then((value) => setState(() {
              _histories = value;
            }));
    super.initState();
  }

  /// init all hotkey
  Future<void> _initHotKey() async {
    for (var hotKey in hotKeys) {
      await hotKeyManager.register(hotKey, keyDownHandler: (hk) {
        setClipboardData(hotKeys.indexOf(hotKey));
      });
    }

    await hotKeyManager.register(escHotkey, keyDownHandler: (_) {
      widget.windowController.close();
    });
  }

  ///unregister  all hotkey
  Future<void> _unregisterHotKey() async {
    for (var hotKey in hotKeys) {
      await hotKeyManager.unregister(hotKey);
    }

    hotKeyManager.unregister(escHotkey);
  }

  @override
  void dispose() {
    _unregisterHotKey();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyBordFocusNode.requestFocus();
      _inputFocusNode.requestFocus();
    });

    return MaterialApp(
      home: RawKeyboardListener(
        onKey: (event) {
          if (event is RawKeyDownEvent) {
            if (_scrollController.position.isScrollingNotifier.value == false) {
              if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                _selectListItem(_selectIndex - 1);
              } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                _selectListItem(_selectIndex + 1);
              } else if (event.logicalKey == LogicalKeyboardKey.enter) {
                setClipboardData(_selectIndex);
              }
            }
          }
        },
        focusNode: _keyBordFocusNode,
        child: Scaffold(
            body: Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
                color: Colors.grey[200]!,
                offset: const Offset(1, 1),
                spreadRadius: 40)
          ]),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  focusNode: _inputFocusNode,
                  onChanged: (text) {
                    inputDebounce.run(() {
                      IsarUtil.instance.isar.clipboardHistorys
                          .filter()
                          .contentContains(text)
                          .sortByCreateTimeDesc()
                          .findAll()
                          .then((value) => setState(() {
                                _selectIndex = 0;
                                _histories = value;
                              }));
                    });
                  },
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[350],
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.only(bottom: 25.0, left: 10, right: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: ListView.builder(
                        key: _listviewKey,
                        controller: _scrollController,
                        itemCount: _histories.length,
                        padding: EdgeInsets.zero,
                        itemExtent: _listItemHeight,
                        itemBuilder: (context, index) {
                          return MouseRegion(
                            onHover: (event) {
                              setState(() {
                                _selectIndex = index;
                              });
                            },
                            child: GestureDetector(
                              onTap: () {
                                setClipboardData(_selectIndex);
                              },
                              child: Container(
                                color: _selectIndex == index
                                    ? Colors.grey[350]
                                    : Colors.transparent,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10),
                                      child: Image.asset(
                                        "images/logo.png",
                                        width: 25,
                                        height: 25,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        _histories[index].content!.trim(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 10, left: 10),
                                      child: _selectIndex == index
                                          ? const Text("↩︎")
                                          : index < 9
                                              ? Text("⌘${index + 1}")
                                              : Container(),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, left: 15, right: 15),
                        child: Container(
                          child: Text(_histories.isNotEmpty
                              ? _histories.elementAt(_selectIndex).content!
                              : ""),
                        ),
                      ))
                    ],
                  ),
                ),
              )
            ],
          ),
        )),
      ),
    );
  }

  /// set clipboard data
  void setClipboardData(index) async {
    if (index < _histories.length) {
      ClipboardHistory history = _histories.elementAt(index);
      String? text = history.content;
      if (text != null && text.isNotEmpty) {
        FloatingWindow.invokeMethod(0, "onClipboardSetData", text);
        Clipboard.setData(ClipboardData(text: text));
        await IsarUtil.instance.isar.writeTxn(() async {
          final needUpdateHistory =
              await IsarUtil.instance.isar.clipboardHistorys.get(history.id);
          needUpdateHistory!.createTime = DateTime.now();
          await IsarUtil.instance.isar.clipboardHistorys
              .put(needUpdateHistory!); // 修改数据
        });
      }
      widget.windowController.close();
    }
  }

  /// scroll to target position
  void _animateToTargetOffset(double targetOffset) {
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: _animationDuration),
      curve: _animationCurve,
    );
  }

  /// calculate scroll and select
  void _selectListItem(int index) {
    double targetScrollOffset = 0;

    if (index < 0) {
      index = _histories.length - 1;
      targetScrollOffset = _scrollController.position.maxScrollExtent;
      _animateToTargetOffset(targetScrollOffset);
    } else if (index >= _histories.length) {
      index = 0;
      targetScrollOffset = _scrollController.position.minScrollExtent;
      _animateToTargetOffset(targetScrollOffset);
    } else {
      RenderObject? listViewRenderObject =
          _listviewKey.currentContext?.findRenderObject();
      if (listViewRenderObject == null) {
        return;
      }
      RenderBox listViewRenderBox = listViewRenderObject as RenderBox;
      double listViewHeight = listViewRenderBox.size.height;
      double targetOffSet = _listItemHeight * index;
      double upperBoundary = _scrollController.offset;
      double underBorder = _scrollController.offset +
          (listViewHeight / _listItemHeight).floor() * _listItemHeight;

      if (targetOffSet >= underBorder || targetOffSet < upperBoundary) {
        if (targetOffSet >= underBorder) {
          targetScrollOffset = underBorder;
        }
        if (targetOffSet < upperBoundary) {
          targetScrollOffset =
              upperBoundary > 0 ? upperBoundary - _listItemHeight : underBorder;
        }
        _animateToTargetOffset(targetScrollOffset);
      }
    }

    setState(() {
      _selectIndex = index;
    });
  }
}
