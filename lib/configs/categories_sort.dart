import 'dart:convert';

import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:jasmine/screens/components/content_error.dart';

import '../basic/methods.dart';

List<int> _categoriesSort = [];

sortCategories(List<Categories> categories) {
  List<int> ids = [];
  for (var value in categories) {
    ids.add(value.id);
  }
  categories.sort((a, b) {
    var aIndex = _categoriesSort.indexOf(a.id);
    var bIndex = _categoriesSort.indexOf(b.id);
    if (aIndex == bIndex) {
      aIndex = ids.indexOf(a.id);
      bIndex = ids.indexOf(b.id);
    }
    if (aIndex == -1) {
      return 1;
    } else if (bIndex == -1) {
      return -1;
    } else {
      return aIndex - bIndex;
    }
  });
}

List<int> getCategoriesSort() {
  return _categoriesSort;
}

const _propertyName = "categoriesSort";

Future initCategoriesSort() async {
  var _sort = await methods.loadProperty(_propertyName);
  if (_sort == "") {
    _sort = "[]";
  }
  _categoriesSort = List<int>.from(jsonDecode(_sort));
}

get categoriesSort => _categoriesSort;
var categoriesSortEvent = Event();

Future<dynamic> saveCategoriesSort(List<int> categories) async {
  _categoriesSort = categories;
  await methods.saveProperty(_propertyName, jsonEncode(categories));
  categoriesSortEvent.broadcast();
}

Widget categoriesSortSetting(BuildContext context) {
  return ListTile(
    onTap: () {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) {
          return const CategoriesSortScreen();
        },
      ));
    },
    title: const Text(
      "首页分类排序",
    ),
  );
}

class CategoriesSortScreen extends StatefulWidget {
  const CategoriesSortScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CategoriesSortScreenState();
}

class _CategoriesSortScreenState extends State<CategoriesSortScreen> {
  Future<CategoriesResponse> _categoriesFuture = methods.categories();
  Key _key = UniqueKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        key: _key,
        future: _categoriesFuture,
        builder:
            (BuildContext context, AsyncSnapshot<CategoriesResponse> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(
                title: const Text("分类排序"),
              ),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(
                title: const Text("分类排序"),
              ),
              body: ContentError(
                error: snapshot.error,
                stackTrace: snapshot.stackTrace,
                onRefresh: () async {
                  setState(() {
                    _categoriesFuture = methods.categories();
                    _key = UniqueKey();
                  });
                },
              ),
            );
          }
          var categories = snapshot.requireData.categories;
          return CategoriesSortPanel(categories);
        });
  }
}

class CategoriesSortPanel extends StatefulWidget {
  final List<Categories> categories;

  const CategoriesSortPanel(this.categories, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CategoriesSortPanelState();
}

class _CategoriesSortPanelState extends State<CategoriesSortPanel> {
  final List<int> _categoriesSort = [];

  _switch(int value) {
    setState(() {
      if (_categoriesSort.contains(value)) {
        _categoriesSort.remove(value);
      } else {
        _categoriesSort.add(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //
    late double blockSize;
    late double imageSize;
    late double imageRs;
    var size = MediaQuery.of(context).size;
    var min = size.width < size.height ? size.width : size.height;
    blockSize = (min ~/ 3).floorToDouble();
    imageSize = blockSize - 15;
    imageRs = imageSize / 10;
    var sort = getCategoriesSort();
    List<int> ids = [];
    for (var value in widget.categories) {
      ids.add(value.id);
    }
    widget.categories.sort((a, b) {
      var aIndex = sort.indexOf(a.id);
      var bIndex = sort.indexOf(b.id);
      if (aIndex == bIndex) {
        aIndex = ids.indexOf(a.id);
        bIndex = ids.indexOf(b.id);
      }
      if (aIndex == -1) {
        return 1;
      } else if (bIndex == -1) {
        return -1;
      } else {
        return aIndex - bIndex;
      }
    });
    List<Widget> wrapItems = _wrapItems(blockSize, imageRs, imageSize);
    //
    return Scaffold(
      appBar: AppBar(
        title: const Text('分类排序'),
        actions: [
          _saveIcon(),
        ],
      ),
      body: ListView(
        children: [
          Container(height: 20),
          Wrap(
            runSpacing: 20,
            alignment: WrapAlignment.spaceAround,
            children: wrapItems,
          ),
          Container(height: 20),
        ],
      ),
    );
  }

  List<Widget> _wrapItems(
    double blockSize,
    double imageRs,
    double imageSize,
  ) {
    List<Widget> list = [];

    append(Widget widget, int id, String title, Function() onTap) {
      list.add(
        GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: blockSize,
            child: Column(
              children: [
                Stack(
                  children: [
                    Card(
                      elevation: .5,
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.all(Radius.circular(imageRs)),
                        child: Container(
                          color: Colors.black,
                          child: widget,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(imageRs)),
                      ),
                    ),
                    if (!_categoriesSort.contains(id))
                      Container(
                        width: imageSize,
                        height: imageSize,
                        color: Colors.black.withOpacity(.6),
                        margin: const EdgeInsets.all(4.0),
                      ),
                    if (_categoriesSort.contains(id))
                      Container(
                        width: imageSize,
                        height: imageSize,
                        color: Colors.black.withOpacity(.2),
                        margin: const EdgeInsets.all(4.0),
                      ),
                    if (_categoriesSort.contains(id))
                      Container(
                        color: Colors.black.withOpacity(.2),
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          "${_categoriesSort.indexOf(id) + 1}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                Container(height: 5),
                Center(
                  child: Text(title),
                ),
              ],
            ),
          ),
        ),
      );
    }

    for (var value in widget.categories) {
      var id = value.id;
      append(
        SizedBox(
          width: imageSize,
          height: imageSize,
          child: Center(
            child: Text(
              value.name.substring(0, 1),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
        ),
        value.id,
        value.name,
        () {
          setState(() {
            _switch(id);
          });
        },
      );
    }

    return list;
  }

  Widget _saveIcon() {
    return IconButton(
      onPressed: () async {
        await saveCategoriesSort(_categoriesSort);
        Navigator.of(context).pop();
      },
      icon: const Icon(Icons.save),
    );
  }
}
