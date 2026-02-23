import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:jmcomic3/basic/methods.dart';
import 'package:jmcomic3/l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../configs/android_version.dart';

const coverShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(4.5)),
);

/// 显示一个toast
void defaultToast(BuildContext context, String title) {
  showToast(
    context.l10n.tr(title),
    context: context,
    position: StyledToastPosition.center,
    animation: StyledToastAnimation.scale,
    reverseAnimation: StyledToastAnimation.fade,
    duration: const Duration(seconds: 4),
    animDuration: const Duration(seconds: 1),
    curve: Curves.elasticOut,
    reverseCurve: Curves.linear,
  );
}

Future<T?> chooseListDialog<T>(BuildContext context,
    {required List<T> values, required String title, String? tips}) async {
  final l10n = context.l10n;
  return showDialog<T>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text(l10n.tr(title)),
        children: [
          ...values.map((e) => SimpleDialogOption(
                onPressed: () {
                  Navigator.of(context).pop(e);
                },
                child: Text(l10n.tr('$e')),
              )),
          ...tips != null
              ? [
                  Container(
                    padding: const EdgeInsets.fromLTRB(15, 5, 15, 15),
                    child: Text(l10n.tr(tips)),
                  ),
                ]
              : [],
        ],
      );
    },
  );
}

Future<T?> chooseMapDialog<T>(
  BuildContext buildContext, {
  required String title,
  required Map<String, T> values,
}) async {
  final l10n = buildContext.l10n;
  return await showDialog<T>(
    context: buildContext,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text(l10n.tr(title)),
        children: values.entries
            .map((e) => SimpleDialogOption(
                  child: Text(l10n.tr(e.key)),
                  onPressed: () {
                    Navigator.of(context).pop(e.value);
                  },
                ))
            .toList(),
      );
    },
  );
}

Future<bool> androidGalleryPermissionRequest() async {
  if (Platform.isAndroid && androidVersion < 33) {
    return await (Permission.storage.request()).isGranted;
  }
  return true;
}

Future<bool> androidMangeStorageRequest() async {
  if (Platform.isAndroid) {
    if (androidVersion < 30) {
      return await (Permission.storage.request()).isGranted;
    }
    return await (Permission.manageExternalStorage.request()).isGranted;
  }
  return true;
}

Future saveImageFileToGallery(BuildContext context, String path) async {
  if (!await androidGalleryPermissionRequest()) {
    throw Exception(context.l10n.tr("申请权限被拒绝", en: "Permission denied"));
  }
  if (Platform.isIOS || Platform.isAndroid) {
    await methods.saveImageFileToGallery(path);
    defaultToast(context, context.l10n.tr("保存成功", en: "Saved successfully"));
    return;
  }
  defaultToast(
      context, context.l10n.tr("暂不支持该平台", en: "Platform not supported"));
}

Future saveImageFileToFile(BuildContext context, String path) async {
  if (!await androidGalleryPermissionRequest()) {
    throw Exception(context.l10n.tr("申请权限被拒绝", en: "Permission denied"));
  }
  late String folder;
  if (Platform.isAndroid) {
    folder = await methods.picturesDir();
  } else if (Platform.isIOS) {
    folder = await methods.iosGetDocumentDir() + "/pictures";
  } else {
    var _f = await chooseFolder(context);
    if (_f != null) {
      folder = _f;
    }
  }
  try {
    await methods.copyPictureToFolder(folder, path);
    defaultToast(context, context.l10n.tr("保存成功", en: "Saved successfully"));
  } catch (e) {
    defaultToast(
      context,
      context.l10n.tr("保存失败", en: "Save failed") + " : $e",
    );
  }
}

Future<SortBy?> chooseSortBy(BuildContext context) async {
  final values = <String, SortBy>{
    sortByName(context, sortByDefault): sortByDefault,
    sortByName(context, sortByNew): sortByNew,
    sortByName(context, sortByLike): sortByLike,
    sortByName(context, sortByView): sortByView,
    sortByName(context, sortByViewDay): sortByViewDay,
    sortByName(context, sortByViewWeek): sortByViewWeek,
    sortByName(context, sortByViewMonth): sortByViewMonth,
  };
  return await chooseMapDialog(
    context,
    title: context.l10n.tr("请选择排序方式", en: "Choose sort mode"),
    values: values,
  );
}

