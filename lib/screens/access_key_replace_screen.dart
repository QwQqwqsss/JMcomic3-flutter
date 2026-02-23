import 'package:flutter/material.dart';
import 'package:jmcomic3/basic/log.dart';
import 'package:jmcomic3/l10n/app_localizations.dart';

import '../basic/commons.dart';
import '../basic/methods.dart';
import '../configs/is_pro.dart';
import 'components/right_click_pop.dart';

class AccessKeyReplaceScreen extends StatefulWidget {
  final String accessKey;

  const AccessKeyReplaceScreen({Key? key, required this.accessKey})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _AccessKeyReplaceScreenState();
}

class _AccessKeyReplaceScreenState extends State<AccessKeyReplaceScreen> {
  bool _loading = true;
  String _username = "";
  String _patId = "";
  String _bindUid = "";
  bool _isPro = false;
  int _reBind = 0;

  @override
  void initState() {
    _load();
    super.initState();
  }

  Future<void> _load() async {
    try {
      if (mounted) {
        setState(() {
          _loading = true;
        });
      }

      _username = await methods.loadLastLoginUsername();
      final check = await checkPatAccessKey(widget.accessKey);

      final reBind = check["re_bind"];
      final fd = check["fd"];

      if (!mounted) {
        return;
      }
      setState(() {
        _patId = "${check["email"] ?? ""}";
        _bindUid = "${check["bind_user"] ?? ""}";
        _isPro = fd == true || "$fd" == "true" || "$fd" == "1";
        _reBind = reBind is int ? reBind : int.tryParse("$reBind") ?? 0;
        _loading = false;
      });
    } catch (e, s) {
      debugPrient("$e\n$s");
      if (!mounted) {
        return;
      }
      defaultToast(
        context,
        "${context.l10n.tr("Verification failed", en: "Verification failed")}: $e",
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return rightClickPop(child: _buildScreen(context), context: context);
  }

  Widget _buildScreen(BuildContext context) {
    final l10n = context.l10n;
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.tr("Verify PAT key", en: "Verify PAT key")),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr("Verify PAT key", en: "Verify PAT key")),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l10n.tr("Key verified successfully",
                en: "Key verified successfully"),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          if (useLocalProDefault)
            Text(
              l10n.tr(
                "Local Pro mode is active. PAT verification uses local cache.",
                en: "Local Pro mode is active. PAT verification uses local cache.",
              ),
              style: TextStyle(color: Colors.orange.shade700),
            ),
          if (useLocalProDefault) const SizedBox(height: 10),
          ListTile(
            title: Text(l10n.tr("PAT account", en: "PAT account")),
            subtitle: Text(
              _patId.isEmpty ? l10n.tr("Unknown", en: "Unknown") : _patId,
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.tr("Pro status", en: "Pro status")),
            subtitle: Text(
              _isPro
                  ? l10n.tr("Pro active", en: "Pro active")
                  : l10n.tr("Not Pro", en: "Not Pro"),
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(
              l10n.tr("Bound JMcomic3 account", en: "Bound JMcomic3 account"),
            ),
            subtitle: Text(
              _bindUid.isEmpty
                  ? l10n.tr("Not bound", en: "Not bound")
                  : _bindUid,
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(
              l10n.tr("Current login account", en: "Current login account"),
            ),
            subtitle: Text(
              _username.isEmpty
                  ? l10n.tr("Not logged in", en: "Not logged in")
                  : _username,
            ),
          ),
          const Divider(),
          const SizedBox(height: 20),
          if (_bindUid.isEmpty)
            ElevatedButton(
              onPressed: _bind,
              child: Text(
                l10n.tr("Bind to current account",
                    en: "Bind to current account"),
              ),
            )
          else if (_bindUid != _username)
            Column(
              children: [
                Text(
                  l10n.tr(
                    "This key is bound to another account. Unbind first or wait until rebinding is available.",
                    en: "This key is bound to another account. Unbind first or wait until rebinding is available.",
                  ),
                  style: const TextStyle(color: Colors.orange),
                ),
                const SizedBox(height: 10),
                if (_reBind > 0)
                  Text(
                    "${l10n.tr("Rebind available at", en: "Rebind available at")}: ${DateTime.fromMillisecondsSinceEpoch(_reBind * 1000)}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _bind,
                  child: Text(
                    l10n.tr("Force bind to current account",
                        en: "Force bind to current account"),
                  ),
                ),
              ],
            )
          else
            ElevatedButton(
              onPressed: _save,
              child: Text(l10n.tr("Save key", en: "Save key")),
            ),
        ],
      ),
    );
  }

  Future<void> _bind() async {
    try {
      defaultToast(context, context.l10n.tr("Binding...", en: "Binding..."));
      await bindPatAccount(widget.accessKey, _username);
      defaultToast(
        context,
        context.l10n.tr("Bind succeeded", en: "Bind succeeded"),
      );
      await reloadIsPro();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e, s) {
      debugPrient("$e\n$s");
      defaultToast(
        context,
        "${context.l10n.tr("Bind failed", en: "Bind failed")}: $e",
      );
    }
  }

  Future<void> _save() async {
    try {
      defaultToast(context, context.l10n.tr("Saving...", en: "Saving..."));
      await bindPatAccount(widget.accessKey, _username);
      defaultToast(
        context,
        context.l10n.tr("Saved successfully", en: "Saved successfully"),
      );
      await reloadIsPro();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e, s) {
      debugPrient("$e\n$s");
      defaultToast(
        context,
        "${context.l10n.tr("Save failed", en: "Save failed")}: $e",
      );
    }
  }
}
