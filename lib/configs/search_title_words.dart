/// 自动全屏

import 'dart:io';

import 'package:flutter/material.dart';

import '../basic/commons.dart';
import '../basic/methods.dart';

const _propertyName = "searchTitleWords";
late bool _searchTitleWords;

Future<void> initSearchTitleWords() async {
  var str = await methods.loadProperty(_propertyName);
  if (str == "") {
    str = "false";
  }
  _searchTitleWords = str == "true";
}

bool currentSearchTitleWords() {
  return _searchTitleWords;
}

Future<void> _chooseSearchTitleWords(BuildContext context) async {
  String? result = await chooseListDialog<String>(context,
      title: "标题中的关键字点击搜索", values: ["是", "否"]);
  if (result != null) {
    var target = result == "是";
    await methods.saveProperty(_propertyName, "$target");
    _searchTitleWords = target;
  }
}

Widget searchTitleWordsSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: const Text("标题中的关键字点击搜索"),
        subtitle: Text(_searchTitleWords ? "是" : "否"),
        onTap: () async {
          await _chooseSearchTitleWords(context);
          setState(() {});
        },
      );
    },
  );
}