String sortByName(BuildContext context, SortBy sortBy) {
  if (sortBy == sortByDefault) {
    return context.l10n.tr("默认", en: "Default");
  }
  if (sortBy == sortByNew) {
    return context.l10n.tr("最新", en: "Newest");
  }
  if (sortBy == sortByLike) {
    return context.l10n.tr("心", en: "Like");
  }
  if (sortBy == sortByView) {
    return context.l10n.tr("查看", en: "Views");
  }
  if (sortBy == sortByViewDay) {
    return context.l10n.tr("日榜", en: "Daily");
  }
  if (sortBy == sortByViewWeek) {
    return context.l10n.tr("周榜", en: "Weekly");
  }
  if (sortBy == sortByViewMonth) {
    return context.l10n.tr("月榜", en: "Monthly");
  }
  return context.l10n.tr(sortBy.toString());
}

/// 将字符串前面加0直至满足len位
String add0(int num, int len) {
  var rsp = "$num";
  while (rsp.length < len) {
    rsp = "0$rsp";
  }
  return rsp;
}

/// 打开web页面
Future<dynamic> openUrl(String url) async {
  if (await canLaunch(url)) {
    await launch(
      url,
      forceSafariVC: false,
    );
  }
}

final _controller = TextEditingController();

Future<String?> displayTextInputDialog(BuildContext context,
    {String? title,
    String src = "",
    String? hint,
    String? desc,
    bool isPasswd = false}) {
  final l10n = context.l10n;
  _controller.text = src;
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: title == null ? null : Text(l10n.tr(title)),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: hint == null ? null : l10n.tr(hint),
                ),
                obscureText: isPasswd,
                obscuringCharacter: '\u2022',
              ),
              ...(desc == null
                  ? []
                  : [
                      Container(
                        padding: EdgeInsets.only(top: 20, bottom: 10),
                        child: Text(
                          l10n.tr(desc),
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withOpacity(.5)),
                        ),
                      )
                    ]),
            ],
          ),
        ),
        actions: <Widget>[
          MaterialButton(
            child: Text(l10n.tr('取消', en: 'Cancel')),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          MaterialButton(
            child: Text(l10n.confirm),
            onPressed: () {
              Navigator.of(context).pop(_controller.text);
            },
          ),
        ],
      );
    },
  );
}

/// 复制内容到剪切板
void copyToClipBoard(BuildContext context, String string) {
  FlutterClipboard.copy(string);
  defaultToast(context, context.l10n.tr("已复制到剪切板", en: "Copied to clipboard"));
}

/// 显示一个确认框, 用户关闭弹窗以及选择否都会返回false, 仅当用户选择确定时返回true
Future<bool> confirmDialog(
    BuildContext context, String title, String content) async {
  final l10n = context.l10n;
  return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(l10n.tr(title)),
                content: new SingleChildScrollView(
                  child: new ListBody(
                    children: <Widget>[
                      new Text(l10n.tr(content)),
                    ],
                  ),
                ),
                actions: <Widget>[
                  new MaterialButton(
                    child: new Text(l10n.tr('取消', en: 'Cancel')),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  new MaterialButton(
                    child: new Text(l10n.confirm),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              )) ??
      false;
}

/// 复制对话框
void confirmCopy(BuildContext context, String content) async {
  if (await confirmDialog(
      context, context.l10n.tr("复制", en: "Copy"), content)) {
    copyToClipBoard(context, content);
  }
}

/// 选择一个文件夹用于保存文件
Future<String?> chooseFolder(BuildContext context) async {
  return FilePicker.platform.getDirectoryPath(
    dialogTitle: context.l10n.tr(
      "选择一个文件夹, 将文件保存到这里",
      en: "Choose a folder to save files",
    ),
  );
}
