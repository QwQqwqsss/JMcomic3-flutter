import 'package:flutter/material.dart';
import 'package:jmcomic3/basic/commons.dart';
import 'package:jmcomic3/configs/app_font_size.dart';
import 'package:jmcomic3/l10n/app_localizations.dart';

class TextPreviewScreen extends StatefulWidget {
  final String text;

  const TextPreviewScreen({
    required this.text,
    Key? key,
  }) : super(key: key);

  @override
  State<TextPreviewScreen> createState() => _TextPreviewScreenState();
}

class _TextPreviewScreenState extends State<TextPreviewScreen> {
  @override
  Widget build(BuildContext context) {
    final contentFontSize = (Theme.of(context).textTheme.bodyMedium?.fontSize ??
            14) +
        currentFontSizeAdjust(FontSizeAdjustType.fontSizeAdjustCommentContent);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.tr('评论全文', en: 'Full comment')),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              copyToClipBoard(context, widget.text);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: SelectableText(
          widget.text,
          style: TextStyle(
            fontSize: contentFontSize,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
