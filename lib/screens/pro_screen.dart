import 'package:flutter/material.dart';
import 'package:jmcomic3/basic/log.dart';
import 'package:jmcomic3/l10n/app_localizations.dart';

import '../basic/commons.dart';
import '../basic/methods.dart';
import '../configs/is_pro.dart';
import 'access_key_replace_screen.dart';
import 'components/right_click_pop.dart';

class ProScreen extends StatefulWidget {
  const ProScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProScreenState();
}

class _ProScreenState extends State<ProScreen> {
  String _username = "";

  @override
  void initState() {
    methods.loadLastLoginUsername().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        _username = value;
      });
    });
    proEvent.subscribe(_setState);
    super.initState();
  }

  @override
  void dispose() {
    proEvent.unsubscribe(_setState);
    super.dispose();
  }

  void _setState(_) {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return rightClickPop(child: _buildScreen(context), context: context);
  }

  Widget _buildScreen(BuildContext context) {
    final l10n = context.l10n;
    final size = MediaQuery.of(context).size;
    final min = size.width < size.height ? size.width : size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr("Pro Center", en: "Pro Center")),
      ),
      body: ListView(
        children: [
          SizedBox(
            width: min / 2,
            height: min / 2,
            child: Center(
              child: Icon(
                hasProAccess ? Icons.offline_bolt : Icons.offline_bolt_outlined,
                size: min / 3,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          Center(child: Text(_username)),
          Container(height: 20),
          if (useLocalProDefault)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                l10n.tr(
                  "Local Pro mode is active. Backend validation sync is disabled.",
                  en: "Local Pro mode is active. Backend validation sync is disabled.",
                ),
                style: TextStyle(color: Colors.orange.shade700),
              ),
            ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              l10n.tr(
                "Login to verify Pro status.\n"
                "Tap \"I used to support\" to refresh status.\n"
                "Tap \"I just supported\" to redeem your code.\n"
                "Use PAT settings below to bind or clear PAT info.\n"
                "If status updates fail, try switching Power mode.",
                en: "Login to verify Pro status.\n"
                    "Tap \"I used to support\" to refresh status.\n"
                    "Tap \"I just supported\" to redeem your code.\n"
                    "Use PAT settings below to bind or clear PAT info.\n"
                    "If status updates fail, try switching Power mode.",
              ),
            ),
          ),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: Text(l10n.tr("Login redeem", en: "Login redeem")),
                  subtitle: Text(
                    proInfoAf.isPro
                        ? "${l10n.tr("Pro active", en: "Pro active")} (${DateTime.fromMillisecondsSinceEpoch(1000 * proInfoAf.expire)})"
                        : l10n.tr("Not Pro", en: "Not Pro"),
                  ),
                ),
              ),
              Expanded(
                child: ListTile(
                  title: Text(l10n.tr("PAT membership", en: "PAT membership")),
                  subtitle: Text(
                    proInfoPat.isPro
                        ? l10n.tr("Pro active", en: "Pro active")
                        : l10n.tr("Not Pro", en: "Not Pro"),
                  ),
                  onTap: () {
                    defaultToast(
                      context,
                      l10n.tr(
                        "Tap PAT membership below to configure.",
                        en: "Tap PAT membership below to configure.",
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const Divider(),
          ListTile(
            title: Text(
              l10n.tr("I used to support", en: "I used to support"),
            ),
            onTap: () async {
              try {
                await refreshProStatus();
                defaultToast(context, l10n.tr("SUCCESS", en: "SUCCESS"));
              } catch (e, s) {
                debugPrient("$e\n$s");
                defaultToast(context, l10n.tr("FAIL", en: "FAIL"));
              }
              await reloadIsPro();
              if (mounted) {
                setState(() {});
              }
            },
          ),
          const Divider(),
          ListTile(
            title: Text(
              l10n.tr("I just supported", en: "I just supported"),
            ),
            onTap: () async {
              final code = await displayTextInputDialog(
                context,
                title: l10n.tr("Enter code", en: "Enter code"),
              );
              if (code != null && code.isNotEmpty) {
                try {
                  await redeemCdKey(code);
                  defaultToast(context, l10n.tr("SUCCESS", en: "SUCCESS"));
                } catch (e, s) {
                  debugPrient("$e\n$s");
                  defaultToast(context, l10n.tr("FAIL", en: "FAIL"));
                }
              }
              await reloadIsPro();
              if (mounted) {
                setState(() {});
              }
            },
          ),
          const Divider(),
          const ProServerNameWidget(),
          const Divider(),
          ..._patProWidgets(),
          const Divider(),
        ],
      ),
    );
  }

  List<Widget> _patProWidgets() {
    final l10n = context.l10n;
    final widgets = <Widget>[];

    if (proInfoPat.accessKey.isNotEmpty) {
      var text = l10n.tr("Key recorded", en: "Key recorded");
      if (proInfoPat.patId.isNotEmpty) {
        text +=
            "\n${l10n.tr("PAT account", en: "PAT account")}: ${proInfoPat.patId}";
      }
      if (proInfoPat.bindUid.isNotEmpty) {
        text +=
            "\n${l10n.tr("Bound account", en: "Bound account")}: ${proInfoPat.bindUid}";
      }
      if (proInfoPat.requestDelete > 0) {
        final dateTime = DateTime.fromMillisecondsSinceEpoch(
          proInfoPat.requestDelete * 1000,
          isUtc: true,
        );
        text +=
            "\n${l10n.tr("Unbind time", en: "Unbind time")}: ${dateTime.toLocal()}";
      }
      if (proInfoPat.reBind > 0) {
        final dateTime = DateTime.fromMillisecondsSinceEpoch(
          proInfoPat.reBind * 1000,
          isUtc: true,
        );
        text +=
            "\n${l10n.tr("Rebind available at", en: "Rebind available at")}: ${dateTime.toLocal()}";
      }

      final append = <TextSpan>[];
      if (proInfoPat.bindUid.isEmpty) {
        append.add(
          TextSpan(
            text:
                "\n${l10n.tr("(Tap to bind to current account)", en: "(Tap to bind to current account)")}",
            style: const TextStyle(color: Colors.blue),
          ),
        );
      } else if (proInfoPat.bindUid != _username) {
        append.add(
          TextSpan(
            text:
                "\n${l10n.tr("(Bound to another account, tap to rebind)", en: "(Bound to another account, tap to rebind)")}",
            style: const TextStyle(color: Colors.red),
          ),
        );
      } else if (!proInfoPat.isPro) {
        append.add(
          TextSpan(
            text:
                "\n${l10n.tr("(Pro status not detected)", en: "(Pro status not detected)")}",
            style: const TextStyle(color: Colors.orange),
          ),
        );
      } else {
        append.add(
          TextSpan(
            text: "\n${l10n.tr("(Normal)", en: "(Normal)")}",
            style: const TextStyle(color: Colors.green),
          ),
        );
      }

      widgets.add(
        ListTile(
          onTap: () async {
            final choose = await chooseMapDialog<int>(
              context,
              title: l10n.tr("Choose action", en: "Choose action"),
              values: {
                l10n.tr("Refresh PAT status", en: "Refresh PAT status"): 2,
                l10n.tr("Bind to current account",
                    en: "Bind to current account"): 3,
                l10n.tr("Replace PAT key", en: "Replace PAT key"): 1,
                l10n.tr("Clear PAT info", en: "Clear PAT info"): 4,
              },
            );
            switch (choose) {
              case 1:
                _addPatAccount();
                break;
              case 2:
                _refreshPatAccount();
                break;
              case 3:
                _bindThisAccount();
                break;
              case 4:
                _clearPatInfo();
                break;
            }
          },
          title: Text(l10n.tr("PAT membership", en: "PAT membership")),
          subtitle: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: text),
                ...append,
              ],
            ),
          ),
        ),
      );
    } else {
      widgets.add(
        ListTile(
          onTap: _addPatAccount,
          title: Text(l10n.tr("PAT membership", en: "PAT membership")),
          subtitle: Text(
            l10n.tr("Tap to bind PAT membership",
                en: "Tap to bind PAT membership"),
          ),
        ),
      );
    }
    return widgets;
  }

  void _addPatAccount() async {
    final key = await displayTextInputDialog(
      context,
      title: context.l10n.tr("Enter PAT token", en: "Enter PAT token"),
    );
    if (key == null || key.isEmpty) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return AccessKeyReplaceScreen(accessKey: key);
        },
      ),
    );
    await reloadIsPro();
    if (mounted) {
      setState(() {});
    }
  }

  void _refreshPatAccount() async {
    defaultToast(context, context.l10n.tr("Please wait", en: "Please wait"));
    try {
      await reloadPatAccount();
      defaultToast(context, context.l10n.tr("SUCCESS", en: "SUCCESS"));
    } catch (e) {
      defaultToast(
        context,
        "${context.l10n.tr("FAIL", en: "FAIL")} : $e",
      );
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _bindThisAccount() async {
    defaultToast(context, context.l10n.tr("Please wait", en: "Please wait"));
    try {
      await bindPatAccount(proInfoPat.accessKey, _username);
      defaultToast(context, context.l10n.tr("SUCCESS", en: "SUCCESS"));
    } catch (e) {
      defaultToast(
        context,
        "${context.l10n.tr("FAIL", en: "FAIL")} : $e",
      );
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _clearPatInfo() async {
    await clearPat();
    defaultToast(context, context.l10n.tr("Cleared", en: "Cleared"));
    if (mounted) {
      setState(() {});
    }
  }
}

class ProServerNameWidget extends StatefulWidget {
  const ProServerNameWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProServerNameWidgetState();
}

class _ProServerNameWidgetState extends State<ProServerNameWidget> {
  String _serverName = "";

  @override
  void initState() {
    super.initState();
    _loadServerNameFromBackend();
  }

  Future<void> _loadServerNameFromBackend() async {
    try {
      final value = await methods.getProServerName();
      if (!mounted) {
        return;
      }
      setState(() {
        _serverName = value;
      });
    } catch (e) {
      debugPrient("getProServerName unsupported: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(context.l10n.tr("Power mode", en: "Power mode")),
      subtitle: Text(_loadServerName(context)),
      onTap: () async {
        final serverName = await chooseMapDialog<String>(
          context,
          title: context.l10n.tr("Choose power mode", en: "Choose power mode"),
          values: {
            context.l10n.tr("Wind power", en: "Wind power"): "HK",
            context.l10n.tr("Hydro power", en: "Hydro power"): "US",
          },
        );
        if (serverName == null || serverName.isEmpty) {
          return;
        }
        try {
          await methods.setProServerName(serverName);
          if (!mounted) {
            return;
          }
          setState(() {
            _serverName = serverName;
          });
        } catch (e) {
          debugPrient("setProServerName unsupported: $e");
          if (!mounted) {
            return;
          }
          defaultToast(
            context,
            context.l10n.tr(
              "Power mode is not supported by the current backend",
              en: "Power mode is not supported by the current backend",
            ),
          );
        }
      },
    );
  }

  String _loadServerName(BuildContext context) {
    switch (_serverName) {
      case "HK":
        return context.l10n.tr("Wind power", en: "Wind power");
      case "US":
        return context.l10n.tr("Hydro power", en: "Hydro power");
      default:
        return "";
    }
  }
}
