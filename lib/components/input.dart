import 'package:flutter/material.dart';

class Input extends StatefulWidget {
  final ValueChanged<String> changed;
  const Input({super.key, required this.changed});
  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  String text = "";
  late TextEditingController controller;
  bool get isEdited => text != "";
  @override
  void initState() {
    controller = TextEditingController()
      ..addListener(() {
        widget.changed(controller.text);
        setState(() {
          text = controller.text;
        });
      });

    super.initState();
  }

  onTapClear() {
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: controller,
        cursorHeight: 12,
        style: const TextStyle(fontSize: 14, color: Colors.white),
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 0),
            isDense: true,
            border: const OutlineInputBorder(
                borderSide: BorderSide(width: 1),
                borderRadius: BorderRadius.all(Radius.circular(6))),
            enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black87,
                  width: 1,
                ),
                borderRadius: BorderRadius.all(Radius.circular(6))),
            hintText: "搜索",
            hintStyle: const TextStyle(color: Colors.white),
            suffixIcon: isEdited
                ? GestureDetector(
                    onTap: onTapClear,
                    child: const Icon(Icons.clear),
                  )
                : const SizedBox.shrink(),
            prefixIcon: const Icon(
              Icons.search,
              size: 14,
            )));
  }
}
