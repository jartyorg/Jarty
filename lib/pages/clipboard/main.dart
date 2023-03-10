import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:isar/isar.dart';
import 'package:jarty/models/clipboard_history.dart';
import 'package:jarty/utils/debounce.dart';
import 'package:jarty/utils/isarUtil.dart';
import 'package:window_manager/window_manager.dart';

class ClipboardPage extends StatefulWidget {
  const ClipboardPage({Key? key}) : super(key: key);

  @override
  State<ClipboardPage> createState() => _ClipboardPageState();
}

class _ClipboardPageState extends State<ClipboardPage> {
  List<ClipboardHistory> _histories = [];
  int _selectIndex = 0;
  final FocusNode _keyBordFocusNode = FocusNode();

  final Debounce inputDebounce =
      Debounce(delay: const Duration(milliseconds: 100));

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _listviewKey = GlobalKey();
  final double _listItemHeight = 26.0;

  static const int _animationDuration = 200;
  static const Curve _animationCurve = Curves.easeInOut;

  HotKey digit1 = HotKey(
    KeyCode.digit1,
    modifiers: [KeyModifier.meta],
    scope: HotKeyScope.inapp, // Set as inapp-wide hotkey.
  );
  HotKey digit2 = HotKey(
    KeyCode.digit2,
    modifiers: [KeyModifier.meta],
    scope: HotKeyScope.inapp, // Set as inapp-wide hotkey.
  );
  HotKey digit3 = HotKey(
    KeyCode.digit3,
    modifiers: [KeyModifier.meta],
    scope: HotKeyScope.inapp, // Set as inapp-wide hotkey.
  );
  HotKey digit4 = HotKey(
    KeyCode.digit4,
    modifiers: [KeyModifier.meta],
    scope: HotKeyScope.inapp, // Set as inapp-wide hotkey.
  );
  HotKey digit5 = HotKey(
    KeyCode.digit5,
    modifiers: [KeyModifier.meta],
    scope: HotKeyScope.inapp, // Set as inapp-wide hotkey.
  );
  HotKey digit6 = HotKey(
    KeyCode.digit6,
    modifiers: [KeyModifier.meta],
    scope: HotKeyScope.inapp, // Set as inapp-wide hotkey.
  );
  HotKey digit7 = HotKey(
    KeyCode.digit7,
    modifiers: [KeyModifier.meta],
    scope: HotKeyScope.inapp, // Set as inapp-wide hotkey.
  );
  HotKey digit8 = HotKey(
    KeyCode.digit8,
    modifiers: [KeyModifier.meta],
    scope: HotKeyScope.inapp, // Set as inapp-wide hotkey.
  );
  HotKey digit9 = HotKey(
    KeyCode.digit9,
    modifiers: [KeyModifier.meta],
    scope: HotKeyScope.inapp, // Set as inapp-wide hotkey.
  );

  @override
  void initState() {
    windowManager.setResizable(false);
    windowManager.setOpacity(0.97);
    _keyBordFocusNode.requestFocus();
    _initHotKey();
    IsarUtil.instance.isar.clipboardHistorys
        .where()
        .sortByCreateTimeDesc()
        .findAll()
        .then((value) => setState(() {
              _histories = value;
            }));
    super.initState();
  }

  //
  Future<void> _initHotKey() async {
    // For hot reload, `unregisterAll()` needs to be called.
    await hotKeyManager.register(digit1, keyDownHandler: (hotKey) {
      setClipboardData(0);
    });
    await hotKeyManager.register(digit2, keyDownHandler: (hotKey) {
      setClipboardData(1);
    });
    await hotKeyManager.register(digit3, keyDownHandler: (hotKey) {
      setClipboardData(2);
    });
    await hotKeyManager.register(digit4, keyDownHandler: (hotKey) {
      setClipboardData(3);
    });
    await hotKeyManager.register(digit5, keyDownHandler: (hotKey) {
      setClipboardData(4);
    });
    await hotKeyManager.register(digit6, keyDownHandler: (hotKey) {
      setClipboardData(5);
    });
    await hotKeyManager.register(digit7, keyDownHandler: (hotKey) {
      setClipboardData(6);
    });
    await hotKeyManager.register(digit8, keyDownHandler: (hotKey) {
      setClipboardData(7);
    });
    await hotKeyManager.register(digit9, keyDownHandler: (hotKey) {
      setClipboardData(8);
    });
  }

  @override
  void dispose() {
    hotKeyManager.unregister(digit1);
    hotKeyManager.unregister(digit2);
    hotKeyManager.unregister(digit3);
    hotKeyManager.unregister(digit4);
    hotKeyManager.unregister(digit5);
    hotKeyManager.unregister(digit6);
    hotKeyManager.unregister(digit7);
    hotKeyManager.unregister(digit8);
    hotKeyManager.unregister(digit9);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
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
                onChanged: (text) {
                  inputDebounce.run(() {
                    IsarUtil.instance.isar.clipboardHistorys
                        .filter()
                        .contentContains(text)
                        .sortByCreateTimeDesc()
                        .findAll()
                        .then((value) => setState(() {
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
                      padding:
                          const EdgeInsets.only(top: 8.0, left: 15, right: 15),
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
    );
  }

  void setClipboardData(index) {
    String? text = _histories.elementAt(index).content;
    if (text != null && text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
    }
    Future.delayed(const Duration(milliseconds: 200), () {
      windowManager.hide();
    });
  }

  void _animateToTargetOffset(double targetOffset) {
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: _animationDuration),
      curve: _animationCurve,
    );
  }

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
