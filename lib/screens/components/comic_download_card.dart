import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jmcomic3/l10n/app_localizations.dart';

import '../../basic/methods.dart';
import 'images.dart';

class ComicDownloadCard extends StatelessWidget {
  final DownloadAlbum comic;

  const ComicDownloadCard(
    this.comic, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(fontWeight: FontWeight.bold);
    final authorStyle = TextStyle(
      fontSize: 13,
      color: Colors.pink.shade300,
    );
    return Container(
      padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Card(
            child: JM3x4Cover(
              comicId: comic.id,
              width: 100 * 3 / 4,
              height: 100,
            ),
          ),
          Container(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(comic.name, style: titleStyle),
                Container(height: 4),
                Text(_author(comic.author), style: authorStyle),
                Container(height: 4),
                _buildCategoryRow(),
                Container(height: 4),
                Text.rich(TextSpan(children: [
                  const WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(Icons.download, size: 12),
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Container(width: 3),
                  ),
                  TextSpan(
                    text: "${comic.dledImageCount} / ${comic.imageCount}",
                    style: const TextStyle(fontSize: 10),
                  ),
                ])),
                ...(comic.dlStatus == 0)
                    ? [
                        Text(
                          context.l10n.tr("队列中", en: "Queued"),
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ]
                    : [],
                ...(comic.dlStatus == 1)
                    ? [
                        Text(
                          context.l10n.tr("已下载", en: "Downloaded"),
                          style: const TextStyle(color: Colors.green),
                        ),
                      ]
                    : [],
                ...(comic.dlStatus == 2)
                    ? [
                        Text(
                          context.l10n.tr("已失败", en: "Failed"),
                          style: const TextStyle(color: Colors.red),
                        ),
                      ]
                    : [],
                ...(comic.dlStatus == 3)
                    ? [
                        Text(
                          context.l10n.tr("删除中", en: "Deleting"),
                          style: const TextStyle(color: Colors.orange),
                        ),
                      ]
                    : [],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow() {
    if (comic is ComicSimple) {
      var _comic = comic as ComicSimple;
      return Row(
        children: [
          ..._c(_comic.category),
          ..._c(_comic.categorySub),
        ],
      );
    }
    return Container();
  }

  List<Widget> _c(ComicSimpleCategory category) {
    if (category.title == null) {
      return [];
    }
    return [
      Text(category.title!),
      Container(width: 15),
    ];
  }
}

String _author(String author) {
  try {
    return List.of(jsonDecode(author)).cast<String>().join(", ");
  } catch (e) {
    return author;
  }
}
