import 'package:app_transcribe/model/task.dart';
import 'package:flutter/material.dart';
import "package:app_transcribe/common/status_key.dart";

class TaskItem extends StatefulWidget {
  final Task task;
  final Function(StatusKey key, Task item) onPressed;
  const TaskItem({super.key, required this.onPressed, required this.task});

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  bool isStart = false;

  renderStatus() {
    switch (widget.task.status) {
      case Status.start:
        return const Padding(
          padding: EdgeInsets.all(8.0),
          child: SizedBox(
            width: 20,
            height: 20,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          ),
        );
      case Status.ready:
        return IconButton(
            onPressed: () {
              widget.onPressed(StatusKey.play, widget.task);
            },
            icon: const Icon(
              Icons.play_arrow,
              color: Colors.blueAccent,
            ));
      case Status.wait:
        return IconButton(
            onPressed: () {
              widget.onPressed(StatusKey.play, widget.task);
            },
            icon: const Icon(
              Icons.pause_circle,
              color: Colors.blueAccent,
            ));
      case Status.complete:
        return IconButton(
            onPressed: () {
              widget.onPressed(StatusKey.play, widget.task);
            },
            icon: const Icon(
              Icons.check,
              color: Colors.blueAccent,
            ));

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: const BoxDecoration(
          color: Color.fromARGB(255, 50, 50, 50),
          borderRadius: BorderRadius.all(Radius.circular(6))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.task.fileName,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  maxLines: 1,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  widget.task.path,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  maxLines: 1,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              renderStatus(),
              IconButton(
                  onPressed: () {
                    widget.onPressed(StatusKey.open, widget.task);
                  },
                  icon: const Icon(
                    Icons.file_open_outlined,
                    color: Colors.cyanAccent,
                  )),
              IconButton(
                  onPressed: () {
                    widget.onPressed(StatusKey.remove, widget.task);
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.redAccent,
                  ))
            ],
          )
        ],
      ),
    );
  }
}
