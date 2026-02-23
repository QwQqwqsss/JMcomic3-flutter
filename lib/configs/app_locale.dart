import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:jmcomic3/basic/commons.dart';
import 'package:jmcomic3/basic/methods.dart';
import 'package:jmcomic3/l10n/app_localizations.dart';

const _propertyName = 'app_locale';
const _followSystem = 'system';

String _localeCode = _followSystem;
final _event = Event();

Event get appLocaleEvent => _event;

Locale? get currentAppLocale {
  if (_localeCode == _followSystem) {
    return null;
  }
  return Locale(_localeCode);
}

Future initAppLocale() async {
  final value = await methods.loadProperty(_propertyName);
  if (value == 'zh' || value == 'en' || value == _followSystem) {
    _localeCode = value;
  } else {
    _localeCode = _followSystem;
  }
  _event.broadcast();
}

String _nameOfLocale(BuildContext context, String code) {
  final l10n = context.l10n;
  switch (code) {
    case 'zh':
      return l10n.simplifiedChinese;
    case 'en':
      return l10n.english;
    default:
      return l10n.followSystem;
  }
}

Future chooseAppLocale(BuildContext context) async {
  final l10n = context.l10n;
  final value = await chooseMapDialog<String>(
    context,
    title: l10n.language,
    values: {
      l10n.followSystem: _followSystem,
      l10n.simplifiedChinese: 'zh',
      l10n.english: 'en',
    },
  );
  if (value == null || value == _localeCode) {
    return;
  }
  _localeCode = value;
  await methods.saveProperty(_propertyName, value);
  _event.broadcast();
}

Widget appLocaleSetting(BuildContext context) {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text(context.l10n.language),
        subtitle: Text(_nameOfLocale(context, _localeCode)),
        onTap: () async {
          await chooseAppLocale(context);
          setState(() {});
        },
      );
    },
  );
}
