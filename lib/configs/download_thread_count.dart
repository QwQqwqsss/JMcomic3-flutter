/// 多线程下载并发数

import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:jmcomic3/basic/methods.dart';
import 'package:jmcomic3/l10n/app_localizations.dart';

import '../basic/commons.dart';
import 'is_pro.dart';

late int _downloadThreadCount;
int get downloadThreadCount => _downloadThreadCount;
const _values = [1, 2, 3, 4, 5];
final downloadThreadCountEvent = Event();

Future initDownloadThreadCount() async {
  _updateDownloadThreadCount(await methods.load_download_thread());
}

Widget downloadThreadCountSetting() {
  return const _DownloadThreadCountSetting();
}

Future chooseDownloadThread(BuildContext context) async {
  final l10n = context.l10n;
  if (!hasProAccess) {
    defaultToast(
      context,
      l10n.tr('先发电才能使用多线程嗷', en: 'Multi-thread download requires Pro'),
    );
    return;
  }
  int? value = await chooseListDialog(
    context,
    title: l10n.tr('选择下载线程数', en: 'Choose download thread count'),
    values: _values,
  );
  if (value != null) {
    await methods.set_download_thread(value);
    _updateDownloadThreadCount(value);
  }
}

void _updateDownloadThreadCount(int value) {
  _downloadThreadCount = value;
  downloadThreadCountEvent.broadcast();
}

class _DownloadThreadCountSetting extends StatefulWidget {
  const _DownloadThreadCountSetting();

  @override
  State<_DownloadThreadCountSetting> createState() =>
      _DownloadThreadCountSettingState();
}

class _DownloadThreadCountSettingState
    extends State<_DownloadThreadCountSetting> {
  @override
  void initState() {
    super.initState();
    downloadThreadCountEvent.subscribe(_setState);
    proEvent.subscribe(_setState);
  }

  @override
  void dispose() {
    downloadThreadCountEvent.unsubscribe(_setState);
    proEvent.unsubscribe(_setState);
    super.dispose();
  }

  void _setState(_) {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListTile(
      title: Text(
        l10n.tr('下载线程数', en: 'Download threads') +
            (!hasProAccess ? l10n.tr('(发电)', en: ' (Pro)') : ''),
        style: TextStyle(
          color: !hasProAccess ? Colors.grey : null,
        ),
      ),
      subtitle: Text('$_downloadThreadCount'),
      onTap: () async {
        await chooseDownloadThread(context);
      },
    );
  }
}
