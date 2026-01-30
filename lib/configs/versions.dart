import 'dart:async' show Future;
import 'dart:convert';

import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:jasmine/basic/commons.dart';
import 'package:jasmine/basic/log.dart';
import 'package:jasmine/basic/methods.dart';

import 'ignore_upgrade_pop.dart';

const _repoOwner = "QwQqwqsss";
const _repoName = "JMcomic3-flutter";
const _releaseLatestUrl =
    "https://api.github.com/repos/$_repoOwner/$_repoName/releases/latest";
const releasePageUrl = "https://github.com/$_repoOwner/$_repoName/releases/";

const _versionAssets = 'lib/assets/version.txt';
final RegExp _versionExp = RegExp(r"^v\d+\.\d+\.\d+(\+\d+)?$");

late String _version;
String? _latestVersion;
String? _latestVersionName;
String? _latestVersionInfo;

const _propertyName = "checkVersionPeriod";
late int _period = -1;

Future initVersion() async {
  try {
    _version = (await rootBundle.loadString(_versionAssets)).trim();
  } catch (e) {
    _version = "dirty";
  }
  var vStr = await methods.loadProperty(_propertyName);
  if (vStr == "") {
    vStr = "0";
  }
  _period = int.parse(vStr);
  if (_period > 0) {
    if (DateTime.now().millisecondsSinceEpoch > _period) {
      await methods.saveProperty(_propertyName, "0");
      _period = 0;
    }
  }
}

var versionEvent = Event<EventArgs>();

String currentVersion() {
  return _version;
}

String? get latestVersion => _latestVersion;

String? get latestVersionName => _latestVersionName;

String? latestVersionInfo() {
  return _latestVersionInfo;
}

Future autoCheckNewVersion() {
  if (_period != 0) {
    return Future.value();
  }
  return _versionCheck();
}

Future manualCheckNewVersion(BuildContext context) async {
  try {
    defaultToast(context, "\u68c0\u67e5\u66f4\u65b0\u4e2d");
    await _versionCheck();
    defaultToast(context, "\u68c0\u67e5\u66f4\u65b0\u6210\u529f");
  } catch (e) {
    defaultToast(context, "\u68c0\u67e5\u66f4\u65b0\u5931\u8d25: $e");
  }
}

Future silentCheckNewVersion() async {
  await _versionCheck();
}

bool dirtyVersion() {
  return !_versionExp.hasMatch(_version);
}

Future _versionCheck() async {
  if (_versionExp.hasMatch(_version)) {
    final json = jsonDecode(await methods.httpGet(_releaseLatestUrl));
    final latest = json["name"] ?? json["tag_name"];
    if (latest != null) {
      final latestVersion = latest.toString().trim();
      final body = json["body"]?.toString() ?? "";
      if (latestVersion.isNotEmpty) {
        _latestVersionName = latestVersion;
        _latestVersionInfo = body;
        _latestVersion = latestVersion != _version ? latestVersion : null;
      } else {
        _latestVersion = null;
        _latestVersionName = null;
        _latestVersionInfo = null;
      }
    }
  }
  versionEvent.broadcast();
  debugPrient("$_latestVersion");
}

String _periodText() {
  if (_period < 0) {
    return "\u81ea\u52a8\u68c0\u67e5\u66f4\u65b0\u5df2\u5173\u95ed";
  }
  if (_period == 0) {
    return "\u81ea\u52a8\u68c0\u67e5\u66f4\u65b0\u5df2\u5f00\u542f";
  }
  return "\u4e0b\u6b21\u68c0\u67e5\u65f6\u95f4: " +
      formatDateTimeToDateTime(
        DateTime.fromMillisecondsSinceEpoch(_period),
      );
}

Future _choosePeriod(BuildContext context) async {
  var result = await chooseListDialog(
    context,
    title: "\u81ea\u52a8\u68c0\u67e5\u66f4\u65b0",
    values: [
      "\u5f00\u542f",
      "\u4e00\u5468\u540e",
      "\u4e00\u4e2a\u6708\u540e",
      "\u4e00\u5e74\u540e",
      "\u5173\u95ed"
    ],
    tips: "\u91cd\u542f\u540e\u7ea2\u70b9\u4f1a\u6d88\u5931",
  );
  switch (result) {
    case "\u5f00\u542f":
      await methods.saveProperty(_propertyName, "0");
      _period = 0;
      break;
    case "\u4e00\u5468\u540e":
      var time = DateTime.now().millisecondsSinceEpoch + (1000 * 3600 * 24 * 7);
      await methods.saveProperty(_propertyName, "$time");
      _period = time;
      break;
    case "\u4e00\u4e2a\u6708\u540e":
      var time =
          DateTime.now().millisecondsSinceEpoch + (1000 * 3600 * 24 * 30);
      await methods.saveProperty(_propertyName, "$time");
      _period = time;
      break;
    case "\u4e00\u5e74\u540e":
      var time =
          DateTime.now().millisecondsSinceEpoch + (1000 * 3600 * 24 * 365);
      await methods.saveProperty(_propertyName, "$time");
      _period = time;
      break;
    case "\u5173\u95ed":
      await methods.saveProperty(_propertyName, "-1");
      _period = -1;
      break;
  }
}

Widget autoUpdateCheckSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: const Text("\u81ea\u52a8\u68c0\u67e5\u66f4\u65b0"),
        subtitle: Text(_periodText()),
        onTap: () async {
          await _choosePeriod(context);
          setState(() {});
        },
      );
    },
  );
}

String formatDateTimeToDateTime(DateTime c) {
  try {
    return "${add0(c.year, 4)}-${add0(c.month, 2)}-${add0(c.day, 2)} ${add0(c.hour, 2)}:${add0(c.minute, 2)}";
  } catch (e) {
    return "-";
  }
}

var _display = true;

void versionPop(BuildContext context) {
  if (latestVersion != null && _display && !currentIgnoreUpgradePop()) {
    _display = false;
    TopConfirm.topConfirm(
      context,
      "\u53d1\u73b0\u65b0\u7248\u672c",
      "\u53d1\u73b0\u65b0\u7248\u672c $latestVersion\uff0c\u8bf7\u5230\u5173\u4e8e\u9875\u9762\u66f4\u65b0",
    );
  }
}

class TopConfirm {
  static topConfirm(BuildContext context, String title, String message,
      {Function()? afterIKnown}) {
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(builder: (BuildContext context) {
      return LayoutBuilder(
        builder: (
          BuildContext context,
          BoxConstraints constraints,
        ) {
          var mq = MediaQuery.of(context).size.width - 30;
          return Material(
            color: Colors.transparent,
            child: Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.35),
              ),
              child: Column(
                children: [
                  Expanded(child: Container()),
                  SizedBox(
                    width: mq,
                    child: Card(
                      child: Column(
                        children: [
                          Container(height: 30),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 28,
                            ),
                          ),
                          Container(height: 15),
                          Text(
                            message,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Container(height: 25),
                          MaterialButton(
                            elevation: 0,
                            color: Colors.grey.shade700.withOpacity(.1),
                            onPressed: () {
                              overlayEntry.remove();
                            },
                            child: const Text("\u77e5\u9053\u4e86"),
                          ),
                          Container(height: 30),
                        ],
                      ),
                    ),
                  ),
                  Expanded(child: Container()),
                ],
              ),
            ),
          );
        },
      );
    });
    OverlayState? overlay = Overlay.of(context);
    if (overlay != null) {
      overlay.insert(overlayEntry);
    }
  }
}
