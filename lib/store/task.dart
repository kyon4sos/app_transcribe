import 'dart:developer';

import 'package:app_transcribe/model/task.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();
final log = Logger('TaskProvider');

class TaskProvider with ChangeNotifier {
  TaskProvider() {
    log.info('TaskProvider init');
    initStorage();
  }
  bool isWork = false;

  List<Task> _tasks = [];
  String search = "";
  late Isar isar;
  List<Task> get tasks => search.isEmpty
      ? _tasks
      : _tasks.where((element) => element.fileName.contains(search)).toList();

  initStorage() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [TaskSchema],
      directory: dir.path,
    );
    _tasks = await isar.tasks.where().findAll();
    notifyListeners();
  }

  void add() async {
    final res = await FilePicker.platform.pickFiles();
    if (res == null) {
      return;
    }
    final files = res.files.first;
    log.info(files.path!);
    final task = Task(
        id: uuid.v4(),
        path: files.path!,
        updateTime: DateTime.now().toString(),
        status: Status.ready,
        fileName: files.name);
    _tasks.add(task);
    await isar.writeTxn(() async {
      await isar.tasks.put(task);
    });
    notifyListeners();
  }

  join(Task task) {
    log.info("join");
    task.status = Status.wait;
    notifyListeners();
  }

  start(Task task) {
    log.info("start");
    task.status = Status.start;
    notifyListeners();
  }

  complete(Task task) async {
    log.info("complete");
    task.status = Status.complete;
    int index = _tasks.indexOf(task);
    index != -1 ? _tasks[index] = task : null;
    await isar.writeTxn(() async {
      await isar.tasks.put(task);
    });

    notifyListeners();
  }

  remove(Task task) async {
    _tasks.remove(task);
    await isar.writeTxn(() async {
      await isar.tasks.delete(task.isarId);
    });
    notifyListeners();
  }

  void filter(String search) {
    this.search = search;
    notifyListeners();
  }
}
