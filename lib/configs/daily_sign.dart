import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:jmcomic3/basic/commons.dart';
import 'package:jmcomic3/basic/log.dart';
import 'package:jmcomic3/basic/methods.dart';
import 'package:jmcomic3/configs/login.dart';
import 'package:jmcomic3/l10n/app_localizations.dart';

enum DailySignStatus {
  unchecked,
  checking,
  signed,
  error,
}

DailySignStatus dailySignStatus = DailySignStatus.unchecked;
const _dailySignCheckCooldown = Duration(minutes: 5);
DateTime? _lastDailySignCheckAt;
int? _lastDailySignCheckUid;

final dailySignEvent = Event();

void _setDailySignStatus(DailySignStatus status) {
  dailySignStatus = status;
  dailySignEvent.broadcast();
}

String dailySignStatusLabel(BuildContext context) {
  switch (dailySignStatus) {
    case DailySignStatus.checking:
      return context.l10n.tr("检测中...", en: "Checking...");
    case DailySignStatus.signed:
      return context.l10n.tr("已签到", en: "Signed in");
    case DailySignStatus.error:
      return context.l10n.tr("签到失败", en: "Sign-in failed");
    case DailySignStatus.unchecked:
      return context.l10n.tr("未检测签到", en: "Not checked");
  }
}

Future<void> checkDailySignStatus(BuildContext context,
    {bool toast = false}) async {
  if (loginStatus != LoginStatus.loginSuccess) {
    _lastDailySignCheckAt = null;
    _lastDailySignCheckUid = null;
    _setDailySignStatus(DailySignStatus.unchecked);
    return;
  }
  if (!toast &&
      _lastDailySignCheckUid == selfInfo.uid &&
      _lastDailySignCheckAt != null &&
      DateTime.now().difference(_lastDailySignCheckAt!) <
          _dailySignCheckCooldown &&
      dailySignStatus != DailySignStatus.unchecked) {
    return;
  }
  _setDailySignStatus(DailySignStatus.checking);
  try {
    final msg = await methods.daily(selfInfo.uid);
    _lastDailySignCheckUid = selfInfo.uid;
    _lastDailySignCheckAt = DateTime.now();
    if (toast) {
      defaultToast(
        context,
        msg.isNotEmpty ? msg : context.l10n.tr("已签到", en: "Signed in"),
      );
    }
    _setDailySignStatus(DailySignStatus.signed);
  } catch (e, st) {
    debugPrient("$e\n$st");
    _lastDailySignCheckUid = selfInfo.uid;
    _lastDailySignCheckAt = DateTime.now();
    if (toast) {
      defaultToast(context, "$e");
    }
    _setDailySignStatus(DailySignStatus.error);
  }
}
