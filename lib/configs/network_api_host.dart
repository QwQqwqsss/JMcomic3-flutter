import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:jmcomic3/basic/http_client.dart';
import 'package:jmcomic3/basic/methods.dart';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart' as pc;

late String _apiHost;

const _base64List = [
  "d3d3LmNkbmJlYS5uZXQ=",
  "d3d3LmNkbmh0aC5uZXQ=",
  "d3d3LmNkbmd3Yy5jYw==",
  "d3d3LmNkbmh0aC5jbHVi",
];

const _apiDomainServerUrls = [
  "https://rup4a04-c01.tos-ap-southeast-1.bytepluses.com/newsvr-2025.txt",
  "https://rup4a04-c02.tos-cn-hongkong.bytepluses.com/newsvr-2025.txt",
];

const _apiDomainServerSecret = "diosfjckwpqpdfjkvnqQjsik";
const _apiDomainCacheKey = "api_domain_cache";
const _apiDomainCacheTsKey = "api_domain_cache_ts";
const _apiDomainCacheTtlSeconds = 7 * 24 * 60 * 60;

List<String> _apiList = [];

Future<void> initApiHost() async {
  _apiList = _decodeBase64List(_base64List);
  await _loadCachedApiList();
  await _refreshApiListIfNeeded();
  _apiHost = await methods.loadApiHost();
  if (_apiHost.isEmpty && _apiList.isNotEmpty) {
    _apiHost = _apiList.first;
    await methods.saveApiHost(_apiHost);
  }
}

String get currentApiHostName => (_apiHost);

List<String> _decodeBase64List(List<String> encoded) {
  return encoded
      .map((e) => utf8.decode(base64.decode(e)))
      .where((e) => e.isNotEmpty)
      .toList();
}

Future<void> _loadCachedApiList() async {
  final cached = await methods.loadProperty(_apiDomainCacheKey);
  if (cached.isEmpty) {
    return;
  }
  try {
    final decoded = jsonDecode(cached);
    if (decoded is List) {
      _mergeApiList(decoded.map((e) => "$e"));
    }
  } catch (_) {
    // Ignore cache parse errors.
  }
}

Future<void> _refreshApiListIfNeeded() async {
  final tsStr = await methods.loadProperty(_apiDomainCacheTsKey);
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final last = int.tryParse(tsStr) ?? 0;
  if (now - last < _apiDomainCacheTtlSeconds) {
    return;
  }
  final latest = await _fetchLatestApiDomainList();
  if (latest.isEmpty) {
    return;
  }
  _mergeApiList(latest);
  await methods.saveProperty(_apiDomainCacheKey, jsonEncode(latest));
  await methods.saveProperty(_apiDomainCacheTsKey, "$now");
}

void _mergeApiList(Iterable<String> items) {
  final merged = LinkedHashSet<String>.from(_apiList);
  for (final raw in items) {
    final value = raw.trim();
    if (value.isNotEmpty) {
      merged.add(value);
    }
  }
  _apiList = merged.toList();
}

Future<List<String>> _fetchLatestApiDomainList() async {
  for (final url in _apiDomainServerUrls) {
    try {
      final list = await _fetchApiDomainList(url);
      if (list.isNotEmpty) {
        return list;
      }
    } catch (_) {
      // Try next server.
    }
  }
  return [];
}

Future<List<String>> _fetchApiDomainList(String url) async {
  final text = await _httpGetText(url);
  if (text == null || text.isEmpty) {
    return [];
  }
  final cleaned = _stripNonAsciiPrefix(text.trim());
  if (cleaned.isEmpty) {
    return [];
  }
  final decodedJson = _decodeDomainServerData(cleaned);
  final decoded = jsonDecode(decodedJson);
  final serverList = decoded is Map ? decoded["Server"] : null;
  if (serverList is! List) {
    return [];
  }
  return serverList.map((e) => "$e").where((e) => e.isNotEmpty).toList();
}

Future<String?> _httpGetText(String url) async {
  return AppHttpClient.getTextOrNull(
    url,
    requestTimeout: const Duration(seconds: 12),
    retries: 1,
  );
}

String _stripNonAsciiPrefix(String text) {
  var index = 0;
  while (index < text.length) {
    final code = text.codeUnitAt(index);
    if (code <= 0x7F) {
      break;
    }
    index++;
  }
  return text.substring(index);
}

