import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = <Locale>[
    Locale('zh'),
    Locale('en'),
  ];

  static AppLocalizations of(BuildContext context) {
    final result =
        Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(result != null, 'No AppLocalizations found in context');
    return result!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'zh': {
      'navBrowse': '浏览',
      'navLibrary': '书架',
      'initializing': '初始化中...',
      'initFailedSetNetwork': '初始化失败，请设置网络',
      'authTitle': '身份验证',
      'authPrompt': '您之前开启了身份验证，请点击这里完成验证后进入应用。',
      'login': '登录',
      'account': '账号',
      'password': '密码',
      'inputAccount': '请输入账号',
      'inputPassword': '请输入密码',
      'guestMode': '游客模式',
      'guestModeSubtitle': '无需登录即可进入，收藏与评论等功能需登录后使用',
      'browse': '浏览',
      'pleaseLogin': '请先登录',
      'loggingIn': '登录中',
      'profile': '个人中心',
      'loginFailed': '登录失败',
      'confirm': '确认',
      'loginRegister': '登录 / 注册',
      'viewError': '查看错误',
      'level': '等级',
      'experience': '经验',
      'coin': '金币',
      'badges': '徽章',
      'email': '邮箱',
      'nickname': '昵称',
      'gender': '性别',
      'male': '男',
      'female': '女',
      'signature': '签名',
      'manualSign': '手动签到',
      'signing': '签到中...',
      'favorites': '收藏夹',
      'viewHistory': '浏览记录',
      'downloads': '下载',
      'comments': '评论区',
      'settings': '设置',
      'sectionUserNetwork': '用户和网络',
      'sectionReading': '阅读',
      'sectionSync': '同步',
      'sectionSystemApp': '系统和应用程序',
      'clearAccount': '清除账号信息',
      'clearAccountConfirm': '您确定要清除账号信息并退出 APP 吗？',
      'exportIncomplete': '导出下载到目录(即使没有下载完)',
      'language': '语言',
      'followSystem': '跟随系统',
      'simplifiedChinese': '简体中文',
      'english': 'English',
      'about': '关于',
      'currentVersion': '当前版本',
      'latestVersion': '最新版本',
      'noNewVersion': '没有检测到新版本',
      'checkUpdate': '检查更新',
      'goToDownloadPage': '前往下载地址',
      'updateContent': '更新内容',
      'updateContentUnavailable': '未获取到更新内容，可点击“检查更新”重试。',
      'discussion': '讨论区',
      'allComments': '全部评论',
      'myComments': '我的评论',
      'goLogin': '去登录',
      'loading': '加载中',
      'delete': '删除',
      'choose': '请选择',
      'yes': '是',
      'no': '否',
      'pleaseSelectExportContent': '请选择导出的内容',
      'threadSuffix': '线程',
      'all': '全部',
      'chooseFolder': '选择文件夹',
      'chooseSort': '选择排序',
      'sortByFavoriteTime': '收藏时间',
      'sortByUpdateTime': '更新时间',
      'featureFavoritesFolder': '收藏夹',
      'clearAllHistory': '清除所有历史记录？',
      'deleteViewHistory': '删除浏览记录',
      'weekMustSee': '每周必看',
      'noContentAvailable': '暂无可用内容',
      'nextIssue': '下一期',
      'noMoreIssue': '没有更多期数了',
      'switchedToNextIssue': '已切换到下一期',
      'networkSettings': '网络设置',
      'tipLoginRequired': '请先登录',
      'tipMyCommentsNeedLogin': '我的评论需要登录后查看',
      'downloadList': '下载列表',
    },
    'en': {
      'navBrowse': 'Browse',
      'navLibrary': 'Library',
      'initializing': 'Initializing...',
      'initFailedSetNetwork':
          'Initialization failed. Please configure network.',
      'authTitle': 'Authentication',
      'authPrompt':
          'Authentication is enabled. Tap here to verify and continue.',
      'login': 'Login',
      'account': 'Account',
      'password': 'Password',
      'inputAccount': 'Enter account',
      'inputPassword': 'Enter password',
      'guestMode': 'Guest Mode',
      'guestModeSubtitle':
          'Continue without login. Favorites and comments require login.',
      'browse': 'Browse',
      'pleaseLogin': 'Please login first',
      'loggingIn': 'Logging in',
      'profile': 'Profile',
      'loginFailed': 'Login failed',
      'confirm': 'Confirm',
      'loginRegister': 'Login / Register',
      'viewError': 'View Error',
      'level': 'Level',
      'experience': 'EXP',
      'coin': 'Coins',
      'badges': 'Badges',
      'email': 'Email',
      'nickname': 'Nickname',
      'gender': 'Gender',
      'male': 'Male',
      'female': 'Female',
      'signature': 'Signature',
      'manualSign': 'Manual Sign-in',
      'signing': 'Signing...',
      'favorites': 'Favorites',
      'viewHistory': 'History',
      'downloads': 'Downloads',
      'comments': 'Comments',
      'settings': 'Settings',
      'sectionUserNetwork': 'Account & Network',
      'sectionReading': 'Reader',
      'sectionSync': 'Sync',
      'sectionSystemApp': 'System & App',
      'clearAccount': 'Clear Account Data',
      'clearAccountConfirm':
          'Are you sure you want to clear account data and exit the app?',
      'exportIncomplete': 'Export downloads (including incomplete tasks)',
      'language': 'Language',
      'followSystem': 'Follow System',
      'simplifiedChinese': 'Simplified Chinese',
      'english': 'English',
      'about': 'About',
      'currentVersion': 'Current Version',
      'latestVersion': 'Latest Version',
      'noNewVersion': 'No new version detected',
      'checkUpdate': 'Check Update',
      'goToDownloadPage': 'Go to download page',
      'updateContent': 'Release Notes',
      'updateContentUnavailable':
          'Release notes are unavailable. Tap "Check Update" to retry.',
      'discussion': 'Discussion',
      'allComments': 'All Comments',
      'myComments': 'My Comments',
      'goLogin': 'Login',
      'loading': 'Loading',
      'delete': 'Delete',
      'choose': 'Choose',
      'yes': 'Yes',
      'no': 'No',
      'pleaseSelectExportContent': 'Please select content to export',
      'threadSuffix': 'threads',
      'all': 'All',
      'chooseFolder': 'Choose Folder',
      'chooseSort': 'Choose Sort',
      'sortByFavoriteTime': 'Favorite Time',
      'sortByUpdateTime': 'Update Time',
      'featureFavoritesFolder': 'Favorites',
      'clearAllHistory': 'Clear all history records?',
      'deleteViewHistory': 'Delete view history',
      'weekMustSee': 'Weekly Picks',
      'noContentAvailable': 'No content available',
      'nextIssue': 'Next Issue',
      'noMoreIssue': 'No more issues',
      'switchedToNextIssue': 'Switched to next issue',
      'networkSettings': 'Network Settings',
      'tipLoginRequired': 'Please login first',
      'tipMyCommentsNeedLogin': 'Login is required to view your comments',
      'downloadList': 'Download List',
    },
  };

  String _text(String key) {
    final languageCode = _localizedValues.containsKey(locale.languageCode)
        ? locale.languageCode
        : 'zh';
    return _localizedValues[languageCode]?[key] ??
        _localizedValues['zh']![key] ??
        key;
  }

  String get navBrowse => _text('navBrowse');
  String get navLibrary => _text('navLibrary');
  String get initializing => _text('initializing');
  String get initFailedSetNetwork => _text('initFailedSetNetwork');
  String get authTitle => _text('authTitle');
  String get authPrompt => _text('authPrompt');
  String get login => _text('login');
  String get account => _text('account');
  String get password => _text('password');
  String get inputAccount => _text('inputAccount');
  String get inputPassword => _text('inputPassword');
  String get guestMode => _text('guestMode');
  String get guestModeSubtitle => _text('guestModeSubtitle');
  String get browse => _text('browse');
  String get pleaseLogin => _text('pleaseLogin');
  String get loggingIn => _text('loggingIn');
  String get profile => _text('profile');
  String get loginFailed => _text('loginFailed');
  String get confirm => _text('confirm');
  String get loginRegister => _text('loginRegister');
  String get viewError => _text('viewError');
  String get level => _text('level');
  String get experience => _text('experience');
  String get coin => _text('coin');
  String get badges => _text('badges');
  String get email => _text('email');
  String get nickname => _text('nickname');
  String get gender => _text('gender');
  String get male => _text('male');
  String get female => _text('female');
  String get signature => _text('signature');
  String get manualSign => _text('manualSign');
  String get signing => _text('signing');
  String get favorites => _text('favorites');
  String get viewHistory => _text('viewHistory');
  String get downloads => _text('downloads');
  String get comments => _text('comments');
  String get settings => _text('settings');
  String get sectionUserNetwork => _text('sectionUserNetwork');
  String get sectionReading => _text('sectionReading');
  String get sectionSync => _text('sectionSync');
  String get sectionSystemApp => _text('sectionSystemApp');
  String get clearAccount => _text('clearAccount');
  String get clearAccountConfirm => _text('clearAccountConfirm');
  String get exportIncomplete => _text('exportIncomplete');
  String get language => _text('language');
  String get followSystem => _text('followSystem');
  String get simplifiedChinese => _text('simplifiedChinese');
  String get english => _text('english');
  String get about => _text('about');
  String get currentVersion => _text('currentVersion');
  String get latestVersion => _text('latestVersion');
  String get noNewVersion => _text('noNewVersion');
  String get checkUpdate => _text('checkUpdate');
  String get goToDownloadPage => _text('goToDownloadPage');
  String get updateContent => _text('updateContent');
  String get updateContentUnavailable => _text('updateContentUnavailable');
  String get discussion => _text('discussion');
  String get allComments => _text('allComments');
  String get myComments => _text('myComments');
  String get goLogin => _text('goLogin');
  String get loading => _text('loading');
  String get delete => _text('delete');
  String get choose => _text('choose');
  String get yes => _text('yes');
  String get no => _text('no');
  String get pleaseSelectExportContent => _text('pleaseSelectExportContent');
  String get threadSuffix => _text('threadSuffix');
  String get all => _text('all');
  String get chooseFolder => _text('chooseFolder');
  String get chooseSort => _text('chooseSort');
  String get sortByFavoriteTime => _text('sortByFavoriteTime');
  String get sortByUpdateTime => _text('sortByUpdateTime');
  String get featureFavoritesFolder => _text('featureFavoritesFolder');
  String get clearAllHistory => _text('clearAllHistory');
  String get deleteViewHistory => _text('deleteViewHistory');
  String get weekMustSee => _text('weekMustSee');
  String get noContentAvailable => _text('noContentAvailable');
  String get nextIssue => _text('nextIssue');
  String get noMoreIssue => _text('noMoreIssue');
  String get switchedToNextIssue => _text('switchedToNextIssue');
  String get networkSettings => _text('networkSettings');
  String get tipLoginRequired => _text('tipLoginRequired');
  String get tipMyCommentsNeedLogin => _text('tipMyCommentsNeedLogin');
  String get downloadList => _text('downloadList');

  String currentVersionLabel(String version) => '$currentVersion : $version';

  String latestVersionLabel(String version) => '$latestVersion: $version';

  String deletingComic(String name) {
    if (locale.languageCode == 'en') {
      return 'Delete $name';
    }
    return '删除$name';
  }

  String tr(String zh, {String? en}) {
    if (locale.languageCode == 'en') {
      return en ?? zh;
    }
    return zh;
  }

  String boolLabel(bool value, {String? trueLabelEn, String? falseLabelEn}) {
    if (value) {
      return tr('是', en: trueLabelEn ?? yes);
    }
    return tr('否', en: falseLabelEn ?? no);
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
        (value) => value.languageCode == locale.languageCode,
      );

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsBuildContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
