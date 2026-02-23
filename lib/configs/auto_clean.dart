import 'package:flutter/material.dart';
import 'package:jmcomic3/basic/commons.dart';
import 'package:jmcomic3/basic/log.dart';
import 'package:jmcomic3/basic/methods.dart';

const _propertyName = 'auto_clean';
const _lastCleanPropertyName = 'auto_clean_last_clean_ts';
const _defaultAutoCleanSeconds = 3600 * 24 * 7;
const _disabledValue = '0';

late String autoClean;

final Map<String, String> _nameMap = <String, String>{
  _disabledValue: '关闭',
  (3600 * 12).toString(): '12小时',
  (3600 * 24).toString(): '1天',
  (3600 * 24 * 3).toString(): '3天',
  (3600 * 24 * 7).toString(): '1周',
  (3600 * 24 * 30).toString(): '1月',
  (3600 * 24 * 30 * 12).toString(): '1年',
};

bool _cleaning = false;

class CacheCleanResult {
  final bool success;
  final Duration duration;
  final Object? error;

  const CacheCleanResult({
    required this.success,
    required this.duration,
    this.error,
  });
}

bool get cacheCleaningInProgress => _cleaning;

Future<void> initAutoClean() async {
  autoClean = await methods.loadProperty(_propertyName);
  if (!_nameMap.containsKey(autoClean)) {
    autoClean = _defaultAutoCleanSeconds.toString();
    await methods.saveProperty(_propertyName, autoClean);
  }
  final lastCleanTs = await _loadLastCleanTs();
  if (lastCleanTs <= 0) {
    await _saveLastCleanTs(_nowSeconds());
  }
}

String autoCleanName() {
  return _nameMap[autoClean] ?? '${_autoCleanSeconds()}秒';
}

Future<void> chooseAutoClean(BuildContext context) async {
  final choose = await chooseMapDialog<String>(
    context,
    title: '选择自动清理时间',
    values: _nameMap.map((key, value) => MapEntry(value, key)),
  );
  if (choose == null || choose == autoClean) {
    return;
  }
  final beforeEnabled = _autoCleanSeconds() > 0;
  autoClean = choose;
  await methods.saveProperty(_propertyName, choose);

  final nowEnabled = _autoCleanSeconds() > 0;
  if (!beforeEnabled && nowEnabled) {
    await _saveLastCleanTs(_nowSeconds());
  }
  if (nowEnabled) {
    defaultToast(context, '自动清理: ${autoCleanName()}');
  } else {
    defaultToast(context, '已关闭自动清理');
  }
}

Future<void> runAutoCleanIfNeeded() async {
  if (_cleaning) {
    return;
  }
  final seconds = _autoCleanSeconds();
  if (seconds <= 0) {
    return;
  }

  final now = _nowSeconds();
  final lastCleanTs = await _loadLastCleanTs();
  if (lastCleanTs <= 0) {
    await _saveLastCleanTs(now);
    return;
  }

  if (now - lastCleanTs < seconds) {
    return;
  }

  final result = await cleanCache();
  if (!result.success) {
    debugPrient('auto clean failed: ${result.error}');
  }
}

Future<CacheCleanResult> cleanCache() async {
  if (_cleaning) {
    return CacheCleanResult(
      success: false,
      duration: Duration.zero,
      error: StateError('Cache clean already in progress'),
    );
  }

  _cleaning = true;
  final sw = Stopwatch()..start();
  try {
    await methods.cleanAllCache();
    await _saveLastCleanTs(_nowSeconds());
    return CacheCleanResult(success: true, duration: sw.elapsed);
  } catch (e, st) {
    debugPrient('$e\n$st');
    return CacheCleanResult(success: false, duration: sw.elapsed, error: e);
  } finally {
    sw.stop();
    _cleaning = false;
  }
}

int _autoCleanSeconds() {
  return _parseInt(autoClean, fallback: _defaultAutoCleanSeconds);
}

int _nowSeconds() {
  return DateTime.now().millisecondsSinceEpoch ~/ 1000;
}

Future<int> _loadLastCleanTs() async {
  final raw = await methods.loadProperty(_lastCleanPropertyName);
  return _parseInt(raw, fallback: 0);
}

Future<void> _saveLastCleanTs(int value) async {
  await methods.saveProperty(_lastCleanPropertyName, '$value');
}

int _parseInt(String value, {required int fallback}) {
  final parsed = int.tryParse(value);
  if (parsed == null || parsed < 0) {
    return fallback;
  }
  return parsed;
}
