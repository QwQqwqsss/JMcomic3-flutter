import 'dart:io';

import 'package:flutter/material.dart';

import '../basic/commons.dart';
import '../basic/methods.dart';
import 'DesktopAuthenticationScreen.dart';
import 'android_version.dart';

const _propertyName = "authentication";
late bool _authentication;

Future<void> initAuthentication() async {
  if (Platform.isIOS || androidVersion >= 29) {
    _authentication = (await methods.loadProperty(_propertyName)) == "true";
  } else if (Platform.isAndroid) {
    _authentication = false;
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    _authentication = await needDesktopAuthentication();
  } else {
    _authentication = false;
  }
}

bool currentAuthentication() {
  return _authentication;
}

Future<bool> verifyAuthentication(BuildContext context) async {
  if (Platform.isIOS || androidVersion >= 29) {
    return await methods.verifyAuthentication();
  }
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    return await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const VerifyPassword())) ==
        true;
  }
  return false;
}

Widget authenticationSetting() {
  if (Platform.isIOS || androidVersion >= 29) {
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return ListTile(
          title: const Text("进入APP时验证身份(如果系统已经录入密码或指纹)"),
          subtitle: Text(_authentication ? "是" : "否"),
          onTap: () async {
            await _chooseAuthentication(context);
            setState(() {});
          },
        );
      },
    );
  }
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    return StatefulBuilder(builder: (
      BuildContext context,
      void Function(void Function()) setState,
    ) {
      return ListTile(
        title: const Text("设置应用程序密码"),
        onTap: () async {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SetPassword()));
        },
      );
    });
  }
  return Container();
}

Future<void> _chooseAuthentication(BuildContext context) async {
  if (await methods.verifyAuthentication()) {
    String? result = await chooseListDialog<String>(context,
        title: "进入APP时验证身份", values: ["是", "否"]);
    if (result != null) {
      var target = result == "是";
      await methods.saveProperty(_propertyName, "$target");
      _authentication = target;
    }
  }
}
