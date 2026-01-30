import 'package:flutter/material.dart';
import 'package:jasmine/basic/commons.dart';
import 'package:jasmine/screens/components/comic_pager.dart';
import 'package:jasmine/screens/components/content_builder.dart';

import '../basic/entities.dart';
import '../basic/methods.dart';

class WeekScreen extends StatefulWidget {
  const WeekScreen({super.key});

  @override
  State<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends State<WeekScreen> {
  late Future<WeekData> _weekData;
  late Key _key;

  @override
  void initState() {
    _weekData = methods.week(0);
    _key = UniqueKey();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("每周必看"),
      ),
      body: ContentBuilder<WeekData>(
          key: _key,
          future: _weekData,
          onRefresh: () async {
            _weekData = methods.week(0);
            _key = UniqueKey();
            setState(() {});
          },
          successBuilder: (context, data) {
            return WeekContent(data: data.requireData);
          }),
    );
  }
}

class WeekContent extends StatefulWidget {
  final WeekData data;
  const WeekContent({super.key, required this.data});

  @override
  State<WeekContent> createState() => _WeekContentState();
}

class _WeekContentState extends State<WeekContent>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late String _categoryId;
  late String _typeId;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: widget.data.types.length, vsync: this);
    _categoryId = widget.data.categories.first.id;
    _typeId = widget.data.types.reversed.first.id;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: DropdownButton<String>(
                underline: Container(),
                value: _categoryId,
                items: widget.data.categories
                    .map((e) => DropdownMenuItem(
                          value: e.id,
                          child: Text(e.time),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _categoryId = value ?? _categoryId;
                  });
                },
              ),
            ),
            Container(
              width: 30,
              color: Colors.red,
            ),
          ],
        ),
        TabBar(
          controller: _tabController,
          tabs: widget.data.types.reversed.map((e) => Text(e.title)).toList(),
          onTap: (index) {
            setState(() {
              _typeId = widget.data.types.reversed.toList()[index].id;
            });
          },
        ),
        Container(
          height: 15,
        ),
        Expanded(
          child: ComicPager(
            key: Key("WeekFilter_${_categoryId}_${_typeId}"),
            onPage: (int page) async {
              final response =
                  await methods.weekFilter(_categoryId, _typeId, page);
              return InnerComicPage(
                total: response.total,
                list: response.list,
              );
            },
            appendList: [
              _buildNextCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNextCard() {
    return GestureDetector(
      onTap: () {
        bool found = false;
        for (var category in widget.data.categories) {
          if (found) {
            setState(() {
              _categoryId = category.id;
            });
            break;
          }
          if (category.id == _categoryId) {
            _categoryId = category.id;
            found = true;
          }
        }
        defaultToast(context, "没有更多了");
      },
      child: Card(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: const Icon(Icons.next_plan_rounded),
            ),
            const Text('下一页'),
          ],
        ),
      ),
    );
  }
}
