import 'dart:convert';

import 'package:event/event.dart';

import '../basic/log.dart';
import '../basic/methods.dart';

const _useLocalProDefault =
    bool.fromEnvironment('FORCE_PRO_UNTIL_2077', defaultValue: true);
const _localProExpire = 3376684800; // 2077-01-01 00:00:00 UTC
const _proCacheIsProKey = "pro_cache_is_pro";
const _proCacheExpireKey = "pro_cache_expire";
const _proCacheInfoAfKey = "pro_cache_info_af";
const _proCacheInfoPatKey = "pro_cache_info_pat";

var isPro = false;
var isProEx = 0;
var _proCacheLoaded = false;

ProInfoAf? _proInfoAf;
ProInfoPat? _proInfoPat;

ProInfoAf get proInfoAf =>
    _proInfoAf ?? ProInfoAf.fromJson({"is_pro": isPro, "expire": isProEx});
ProInfoPat get proInfoPat => _proInfoPat ?? _defaultProInfoPat();

bool get useLocalProDefault => _useLocalProDefault;

final proEvent = Event();

bool get hasProAccess {
  if (isPro || _proInfoAf?.isPro == true || _proInfoPat?.isPro == true) {
    return true;
  }
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  return isProEx > now;
}

Future<bool> ensureProAccess() async {
  if (hasProAccess) {
    return true;
  }
  await reloadIsPro();
  return hasProAccess;
}

bool _parseBool(String value, {required bool fallback}) {
  final normalized = value.trim().toLowerCase();
  if (normalized == "true" || normalized == "1") {
    return true;
  }
  if (normalized == "false" || normalized == "0") {
    return false;
  }
  return fallback;
}

bool _isUnsupportedProApiError(Object error) {
  final message = error.toString().toUpperCase();
  return message.contains("NO FLAT") ||
      message.contains("NOT IMPLEMENTED") ||
      message.contains("MISSINGPLUGINEXCEPTION");
}

ProInfoPat _defaultProInfoPat() {
  return ProInfoPat.fromJson({
    "is_pro": false,
    "pat_id": "",
    "bind_uid": "",
    "request_delete": 0,
    "re_bind": 0,
    "error_type": 0,
    "error_msg": "",
    "access_key": ""
  });
}

Map<String, dynamic>? _decodeJsonMap(String raw) {
  if (raw.isEmpty) {
    return null;
  }
  final decoded = jsonDecode(raw);
  if (decoded is! Map) {
    return null;
  }
  return Map<String, dynamic>.from(decoded);
}

String _maskPatId(String accessKey) {
  if (accessKey.length <= 6) {
    return accessKey;
  }
  return "${accessKey.substring(0, 3)}***${accessKey.substring(accessKey.length - 3)}";
}

Future<void> _restoreProCacheIfNeeded() async {
  if (_proCacheLoaded) {
    return;
  }
  _proCacheLoaded = true;
  try {
    final cachedIsPro = await methods.loadProperty(_proCacheIsProKey);
    final cachedExpire = await methods.loadProperty(_proCacheExpireKey);
    final cachedInfoAf = await methods.loadProperty(_proCacheInfoAfKey);
    final cachedInfoPat = await methods.loadProperty(_proCacheInfoPatKey);

    if (cachedIsPro.isNotEmpty) {
      isPro = _parseBool(cachedIsPro, fallback: isPro);
    }
    final expire = int.tryParse(cachedExpire);
    if (expire != null) {
      isProEx = expire;
    }

    final afMap = _decodeJsonMap(cachedInfoAf);
    if (afMap != null) {
      _proInfoAf = ProInfoAf.fromJson(afMap);
      isPro = _proInfoAf!.isPro;
      isProEx = _proInfoAf!.expire;
    }

    final patMap = _decodeJsonMap(cachedInfoPat);
    if (patMap != null) {
      _proInfoPat = ProInfoPat.fromJson(patMap);
    }
  } catch (e, st) {
    debugPrient("restoreProCache failed: $e\n$st");
  }
}

Map<String, dynamic> _serializePat(ProInfoPat? pat) {
  return {
    "is_pro": pat?.isPro ?? false,
    "pat_id": pat?.patId ?? "",
    "bind_uid": pat?.bindUid ?? "",
    "request_delete": pat?.requestDelete ?? 0,
    "re_bind": pat?.reBind ?? 0,
    "error_type": pat?.errorType ?? 0,
    "error_msg": pat?.errorMsg ?? "",
    "access_key": pat?.accessKey ?? "",
  };
}

