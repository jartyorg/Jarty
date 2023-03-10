import 'package:isar/isar.dart';

part 'clipboard_history.g.dart';

@collection
class ClipboardHistory {
  Id id = Isar.autoIncrement;

  String? content;

  DateTime? createTime;

}
