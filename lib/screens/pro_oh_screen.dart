import 'package:flutter/material.dart';
import 'package:jmcomic3/basic/log.dart';
import 'package:jmcomic3/l10n/app_localizations.dart';

import '../basic/commons.dart';
import '../basic/methods.dart';
import '../configs/is_pro.dart';
import 'components/right_click_pop.dart';

class ProOhScreen extends StatefulWidget {
  const ProOhScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ProScreenState();
}

class _ProScreenState extends State<ProOhScreen> {
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
    super.initState();
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
          ListTile(
            title: Text(l10n.tr("Pro details", en: "Pro details")),
            subtitle: Text(
              hasProAccess
                  ? "${l10n.tr("Pro active", en: "Pro active")} (${DateTime.fromMillisecondsSinceEpoch(1000 * isProEx)})"
                  : l10n.tr("Not Pro", en: "Not Pro"),
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(
              l10n.tr("I used to support", en: "I used to support"),
            ),
            onTap: () async {
              try {
                await refreshProStatus();
                defaultToast(context, "SUCCESS");
              } catch (e, s) {
                debugPrient("$e\n$s");
                defaultToast(context, "FAIL");
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
        ],
      ),
    );
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
    methods.getProServerName().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        _serverName = value;
      });
    });
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
