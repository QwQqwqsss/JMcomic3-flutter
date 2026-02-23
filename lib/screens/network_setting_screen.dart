import 'package:flutter/material.dart';
import 'package:jmcomic3/l10n/app_localizations.dart';
import 'package:jmcomic3/configs/network_api_host.dart';
import 'package:jmcomic3/configs/network_cdn_host.dart';
import 'package:jmcomic3/configs/proxy.dart';
import 'package:jmcomic3/screens/init_screen.dart';

import 'components/right_click_pop.dart';
import 'downloads_screen.dart';

class NetworkSettingScreen extends StatelessWidget {
  const NetworkSettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return rightClickPop(child: buildScreen(context), context: context);
  }

  Widget buildScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.networkSettings),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (BuildContext context) {
                  return const DownloadsScreen();
                }),
              );
            },
            icon: const Icon(Icons.download),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (BuildContext context) {
                  return const InitScreen();
                }),
              );
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: ListView(
        children: [
          apiHostSetting(),
          cdnHostSetting(),
          proxySetting(),
        ],
      ),
    );
  }
}
