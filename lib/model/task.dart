import 'package:isar/isar.dart';

import 'package:app_transcribe/utils/hash.dart';

part 'task.g.dart';

enum Status { start, ready, wait, complete }

@collection
class Task {
  String? id;
  Id get isarId => fastHash(id!);
  String path;
  String fileName;
  String updateTime;
  String? result;

  @enumerated
  Status status;
  Task(
      {required this.id,
      required this.path,
      required this.updateTime,
      required this.status,
      required this.fileName});
}
