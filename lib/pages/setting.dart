import 'package:flutter/material.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> with AutomaticKeepAliveClientMixin {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    super.updateKeepAlive();
    return const Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(
                Icons.light,
                color: Colors.yellowAccent,
                size: 40,
              ),
              SizedBox(
                width: 4,
              ),
              Text(
                "todo ",
                style: TextStyle(color: Colors.white60, fontSize: 40),
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
