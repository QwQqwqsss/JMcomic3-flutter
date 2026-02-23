import 'package:flutter/material.dart';
import 'package:jmcomic3/configs/login.dart';
import 'package:jmcomic3/l10n/app_localizations.dart';
import 'package:jmcomic3/screens/about_screen.dart';
import 'package:jmcomic3/screens/comments_screen.dart';
import 'package:jmcomic3/screens/components/avatar.dart';
import 'package:jmcomic3/screens/pro_oh_screen.dart';
import 'package:jmcomic3/screens/pro_screen.dart';
import 'package:jmcomic3/screens/components/recommend_links_panel.dart';
import 'package:jmcomic3/screens/settings_screen.dart';
import 'package:jmcomic3/screens/view_log_screen.dart';

import '../basic/platform.dart';
import '../configs/daily_sign.dart';
import '../configs/is_pro.dart';
import 'components/badge.dart';
import 'downloads_screen.dart';
import 'favorites_screen.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    loginEvent.subscribe(_setState);
    proEvent.subscribe(_setState);
    dailySignEvent.subscribe(_setState);
    super.initState();
  }

  @override
  void dispose() {
    loginEvent.unsubscribe(_setState);
    proEvent.unsubscribe(_setState);
    dailySignEvent.unsubscribe(_setState);
    super.dispose();
  }

  void _setState(_) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.profile), actions: [
        if (!normalPlatform)
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return const ProOhScreen();
              }));
            },
            icon: Icon(
              hasProAccess ? Icons.offline_bolt : Icons.offline_bolt_outlined,
            ),
          ),
        if (normalPlatform)
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return const ProScreen();
              }));
            },
            icon: Icon(
              hasProAccess ? Icons.offline_bolt : Icons.offline_bolt_outlined,
            ),
          ),
        _buildSettingsIcon(),
        if (normalPlatform) _buildAboutIcon(),
      ]),
      body: SafeArea(
        child: ListView(
          children: [
            _buildCard(),
            const Divider(),
            _buildFavorites(),
            const Divider(),
            _buildViewLog(),
            const Divider(),
            _buildDownloads(),
            const Divider(),
            _buildComments(),
            const Divider(),
            const RecommendLinksPanel(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            ),
            // _buildFdT(),
            // const Divider(),
            // _buildSettingsT(),
            // const Divider(),
            // _buildAboutT(),
            // const Divider(),
            Container(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCard() {
    late Widget child;
    switch (loginStatus) {
      case LoginStatus.notSet:
        child = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLoginButton(context.l10n.loginRegister),
            const SizedBox(height: 8),
          ],
        );
        break;
      case LoginStatus.logging:
        child = _buildLoginLoading();
        break;
      case LoginStatus.loginSuccess:
        child = _buildSelfInfoCard();
        break;
      case LoginStatus.guest:
        child = _buildGuestCard();
        break;
      case LoginStatus.loginField:
        child = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLoginButton(context.l10n.loginFailed),
            const SizedBox(height: 8),
            const SizedBox(height: 10),
            _buildLoginErrorButton(),
          ],
        );
        break;
    }
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardMinHeight =
        loginStatus == LoginStatus.loginSuccess ? 320.0 : 210.0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        constraints: BoxConstraints(minHeight: cardMinHeight),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isLight
                ? const [
                    Color(0xFFF8FBFF),
                    Color(0xFFEAF2FF),
                    Color(0xFFF6F7FA),
                  ]
                : const [
                    Color(0xFF232B3A),
                    Color(0xFF1D2230),
                    Color(0xFF161B26),
                  ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isLight
                ? Colors.blueGrey.withValues(alpha: .16)
                : Colors.white.withValues(alpha: .08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isLight ? .08 : .24),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  Widget _buildLoginButton(String title) {
    return MaterialButton(
      onPressed: () async {
        await loginDialog(context);
      },
      child: Container(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.orange.shade700,
          border: Border.all(
            color: Colors.black,
            style: BorderStyle.solid,
            width: .5,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLoading() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final size = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        return Icon(Icons.refresh,
            size: size * .5, color: Colors.white.withValues(alpha: .5));
      },
    );
  }

  Widget _buildLoginErrorButton() {
    return MaterialButton(
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(context.l10n.loginFailed),
              content: SelectableText(loginMessage),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(context.l10n.confirm),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          border: Border.all(
            color: Colors.black,
            style: BorderStyle.solid,
            width: .5,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        child: Text(
          context.l10n.viewError,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSelfInfoCard() {
    final brightness = Theme.of(context).brightness;
    final theme = Theme.of(context);
    final isLight = brightness == Brightness.light;
    Color statusColor;
    switch (dailySignStatus) {
      case DailySignStatus.signed:
        statusColor = isLight ? Colors.green.shade700 : Colors.green.shade200;
        break;
      case DailySignStatus.error:
        statusColor = isLight ? Colors.red.shade700 : Colors.red.shade200;
        break;
      case DailySignStatus.checking:
        statusColor = isLight ? Colors.orange.shade700 : Colors.orange.shade200;
        break;
      case DailySignStatus.unchecked:
        statusColor = isLight ? Colors.black54 : Colors.white70;
        break;
    }
    final statusStyle =
        (theme.textTheme.bodySmall ?? const TextStyle()).copyWith(
      fontSize: 12,
      color: statusColor,
      fontWeight: FontWeight.w600,
    );
    final detailStyle =
        (theme.textTheme.bodySmall ?? const TextStyle()).copyWith(
      fontSize: 12,
      color: isLight ? Colors.black54 : Colors.white70,
      fontWeight: FontWeight.w500,
    );
    final titleStyle =
        (theme.textTheme.titleSmall ?? const TextStyle()).copyWith(
      color: isLight ? Colors.black87 : Colors.white,
      fontWeight: FontWeight.w600,
    );
    final uidText = "UID ${selfInfo.uid}";
    final levelText = "${selfInfo.levelName} Lv.${selfInfo.level}";
    final expPercentText = "${_formatExpPercent(selfInfo.expPercent)}%";
    final genderText = _formatGender(selfInfo.gender);
    final nickname =
        selfInfo.fname.trim().isEmpty ? "-" : selfInfo.fname.trim();
    final message = selfInfo.message.trim();
    final canSign = dailySignStatus != DailySignStatus.checking;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Avatar(selfInfo.photo),
        ),
        const SizedBox(height: 10),
        Text(
          selfInfo.username,
          style: titleStyle,
        ),
        const SizedBox(height: 2),
        Text(uidText, style: detailStyle),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildSelfInfoBadge(
                context,
                context.l10n.level,
                levelText,
                Icons.workspace_premium,
              ),
              _buildSelfInfoBadge(
                context,
                context.l10n.experience,
                expPercentText,
                Icons.trending_up,
              ),
              _buildSelfInfoBadge(
                context,
                context.l10n.coin,
                "${selfInfo.coin}",
                Icons.monetization_on,
              ),
              _buildSelfInfoBadge(
                context,
                context.l10n.badges,
                "${selfInfo.badges.length}",
                Icons.verified_outlined,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (selfInfo.email.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "${context.l10n.email}: ${selfInfo.email}",
              style: detailStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "${context.l10n.nickname}: $nickname  ${context.l10n.gender}: $genderText",
            style: detailStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        if (message.isNotEmpty) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "${context.l10n.signature}: $message",
              style: detailStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          dailySignStatusLabel(context),
          style: statusStyle,
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 132, minHeight: 44),
          child: FilledButton.icon(
            onPressed: canSign
                ? () async {
                    await checkDailySignStatus(context, toast: true);
                  }
                : null,
            icon: Icon(
              canSign ? Icons.check_circle_outline : Icons.sync,
              size: 18,
            ),
            label: Text(
              canSign ? context.l10n.manualSign : context.l10n.signing,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelfInfoBadge(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isLight
            ? Colors.white.withValues(alpha: .72)
            : Colors.white.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLight
              ? Colors.black.withValues(alpha: .08)
              : Colors.white.withValues(alpha: .12),
          width: .8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isLight ? Colors.black54 : Colors.white70,
          ),
          const SizedBox(width: 4),
          Text(
            "$label:$value",
            style: (Theme.of(context).textTheme.bodySmall ?? const TextStyle())
                .copyWith(
              fontSize: 11,
              color: isLight ? Colors.black87 : Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatGender(String raw) {
    final value = raw.trim();
    if (value.isEmpty) {
      return "-";
    }
    if (value == "m" || value == "male" || value == "1") {
      return context.l10n.male;
    }
    if (value == "f" || value == "female" || value == "2") {
      return context.l10n.female;
    }
    return value;
  }

  String _formatExpPercent(double value) {
    final normalized = value <= 1 ? value * 100 : value;
    final safe = normalized.isNaN ? 0.0 : normalized.clamp(0, 100).toDouble();
    if (safe >= 10) {
      return safe.toStringAsFixed(0);
    }
    return safe.toStringAsFixed(1);
  }

  Widget _buildGuestCard() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.explore_outlined, size: 48),
        const SizedBox(height: 10),
        Text(context.l10n.guestMode),
        const SizedBox(height: 8),
        _buildLoginButton(context.l10n.login),
      ],
    );
  }

  Widget _buildFavorites() {
    return ListTile(
      onTap: () async {
        if (!await ensureJwtAccess(
          context,
          feature: context.l10n.featureFavoritesFolder,
        )) {
          return;
        }
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) {
            return const FavoritesScreen();
          },
        ));
      },
      title: Text(context.l10n.favorites),
    );
  }

  Widget _buildViewLog() {
    return ListTile(
      onTap: () async {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) {
            return const ViewLogScreen();
          },
        ));
      },
      title: Text(context.l10n.viewHistory),
    );
  }

  Widget _buildDownloads() {
    return ListTile(
      onTap: () async {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) {
            return const DownloadsScreen();
          },
        ));
      },
      title: Text(context.l10n.downloadList),
    );
  }

  Widget _buildComments() {
    return ListTile(
      onTap: () async {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) {
            return const CommentsScreen();
          },
        ));
      },
      title: Text(context.l10n.comments),
    );
  }

  Widget _buildSettingsIcon() {
    return IconButton(
      onPressed: () async {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) {
            return const SettingsScreen();
          },
        ));
      },
      icon: const Icon(Icons.settings),
    );
  }

  Widget _buildAboutIcon() {
    return IconButton(
      onPressed: () async {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) {
            return const AboutScreen();
          },
        ));
      },
      icon: const VersionBadged(
        child: Padding(
          padding: EdgeInsets.all(1),
          child: Icon(Icons.info_outlined),
        ),
      ),
    );
  }
}
