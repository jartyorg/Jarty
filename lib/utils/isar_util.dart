import 'package:isar/isar.dart';
import 'package:jarty/models/clipboard_history.dart';

class IsarUtil {
  static IsarUtil? _instance;

  static IsarUtil get instance {
    _instance ??= IsarUtil._privateConstructor();
    return _instance!;
  }

  IsarUtil._privateConstructor();

  late Isar isar;

  Future<void> init() async {
    isar = await Isar.open([ClipboardHistorySchema]);
  }

}
