import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:jmcomic3/basic/commons.dart';
import 'package:jmcomic3/configs/versions.dart';
import 'package:jmcomic3/l10n/app_localizations.dart';
import 'package:jmcomic3/screens/components/badge.dart';

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final info = latestVersionInfo();
      if ((info ?? "").trim().isEmpty) {
        await silentCheckNewVersion();
        if (mounted) setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return rightClickPop(child: buildScreen(context), context: context);
  }

  Widget buildScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.about),
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
      child: Text(context.l10n.currentVersionLabel(currentVersion())),
    );
  }

  Widget _buildNewestVersion() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Text.rich(TextSpan(
        children: [
          TextSpan(text: "${context.l10n.latestVersion}: "),
          _buildNewestVersionSpan(),
          _buildCheckButton(),
        ],
      )),
    );
  }

  InlineSpan _buildNewestVersionSpan() {
    final versionText = latestVersionName ?? context.l10n.noNewVersion;
    return WidgetSpan(
      child: Container(
        padding: const EdgeInsets.only(right: 20),
        child: VersionBadged(
          child: Text(
            "$versionText    ",
          ),
        ),
      ),
    );
  }

  InlineSpan _buildCheckButton() {
    return WidgetSpan(
      child: GestureDetector(
        child: Text(
          context.l10n.checkUpdate,
          style: TextStyle(height: 1.3, color: Colors.blue),
          strutStyle: const StrutStyle(height: 1.3),
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
        child: Text(
          context.l10n.goToDownloadPage,
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
    if (info != null && info.trim().isNotEmpty) {
      info = "## ${context.l10n.updateContent}\n\n$info";
    } else {
      info =
          "${context.l10n.updateContent}\n\n${context.l10n.updateContentUnavailable}";
    }
    return Container(
      padding: const EdgeInsets.all(20),
      child: MarkdownBody(data: info),
    );
  }
}
