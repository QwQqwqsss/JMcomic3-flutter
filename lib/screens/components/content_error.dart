import 'package:flutter/material.dart';
import 'package:jmcomic3/basic/log.dart';
import 'package:jmcomic3/l10n/app_localizations.dart';
import 'error_types.dart';

class ContentError extends StatelessWidget {
  final Object? error;
  final StackTrace? stackTrace;
  final Future<void> Function() onRefresh;

  const ContentError({
    Key? key,
    required this.error,
    required this.stackTrace,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var type = errorType("$error");
    late String message;
    late IconData iconData;
    switch (type) {
      case ERROR_TYPE_NETWORK:
        iconData = Icons.wifi_off_rounded;
        message = context.l10n.tr(
          "连接不上啦, 请检查网络",
          en: "Cannot connect. Please check your network",
        );
        break;
      case ERROR_TYPE_PERMISSION:
        iconData = Icons.highlight_off;
        message = context.l10n.tr(
          "没有权限或路径不可用",
          en: "No permission or path unavailable",
        );
        break;
      case ERROR_TYPE_TIME:
        iconData = Icons.timer_off;
        message = context.l10n.tr("请检查设备时间", en: "Please check device time");
        break;
      case ERROR_TYPE_UNDER_REVIEW:
        iconData = Icons.highlight_off;
        message = context.l10n.tr(
          "资源未审核或不可用",
          en: "Resource is unavailable or under review",
        );
        break;
      default:
        iconData = Icons.highlight_off;
        message = context.l10n.tr("啊哦, 被玩坏了", en: "Oops, something went wrong");
        break;
    }
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        debugPrient("$error");
        debugPrient("$stackTrace");
        var width = constraints.maxWidth;
        var height = constraints.maxHeight;
        var min = width < height ? width : height;
        var iconSize = min / 2.3;
        var textSize = min / 16;
        var tipSize = min / 20;
        var infoSize = min / 30;
        return GestureDetector(
          onTap: onRefresh,
          child: ListView(
            children: [
              Container(
                height: height,
                child: Column(
                  children: [
                    Expanded(child: Container()),
                    Container(
                      child: Icon(
                        iconData,
                        size: iconSize,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Container(height: min / 10),
                    Container(
                      padding: const EdgeInsets.only(
                        left: 30,
                        right: 30,
                      ),
                      child: Text(
                        message,
                        style: TextStyle(fontSize: textSize),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Text(
                      context.l10n.tr('(点击刷新)', en: '(Tap to refresh)'),
                      style: TextStyle(fontSize: tipSize),
                    ),
                    Container(height: min / 15),
                    Text('$error', style: TextStyle(fontSize: infoSize)),
                    Expanded(child: Container()),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
