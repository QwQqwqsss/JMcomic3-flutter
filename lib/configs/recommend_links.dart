import 'package:event/event.dart';

import '../basic/methods.dart';

final recommendLinksEvent = Event();
Map<String, String> _recommendLinks = {};
const _followChannelLink = "https://qm.qq.com/q/h3p372R200";

Map<String, String> currentRecommendLinks() => _recommendLinks;

Future<void> initRecommendLinks() async {
  try {
    _recommendLinks = await methods.configLinks();
    _recommendLinks = _replaceFollowChannelLink(_recommendLinks);
  } catch (_) {
    _recommendLinks = {};
  }
  recommendLinksEvent.broadcast();
}

Map<String, String> _replaceFollowChannelLink(Map<String, String> src) {
  final result = Map<String, String>.from(src);
  for (final key in result.keys.toList()) {
    if (key.contains("关注频道") || key.trim() == "频道") {
      result[key] = _followChannelLink;
    }
  }
  return result;
}
