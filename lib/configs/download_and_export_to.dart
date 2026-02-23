import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jmcomic3/l10n/app_localizations.dart';

import '../basic/commons.dart';
import '../basic/methods.dart';
import 'is_pro.dart';

late String _currentDownloadAndExportTo;

Future<String?> initDownloadAndExportTo() async {
  _currentDownloadAndExportTo = await methods.getDownloadAndExportTo();
  return null;
}

String currentDownloadAndExportToName() {
  return _currentDownloadAndExportTo == ""
      ? "Not set"
      : _currentDownloadAndExportTo;
}

String get currentDownloadAndExportTo => _currentDownloadAndExportTo;

Widget downloadAndExportToSetting() {
  if (!hasProAccess) {
    return Builder(
      builder: (context) {
        final l10n = context.l10n;
        return SwitchListTile(
          title: Text(
            l10n.tr("下载时同时导出", en: "Export while downloading"),
            style: const TextStyle(color: Colors.grey),
          ),
          subtitle: Text(
            l10n.tr("发电才能使用", en: "Pro required"),
            style: const TextStyle(color: Colors.grey),
          ),
          value: false,
          onChanged: (_) {},
        );
      },
    );
  }
  if (Platform.isIOS) {
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        final l10n = context.l10n;
        return SwitchListTile(
          title: Text(l10n.tr("下载时同时导出", en: "Export while downloading")),
          subtitle: Text(_currentDownloadAndExportTo),
          value: _currentDownloadAndExportTo.isNotEmpty,
          onChanged: (e) async {
            var root =
                e ? ((await methods.iosGetDocumentDir()) + "/exports") : "";
            await methods.setDownloadAndExportTo(root);
            _currentDownloadAndExportTo = root;
            setState(() {});
          },
        );
      },
    );
  }
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      final l10n = context.l10n;
      return ListTile(
        title: Text(
          l10n.tr("下载的同时导出到某个目录(填完整路径)",
              en: "Export to a directory while downloading (full path)"),
        ),
        subtitle: Text(
          _currentDownloadAndExportTo.isEmpty
              ? l10n.tr("未设置", en: "Not set")
              : _currentDownloadAndExportTo,
        ),
        onTap: () async {
          final chooseNewLocation = l10n.tr("选择新位置", en: "Choose new location");
          final clearSetting = l10n.tr("清除设置", en: "Clear setting");
          var result = await chooseListDialog(context,
              values: [chooseNewLocation, clearSetting],
              title: l10n.tr("下载的时候同时导出", en: "Export while downloading"));
          if (result != null) {
            if (chooseNewLocation == result) {
              if (!await androidMangeStorageRequest()) {
                throw Exception(l10n.tr("申请权限被拒绝", en: "Permission denied"));
              }
              String? root = await chooseFolder(context);
              if (root != null) {
                await methods.setDownloadAndExportTo(root);
                _currentDownloadAndExportTo = root;
                setState(() {});
              }
            } else if (clearSetting == result) {
              const root = "";
              await methods.setDownloadAndExportTo(root);
              _currentDownloadAndExportTo = root;
              setState(() {});
            }
          }
        },
      );
    },
  );
}