Future<void> _saveProCache() async {
  try {
    await methods.saveProperty(_proCacheIsProKey, "$isPro");
    await methods.saveProperty(_proCacheExpireKey, "$isProEx");
    await methods.saveProperty(
      _proCacheInfoAfKey,
      jsonEncode({
        "is_pro": _proInfoAf?.isPro ?? isPro,
        "expire": _proInfoAf?.expire ?? isProEx,
      }),
    );
    await methods.saveProperty(
      _proCacheInfoPatKey,
      jsonEncode(_serializePat(_proInfoPat)),
    );
  } catch (e, st) {
    debugPrient("saveProCache failed: $e\n$st");
  }
}

void _applyLocalDefaultState() {
  isPro = true;
  isProEx = _localProExpire;
  _proInfoAf = ProInfoAf.fromJson({
    "is_pro": true,
    "expire": _localProExpire,
  });
  _proInfoPat ??= _defaultProInfoPat();
}

Future<void> _reloadFromBackend() async {
  var loadedByIsProApi = false;
  var loadedByProInfoAllApi = false;

  try {
    final all = await methods.proInfoAll();
    loadedByProInfoAllApi = true;
    _proInfoAf = all.proInfoAf;
    _proInfoPat = all.proInfoPat;
    isPro = _proInfoAf?.isPro ?? isPro;
    isProEx = _proInfoAf?.expire ?? isProEx;
  } catch (e, st) {
    if (_isUnsupportedProApiError(e)) {
      debugPrient("reloadIsPro/proInfoAll unsupported: $e");
    } else {
      debugPrient("reloadIsPro/proInfoAll failed: $e\n$st");
    }
  }

  if (!loadedByProInfoAllApi) {
    try {
      final info = await methods.isPro();
      loadedByIsProApi = true;
      isPro = info.isPro;
      isProEx = info.expire;
      _proInfoAf = ProInfoAf.fromJson({"is_pro": isPro, "expire": isProEx});
    } catch (e, st) {
      if (_isUnsupportedProApiError(e)) {
        debugPrient("reloadIsPro/isPro unsupported: $e");
      } else {
        debugPrient("reloadIsPro/isPro failed: $e\n$st");
      }
    }
  }

  if (!loadedByIsProApi && !loadedByProInfoAllApi) {
    _proInfoAf ??= ProInfoAf.fromJson({"is_pro": isPro, "expire": isProEx});
    _proInfoPat ??= _defaultProInfoPat();
    return;
  }

  _proInfoAf ??= ProInfoAf.fromJson({"is_pro": isPro, "expire": isProEx});
  _proInfoPat ??= _defaultProInfoPat();
  await _saveProCache();
}

Future reloadIsPro() async {
  await _restoreProCacheIfNeeded();

  if (_useLocalProDefault) {
    _applyLocalDefaultState();
    await _saveProCache();
    proEvent.broadcast();
    return;
  }

  await _reloadFromBackend();
  proEvent.broadcast();
}

Future<void> refreshProStatus() async {
  if (_useLocalProDefault) {
    await reloadIsPro();
    return;
  }
  await methods.reloadPro();
  await reloadIsPro();
}

Future<void> redeemCdKey(String cdKey) async {
  if (_useLocalProDefault) {
    _applyLocalDefaultState();
    await _saveProCache();
    proEvent.broadcast();
    return;
  }
  await methods.inputCdKey(cdKey);
  await reloadIsPro();
}

Future<Map<String, dynamic>> checkPatAccessKey(String accessKey) async {
  await _restoreProCacheIfNeeded();

  if (_useLocalProDefault) {
    return {
      "email": _maskPatId(accessKey),
      "bind_user": _proInfoPat?.bindUid ?? "",
      "fd": true,
      "re_bind": 0,
    };
  }

  final checkResult = await methods.checkPat(accessKey);
  final decoded = jsonDecode(checkResult);
  if (decoded is! Map) {
    return {};
  }
  return Map<String, dynamic>.from(decoded);
}

Future<void> bindPatAccount(String accessKey, String username) async {
  await _restoreProCacheIfNeeded();

  if (_useLocalProDefault) {
    _applyLocalDefaultState();
    _proInfoPat = ProInfoPat.fromJson({
      "is_pro": true,
      "pat_id": _maskPatId(accessKey),
      "bind_uid": username,
      "request_delete": 0,
      "re_bind": 0,
      "error_type": 0,
      "error_msg": "",
      "access_key": accessKey,
    });
    await _saveProCache();
    proEvent.broadcast();
    return;
  }

  await methods.bindPatAccount(accessKey, username);
  await reloadIsPro();
}

Future<void> reloadPatAccount() async {
  if (_useLocalProDefault) {
    await reloadIsPro();
    return;
  }
  await methods.reloadPatAccount();
  await reloadIsPro();
}

Future<void> clearPat() async {
  await _restoreProCacheIfNeeded();

  if (_useLocalProDefault) {
    _proInfoPat = _defaultProInfoPat();
    await _saveProCache();
    proEvent.broadcast();
    return;
  }

  await methods.clearPat();
  await reloadIsPro();
}
