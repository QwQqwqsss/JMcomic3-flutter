import 'dart:io';

bool get normalPlatform =>
    Platform.isAndroid ||
    Platform.isIOS ||
    Platform.isLinux ||
    Platform.isMacOS ||
    Platform.isWindows;
