import 'package:flutter/material.dart';

import '../basic/commons.dart';
import '../basic/methods.dart';
import 'is_pro.dart';

const _propertyName = "ignoreUpgradePop";
late bool _ignoreUpgradePop;

Future<void> initIgnoreUpgradePop() async {
  _ignoreUpgradePop = (await methods.loadProperty(_propertyName)) == "true";
  if (!isPro) {
    _ignoreUpgradePop = false;
  }
}

bool currentIgnoreUpgradePop() {
  return _ignoreUpgradePop;
}

Widget ignoreUpgradePopSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        title: Text(
          "是否忽略升级弹窗",
          style: TextStyle(
            color: !isPro ? Colors.grey : null,
          ),
        ),
        subtitle: Text(
          _ignoreUpgradePop ? "是" : "否",
          style: TextStyle(
            color: !isPro ? Colors.grey : null,
          ),
        ),
        value: _ignoreUpgradePop,
        onChanged: (value) async {
          if (!isPro) {
            return;
          }
          await methods.saveProperty(_propertyName, "$value");
          _ignoreUpgradePop = value;
          setState(() {});
        },
      );
    },
  );
}
