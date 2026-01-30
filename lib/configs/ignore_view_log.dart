/// 自动全屏

import 'dart:io';

import 'package:flutter/material.dart';

import '../basic/commons.dart';
import '../basic/methods.dart';

const _propertyName = "ignoreVewLog";
late bool _ignoreVewLog;

Future<void> initIgnoreVewLog() async {
  _ignoreVewLog =
      (await methods.loadProperty(_propertyName)) == "true";
}

bool currentIgnoreVewLog() {
  return _ignoreVewLog;
}

Widget ignoreVewLogSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        value: _ignoreVewLog,
        onChanged: (value) async {
          await methods.saveProperty(_propertyName, "$value");
          _ignoreVewLog = value;
          setState(() {});
        },
        title: const Text("详情页不记录浏览记录"),
      );
    },
  );
}