String _decodeDomainServerData(String data) {
  final normalized = data.replaceAll(RegExp(r"\s"), "");
  final decoded = base64.decode(normalized);
  final key = _md5HexBytes(_apiDomainServerSecret);
  final decrypted = _aesEcbDecrypt(Uint8List.fromList(decoded), key);
  return _pkcs7UnpadToString(decrypted);
}

Uint8List _md5HexBytes(String input) {
  final digest = md5.convert(utf8.encode(input)).toString();
  return Uint8List.fromList(utf8.encode(digest));
}

Uint8List _aesEcbDecrypt(Uint8List data, Uint8List key) {
  final cipher = pc.ECBBlockCipher(pc.AESEngine());
  cipher.init(false, pc.KeyParameter(key));
  final blockSize = cipher.blockSize;
  final output = Uint8List(data.length);
  for (var offset = 0; offset < data.length; offset += blockSize) {
    cipher.processBlock(data, offset, output, offset);
  }
  return output;
}

String _pkcs7UnpadToString(Uint8List data) {
  if (data.isEmpty) {
    return "";
  }
  final pad = data.last;
  final cut = data.length - pad;
  if (pad <= 0 || pad > data.length) {
    return utf8.decode(data, allowMalformed: true);
  }
  return utf8.decode(data.sublist(0, cut), allowMalformed: true);
}

Future<T?> chooseApiDialog<T>(BuildContext buildContext) async {
  return await showDialog<T>(
    context: buildContext,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: const Text("API分流"),
        children: [
          ..._apiList.map(
            (e) => SimpleDialogOption(
              child: ApiOptionRow(
                e,
                key: Key("API:${e}"),
              ),
              onPressed: () {
                Navigator.of(context).pop(e);
              },
            ),
          ),
          SimpleDialogOption(
            child: const Text("手动输入"),
            onPressed: () async {
              Navigator.of(context).pop(await _manualInputApiHost(context));
            },
          ),
          SimpleDialogOption(
            child: const Text("取消"),
            onPressed: () {
              Navigator.of(context).pop(null);
            },
          ),
        ],
      );
    },
  );
}

final TextEditingController _controller = TextEditingController();

Future<String> _manualInputApiHost(BuildContext context) async {
  _controller.text = _apiHost;
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("手动输入API地址"),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: "www.example.com",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(_controller.text);
            },
            child: const Text("确定"),
          ),
        ],
      );
    },
  );
}

class ApiOptionRow extends StatefulWidget {
  final String value;

  const ApiOptionRow(this.value, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ApiOptionRowState();
}

class _ApiOptionRowState extends State<ApiOptionRow> {
  late Future<int> _feature;

  @override
  void initState() {
    super.initState();
    _feature = methods.ping(widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(widget.value),
        Expanded(child: Container()),
        FutureBuilder(
          future: _feature,
          builder: (
            BuildContext context,
            AsyncSnapshot<int> snapshot,
          ) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const PingStatus(
                "测速中",
                Colors.blue,
              );
            }
            if (snapshot.hasError) {
              return const PingStatus(
                "失败",
                Colors.red,
              );
            }
            int ping = snapshot.requireData;
            if (ping <= 200) {
              return PingStatus(
                "${ping}ms",
                Colors.green,
              );
            }
            if (ping <= 500) {
              return PingStatus(
                "${ping}ms",
                Colors.yellow,
              );
            }
            return PingStatus(
              "${ping}ms",
              Colors.orange,
            );
          },
        ),
      ],
    );
  }
}

class PingStatus extends StatelessWidget {
  final String title;
  final Color color;

  const PingStatus(this.title, this.color, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '\u2022',
          style: TextStyle(
            color: color,
          ),
        ),
        Text(" $title"),
      ],
    );
  }
}

Future chooseApiHost(BuildContext context) async {
  final choose = await chooseApiDialog(context);
  if (choose != null) {
    await methods.saveApiHost(choose);
    _apiHost = choose;
  }
}

Widget apiHostSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        onTap: () async {
          await chooseApiHost(context);
          setState(() {});
        },
        title: const Text("API分流"),
        subtitle: Text(_apiHost),
      );
    },
  );
}
