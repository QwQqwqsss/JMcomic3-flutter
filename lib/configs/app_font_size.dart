import 'package:flutter/material.dart';
import 'package:jmcomic3/l10n/app_localizations.dart';

import '../basic/methods.dart';

enum FontSizeAdjustType {
  fontSizeAdjustCommentContent,
}

final valueMap = {
  FontSizeAdjustType.fontSizeAdjustCommentContent: 0,
};

Future<void> initFontSizeAdjust() async {
  for (var key in valueMap.keys) {
    var str = await methods.loadProperty(key.toString());
    if (str == "") {
      str = "0";
    }
    valueMap[key] = int.parse(str);
  }
}

int currentFontSizeAdjust(FontSizeAdjustType type) {
  return valueMap[type]!;
}

List<Widget> fontSizeAdjustSettings() {
  return [
    for (var key in valueMap.keys) fontSizeAdjustSetting(key),
  ];
}

String _fontSizeAdjustTypeName(FontSizeAdjustType type, BuildContext context) {
  switch (type) {
    case FontSizeAdjustType.fontSizeAdjustCommentContent:
      return context.l10n.tr("评论", en: "Comments");
  }
}

Widget fontSizeAdjustSetting(FontSizeAdjustType type) {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text(
          context.l10n.tr("文字大小调整", en: "Text size adjustment") +
              " - ${_fontSizeAdjustTypeName(type, context)}",
        ),
        subtitle: Slider(
          value: valueMap[type]!.toDouble(), // 当前值
          min: -5, // 最小值
          max: 5, // 最大值
          divisions: 10, // 分成 10 等分（-5 到 5）
          label: valueMap[type].toString(), // 显示滑块标签
          onChanged: (value) {
            setState(() {
              valueMap[type] = value.toInt(); // 更新当前值
            });
            methods.saveProperty(
                type.toString(), value.toInt().toString()); // 保存当前值
          },
        ),
        trailing: Text(
          valueMap[type].toString(), // 显示当前值
          style: const TextStyle(fontSize: 16),
        ),
      );
    },
  );
}
