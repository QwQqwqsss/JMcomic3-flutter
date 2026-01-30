import 'package:flutter/material.dart';
import 'package:jasmine/basic/methods.dart';
import 'package:jasmine/configs/login.dart';
import 'package:jasmine/screens/components/comic_list.dart';

import 'components/comic_comments_list.dart';
import 'components/right_click_pop.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen>
    with SingleTickerProviderStateMixin {
  var _idx = 0;
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return rightClickPop(child: buildScreen(context), context: context);
  }

  Widget buildScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("讨论区"),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          onTap: (v) {
            setState(() {
              _idx = v;
            });
          },
          tabs: const [
            Tab(text: "全部评论"),
            Tab(text: "我的评论"),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: _idx == 0
                ? const ComicCommentsList(
                    mode: "manhua", aid: null, gotoComic: true)
                : const SelfCommentList(),
          ),
        ),
      ],
    );
  }
}

class SelfCommentList extends StatefulWidget {
  const SelfCommentList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SelfCommentListState();
}

class _SelfCommentListState extends State<SelfCommentList> {
  @override
  void initState() {
    loginEvent.subscribe(_setState);
    super.initState();
  }

  @override
  void dispose() {
    loginEvent.unsubscribe(_setState);
    super.dispose();
  }

  void _setState(_) {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loginStatus == LoginStatus.loginSuccess) {
      return ComicCommentsList(
        mode: "manhua",
        aid: null,
        gotoComic: true,
        uid: selfInfo.uid,
      );
    }
    return Center(
      child: Text(
        "请先登录",
        style: TextStyle(fontSize: 20, color: Colors.grey.shade600),
      ),
    );
  }
}
