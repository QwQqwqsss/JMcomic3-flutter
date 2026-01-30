import 'package:flutter/material.dart';
import 'package:jasmine/basic/commons.dart';
import 'package:jasmine/configs/android_display_mode.dart';
import 'package:jasmine/configs/proxy.dart';
import 'package:jasmine/configs/versions.dart';
import 'package:jasmine/screens/components/badge.dart';

import '../configs/is_pro.dart';
import '../configs/theme.dart';
import '../configs/using_right_click_pop.dart';
import 'components/right_click_pop.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AboutState();
  }
}

class _AboutState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return rightClickPop(child: buildScreen(context), context: context);
  }

  Widget buildScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("\u5173\u4e8e"),
      ),
      body: ListView(
        children: [
          const Divider(),
          _buildLogo(),
          const Divider(),
          _buildCurrentVersion(),
          const Divider(),
          _buildNewestVersion(),
          if (latestVersion != null) _buildGotoGithub(),
          const Divider(),
          _buildVersionText(),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double? width, height;
        if (constraints.maxWidth < constraints.maxHeight) {
          width = constraints.maxWidth / 3;
        } else {
          height = constraints.maxHeight / 3;
        }
        double l = width ?? height!;
        return Column(
          children: [
            Container(height: l / 4),
            SizedBox(
              width: l,
              height: l,
              child: ConstrainedBox(
                constraints: const BoxConstraints.expand(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Opacity(
                    opacity: 0.9,
                    child: Icon(
                      Icons.abc,
                      size: l,
                    ),
                  ),
                ),
              ),
            ),
            Container(height: l / 4),
          ],
        );
      },
    );
  }

  Widget _buildCurrentVersion() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Text("\u5f53\u524d\u7248\u672c : ${currentVersion()}"),
    );
  }

  Widget _buildNewestVersion() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Text.rich(TextSpan(
        children: [
          const TextSpan(text: "\u6700\u65b0\u7248\u672c: "),
          _buildNewestVersionSpan(),
          _buildCheckButton(),
        ],
      )),
    );
  }

  InlineSpan _buildNewestVersionSpan() {
    return WidgetSpan(
      child: Container(
        padding: const EdgeInsets.only(right: 20),
        child: VersionBadged(
          child: Text(
            "${latestVersion ?? "\u6ca1\u6709\u68c0\u6d4b\u5230\u65b0\u7248\u672c"}    ",
          ),
        ),
      ),
    );
  }

  InlineSpan _buildCheckButton() {
    return WidgetSpan(
      child: GestureDetector(
        child: const Text(
          "\u68c0\u67e5\u66f4\u65b0",
          style: TextStyle(height: 1.3, color: Colors.blue),
          strutStyle: StrutStyle(height: 1.3),
        ),
        onTap: () async {
          await manualCheckNewVersion(context);
          setState(() {});
        },
      ),
    );
  }

  Widget _buildGotoGithub() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: GestureDetector(
        child: const Text(
          "\u524d\u5f80\u4e0b\u8f7d\u5730\u5740",
          style: TextStyle(color: Colors.blue),
        ),
        onTap: () async {
          openUrl(releasePageUrl);
        },
      ),
    );
  }

  Widget _buildVersionText() {
    var info = latestVersionInfo();
    if (info != null) {
      info = "\u66f4\u65b0\u5185\u5bb9\n\n$info";
    }
    return Container(
      padding: const EdgeInsets.all(20),
      child: SelectableText(info ?? ""),
    );
  }
}
