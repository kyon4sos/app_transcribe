import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:app_transcribe/store/task.dart';
import 'package:app_transcribe/theme/color.dart';
import 'package:app_transcribe/whisper_bindings_generated.dart';
import 'package:app_transcribe/common/status_key.dart';
import 'package:app_transcribe/components/task_item.dart';
import 'package:app_transcribe/model/task.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;
import 'package:ffi/ffi.dart' as ffi;
import 'package:app_transcribe/whisper.dart';
import 'package:clipboard/clipboard.dart';

final log = Logger('Home');

Whisper whisper = Whisper();

String transcribe(Request req) {
  final ctx = Pointer<whisper_context>.fromAddress(req.address);
  return whisper.transcribeFromPath(ctx, req.task.path);
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  List<Task> get taskList =>
      Provider.of<TaskProvider>(context, listen: false).tasks;
  late Task _currentSelectTask;
  late Pointer<whisper_context> ctx;
  late FToast fToast;
  final List<Task> job = [];
  bool isWorking = false;

  @override
  initState() {
    init();
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  @override
  dispose() {
    ffi.calloc.free(ctx);
    super.dispose();
  }

  init() async {
    log.shout(" ==== init ====");
    Whisper whisper = Whisper();
    final dir = await getApplicationDocumentsDirectory();
    const model = "assets/ggml-tiny.en.bin";
    final modelDir = p.join(dir.path, "models");
    final _dir = Directory(modelDir);
    final file = File(p.join(modelDir, "ggml-tiny.en.bin"));
    log.info(" ==== ${await file.exists()} ====");
    if (!await file.exists()) {
      log.info(" ==== copy model file ====");
      await _dir.create(recursive: true);
      final bytes = await rootBundle.load(model);
      await file.writeAsBytes(bytes.buffer.asInt8List());
    }
    ctx = whisper.initFromFile(file.path);
    // ctx = whisper.initFromFile(file.path);
  }

  _showToast() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.greenAccent,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check),
          SizedBox(
            width: 12.0,
          ),
          Text("复制成功"),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
    );
  }

  var overlayEntry = OverlayEntry(builder: (context) {
    return const Icon(Icons.more_horiz_outlined);
  });
  get modalBody => Scaffold(
        backgroundColor: AppTheme.bgColor,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(top: 20),
                color: Colors.black12,
                // height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.grey,
                        )),
                    Expanded(
                        child: Text(
                      _currentSelectTask.path ?? "",
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    )),
                    PopupMenuButton(
                        icon: const Icon(
                          Icons.more_horiz_outlined,
                          color: Colors.grey,
                        ),
                        position: PopupMenuPosition.under,
                        color: Colors.black,
                        surfaceTintColor: Colors.black,
                        padding: const EdgeInsets.all(2),
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                              padding: const EdgeInsets.all(2),
                              child: TextButton.icon(
                                  onPressed: () async {
                                    FlutterClipboard.copy(
                                        _currentSelectTask.result ?? "");
                                    _showToast();
                                  },
                                  icon: const Icon(Icons.copy),
                                  label: const Text("copy")),
                            )
                          ];
                        })
                  ],
                ),
                // decoration: BoxDecoration(
                //     border: Border(bottom: BorderSide(width: 1))),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SelectableText(
                    _currentSelectTask.result ?? "",
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontStyle: FontStyle.normal),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  openDialog() {
    showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black45,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext, Animation animation,
            Animation secondaryAnimation) {
          return modalBody;
        });
  }

  handleTask(TaskProvider taskProvider, Task task) async {
    taskProvider.join(task);
    job.add(task);
    if (isWorking) {
      return;
    }
    int i = 0;
    while (job.isNotEmpty) {
      if (!isWorking) {
        isWorking = true;
        taskProvider.start(job[i]);
        final res = await compute(
            transcribe, Request(address: ctx.address, task: job[i]));
        log.info("complete ${res}");
        job[i].result = res;
        taskProvider.complete(job[i]);
        job.remove(job[i]);
        isWorking = false;
      }
    }
  }

  onPressed(StatusKey key, Task task) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    if (key == StatusKey.remove) {
      taskProvider.remove(task);
    }
    if (key == StatusKey.open) {
      _currentSelectTask = task;
      openDialog();
    }
    if (key == StatusKey.play) {
      handleTask(taskProvider, task);
    }
  }

  Widget get buildTaskList => FutureBuilder<List<Task>>(
        future: Future.value(taskList),
        initialData: taskList,
        builder:
            (BuildContext buildContext, AsyncSnapshot<List<Task>> snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemBuilder: (BuildContext context, int index) =>
                  TaskItem(task: taskList[index], onPressed: onPressed),
              itemCount: taskList.length,
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: SizedBox(
                height: 100,
                child: Column(
                  children: [
                    Icon(
                      Icons.error_sharp,
                      color: Colors.grey,
                      size: 48,
                    ),
                    Padding(padding: EdgeInsets.all(4)),
                    Text(
                      "No Data",
                      style: TextStyle(color: Colors.grey),
                    )
                  ],
                ),
              ),
            );
          }
          return const Icon(Icons.file_open);
        },
      );

  get addButton => Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: Color.fromARGB(255, 38, 38, 38),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            TextButton.icon(
              style: TextButton.styleFrom(
                  foregroundColor: Colors.blueAccent,
                  textStyle: const TextStyle(color: Colors.amber)),
              onPressed: Provider.of<TaskProvider>(context).add,
              icon: const Icon(Icons.add),
              label: const Text(
                "添加任务",
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<TaskProvider>(
      builder: (context, task, child) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            children: [
              const SizedBox(
                height: 18,
              ),
              const Row(
                children: [
                  Text(
                    "任务",
                    style: TextStyle(color: Colors.blueAccent, fontSize: 22),
                  ),
                ],
              ),
              const SizedBox(
                height: 28,
              ),
              Expanded(child: buildTaskList),
              addButton
            ],
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
