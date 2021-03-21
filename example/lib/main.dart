import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:text_composition/text_composition.dart';

import 'first_chapter.dart';

main(List<String> args) {
  runApp(MaterialApp(home: Setting()));
}

class Setting extends StatefulWidget {
  Setting({Key? key}) : super(key: key);

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  var physicalSize = window.physicalSize,
      ratio = window.devicePixelRatio,
      size = TextEditingController(text: '16'),
      height = TextEditingController(text: '1.55'),
      paragraph = TextEditingController(text: '10'),
      shouldJustifyHeight = true,
      start = DateTime.now(),
      end = DateTime.now(),
      showMenu = true;
  Widget? content;
  TextComposition? textComposition;

  @override
  Widget build(BuildContext context) {
    physicalSize = window.physicalSize;
    ratio = window.devicePixelRatio;
    final _size = physicalSize / ratio;
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          if (content != null) content!,
          if (showMenu)
            InkWell(
              child: Container(
                child: Center(),
                color: Colors.transparent,
                width: double.infinity,
                height: double.infinity,
              ),
              onTap: () {
                setState(() {
                  showMenu = false;
                });
              },
            ),
          if (!showMenu)
            InkWell(
              child: Container(
                child: Center(child: Text("显示菜单", style: TextStyle(fontSize: 24),),),
                color: Colors.limeAccent.withOpacity(0.3),
                width: _size.width / 2,
                height: _size.height / 2,
              ),
              onTap: () {
                setState(() {
                  showMenu = true;
                });
              },
            ),
          if (showMenu)
            Card(
              child: Container(
                height: _size.height * 2 / 3,
                padding: EdgeInsets.all(10),
                child: ListView(
                  children: [
                    Text(
                        "physicalSize / ratio: $physicalSize / $ratio = ${physicalSize / ratio}"),
                    TextField(
                      decoration: InputDecoration(labelText: "字号 size"),
                      controller: size,
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: "行高 height"),
                      controller: height,
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: "段高 paragraph"),
                      controller: paragraph,
                      keyboardType: TextInputType.number,
                    ),
                    SwitchListTile(
                      title: Text("是否底栏对齐"),
                      subtitle: Text("shouldJustifyHeight"),
                      value: shouldJustifyHeight,
                      onChanged: (bool value) => setState(() {
                        shouldJustifyHeight = !shouldJustifyHeight;
                      }),
                    ),
                    Text("排版开始 $start"),
                    Text("排版结束 $end"),
                    OutlinedButton(
                      child: Text("开始或重新排版"),
                      onPressed: () {
                        final width = physicalSize.width / ratio;
                        start = DateTime.now();
                        textComposition = TextComposition(
                          paragraphs: first_chapter,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: double.tryParse(size.text),
                            height: double.tryParse(height.text),
                          ),
                          title: "烙印纹章 第一卷 一卷全",
                          titleStyle: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: double.tryParse(size.text),
                            height: 2,
                          ),
                          columnGap: 40,
                          columnCount: width > 1200
                              ? 3
                              : width > 600
                                  ? 2
                                  : 1,
                          paragraph: double.tryParse(paragraph.text) ?? 10.0,
                          padding: EdgeInsets.all(10),
                          shouldJustifyHeight: shouldJustifyHeight,
                          debug: true,
                          // buildFooter: ({TextPage? page, int? pageIndex}) {
                          //   return Text(
                          //     "烙印纹章 第一卷 一卷全 ${pageIndex == null ? '' : pageIndex + 1}/${textComposition!.pageCount}",
                          //     style: TextStyle(fontSize: 12),
                          //   );
                          // },
                          // footerHeight: 24,
                          // linkPattern: "<img",
                          // linkText: (s) =>
                          //     RegExp('(?<=src=".*)[^/\'"]+(?=[\'"])').stringMatch(s) ?? "链接",
                          // linkStyle: TextStyle(
                          //   color: Colors.cyan,
                          //   fontStyle: FontStyle.italic,
                          //   fontSize: double.tryParse(size.text),
                          //   height: double.tryParse(height.text),
                          // ),
                          // onLinkTap: (s) => Navigator.of(context).push(MaterialPageRoute(
                          //     builder: (BuildContext context) => Scaffold(
                          //           appBar: AppBar(),
                          //           body: Image.network(
                          //               RegExp('(?<=src=")[^\'"]+').stringMatch(s) ?? ""),
                          //         ))),
                        );
                        end = DateTime.now();
                        setState(() {});
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    OutlinedButton(
                      child: Text("手势翻页 修改版"),
                      onPressed: () async {
                        if (textComposition == null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('先排版才能预览'),
                          ));
                        } else {
                          setState(() {
                            content = PageTurn(
                              textComposition: textComposition!,
                            );
                          });
                        }
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    OutlinedButton(
                      child: Text("水平排列"),
                      onPressed: () async {
                        if (textComposition == null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('先排版才能预览'),
                          ));
                        } else {
                          setState(() {
                            content =
                                PageListView(textComposition: textComposition!);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
  }
}

class PageListView extends StatelessWidget {
  final TextComposition textComposition;
  const PageListView({required this.textComposition, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    final col = Column(
      children: List.generate(
        textComposition.boxSize.height ~/ 10,
        (index) => Container(
          height: 10,
          width: 20,
          color: index % 2 == 0 ? null : Colors.cyan,
          child: Text(
            index % 2 == 0 ? "" : (index * 10).toString(),
            textAlign: TextAlign.end,
            style: TextStyle(color: Colors.white, fontSize: 10, height: 1),
          ),
        ),
      ),
    );
    return Scaffold(
      body: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: textComposition.pageCount,
        separatorBuilder: (BuildContext context, int index) => col,
        itemBuilder: (BuildContext context, int index) {
          return textComposition.getPageWidget(index);
        },
      ),
    );
  }
}
