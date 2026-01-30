import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jasmine/basic/commons.dart';
import 'package:jasmine/basic/methods.dart';
import 'package:jasmine/screens/components/floating_search_bar.dart';

import 'components/browser_bottom_sheet.dart';
import 'components/comic_list.dart';
import 'components/comic_pager.dart';
import 'components/right_click_pop.dart';
import 'components/types.dart';

class ViewLogScreen extends StatefulWidget {
  const ViewLogScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ViewLogScreenState();
}

class _ViewLogScreenState extends State<ViewLogScreen> {
  // random key
  var key = "HISTORY::" + Random().nextInt(100000).toString();

  @override
  Widget build(BuildContext context) {
    return rightClickPop(child: buildScreen(context), context: context);
  }

  Widget buildScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("浏览记录"),
        actions: [
          IconButton(
            onPressed: () async {
              String? choose = await chooseListDialog(
                context,
                values: ["是", "否"],
                title: "清除所有历史记录?",
              );
              if ("是" == choose) {
                await methods.clearViewLog();
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) {
                    return const ViewLogScreen();
                  },
                ));
              }
            },
            icon: const Icon(Icons.auto_delete),
          ),
          const BrowserBottomSheetAction(),
        ],
      ),
      body: ComicPager(
        key: Key(key),
        onPage: (int page) async {
          final response = await methods.pageViewLog(page);
          return InnerComicPage(
            total: response.total,
            list: response.content,
          );
        },
        longPressMenuItems: [
          ComicLongPressMenuItem(
            "删除浏览记录",
            (ComicBasic comic) async {
              defaultToast(context, "删除${comic.name}");
              await methods.deleteViewLogByComicId(comic.id);
              setState(() {
                key = "HISTORY::" + Random().nextInt(100000).toString();
              });
            },
          ),
        ],
      ),
    );
  }
}
