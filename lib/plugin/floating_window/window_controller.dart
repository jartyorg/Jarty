import 'dart:ui';

import 'window_controller_impl.dart';

/// The [WindowController] instance that is used to control this window.
abstract class WindowController {
  WindowController();

  factory WindowController.fromWindowId(int id) {
    return WindowControllerMainImpl(id);
  }

  factory WindowController.main() {
    return WindowControllerMainImpl(0);
  }

  /// The id of the window.
  /// 0 means the main window.
  int get windowId;

  /// Close the window.
  Future<void> close();


  /// Show the window.
  Future<void> show();


  /// Center the window on the screen.
  Future<void> center();

  /// Hide the window.
  Future<void> hide();

  /// Set the window frame rect.
  Future<void> setFrame(Rect frame);
}
