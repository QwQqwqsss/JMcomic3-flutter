import 'package:flutter/material.dart';
import 'package:jmcomic3/l10n/app_localizations.dart';

import 'content_error.dart';
import 'content_loading.dart';

class ContentBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final Future<dynamic> Function() onRefresh;
  final AsyncWidgetBuilder<T> successBuilder;
  final String loadingLabel;

  const ContentBuilder({
    super.key,
    required this.future,
    required this.onRefresh,
    required this.successBuilder,
    this.loadingLabel = '',
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        if (snapshot.hasError) {
          return ContentError(
            error: snapshot.error,
            stackTrace: snapshot.stackTrace,
            onRefresh: onRefresh,
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return ContentLoading(
            label: loadingLabel.isEmpty
                ? context.l10n.tr('加载中...', en: 'Loading...')
                : loadingLabel,
          );
        }
        return successBuilder(context, snapshot);
      },
    );
  }
}
