import 'package:flutter/material.dart';
import 'package:jmcomic3/l10n/app_localizations.dart';

class ContentLoading extends StatelessWidget {
  final String? label;

  const ContentLoading({Key? key, this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        var width = constraints.maxWidth;
        var height = constraints.maxHeight;
        var min = width < height ? width : height;
        var theme = Theme.of(context);
        return Center(
          child: Column(
            children: [
              Expanded(child: Container()),
              SizedBox(
                width: min / 2,
                height: min / 2,
                child: CircularProgressIndicator(
                  color: theme.colorScheme.secondary,
                  backgroundColor: Colors.grey[100],
                ),
              ),
              Container(height: min / 10),
              Text(
                label ?? context.l10n.loading,
                style: TextStyle(fontSize: min / 15),
              ),
              Expanded(child: Container()),
            ],
          ),
        );
      },
    );
  }
}
