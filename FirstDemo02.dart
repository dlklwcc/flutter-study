import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart'; //english_words: ^4.0.0

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello Flutter',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: RandomWords(),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  createState() => RandomWordsState();
}

double textsize = 30;

class RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _star = <WordPair>[];
  ValueNotifier<int> counter1 = ValueNotifier<int>(0); //可以监控counter1的变化以刷新组件
  ValueNotifier<int> _starNumber = ValueNotifier<int>(0);
  final _actionRecord = <Map>[];
  int _wordCount = 5;
  TextEditingController _unameController = TextEditingController();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('你好，Flutter'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              counter1.value += 1;
            },
          ),
          IconButton(
            icon: Icon(Icons.history),
            onPressed: _pushNewScreen,
          )
        ],
        centerTitle: true,
      ),
      body: _buildTwoList(),
    );
  }

  Widget _buildTwoList() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _suggestionWordList(),
        _buildTextField(),
        _starWordList(),
      ],
    );
  }

  Widget _buildTextField() {
    return Expanded(
      child: Column(
        children: <Widget>[
          TextField(
            autofocus: true,
            controller: _unameController, //用于其他组件读取输入值，也可自建变量储存
            decoration: InputDecoration(
              labelText: "添加word数：", //已有输入时显示在上边
              hintText: "需要添加多少单词", //没有输入时显示
              //prefixIcon: Icon(Icons.note_add),//左边图像
            ),
          ),
          // ignore: deprecated_member_use
          RaisedButton(
            child: Text('添加'),
            onPressed: () {
              setState(() {
                _wordCount += int.parse(_unameController.text);
                //int->string:123.toString();
                //string->int:int.parse("123");
              });
            },
          ),
          ValueListenableBuilder(
            builder: (BuildContext context, int value, Widget child) {
              // 只有在更新计数器时才会调用此生成器。
              return //Center(
                  //widthFactor: 2, //宽度取决于子控件的宽度，为2时即宽度为子控件的两倍
                  Container(
                width: 180,
                child: Text(
                  '现已生成$_wordCount个单词!\n' +
                      '您已收藏${_star.length}个单词!\n' +
                      '收藏单词数点击右上角加号按钮刷新!!!\n' +
                      '我是计数器，点击右上角加号按钮计数~~\n' +
                      '你已点击${counter1.value}次！！！\n',
                  //使用'''abc'''格式导致除第一行外前面均有空格
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  //textWidthBasis: TextWidthBasis.longestLine,
                ),
              );
            },
            valueListenable: counter1,
          ),
        ],
      ),
    );
  }

  Widget _suggestionWordList() {
    _suggestions.addAll(generateWordPairs().take(1));
    return Expanded(
      //ListView放入column等容器会导致不显示容器，使用expanded包裹即可解决
      // child: ListView.builder(
      //   //padding: const EdgeInsets.all(16.0),
      //   //itemCount: 10, //ListView条目数
      //   //shrinkWrap: true, //false时listview会充满，true为自动
      //   //physics: NeverScrollableScrollPhysics(), //控制listview是否能滚动
      //   itemBuilder: (context, i) {
      //     if (i.isOdd) return new Divider();
      //     final index = i ~/ 2;
      //     if (index >= _suggestions.length) {
      //       _suggestions.addAll(generateWordPairs().take(10));
      //     }
      //     return _buildWordRow(_suggestions[index]);
      //   },
      // ),
      // 使用ListView.builder默认没有分隔线，需手动设置；
      // 使用ListView.separated中separatorBuilder设置分隔线，
      //     其实相当于设置两个itemBuilder；
      // 使用ListTile.divideTiles只可以设置固定像素的分隔线;
      // 后两种方法最后一行均不会出现分隔线

      child: ListView.separated(
        itemBuilder: (context, i) {
          if (i >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildWordRow(_suggestions[i]);
        },
        separatorBuilder: (context, i) {
          return Divider(
            height: 5,
          );
          //return Icon(Icons.arrow_right);
        },
        itemCount: _wordCount,
      ),
    );
  }

  Widget _buildWordRow(WordPair pair) {
    ValueNotifier<int> _alreadySaved =
        ValueNotifier<int>(_star.contains(pair) ? 1 : 0);
    return ValueListenableBuilder(
      builder: (BuildContext context, int value, Widget child) {
        return ListTile(
          title: Text(
            pair.asPascalCase, //Wordpair中的值
          ),
          trailing: Icon(
            (value == 1) ? Icons.star : Icons.star_border,
            color: (value == 1) ? Colors.yellow : null,
          ),
          onTap: () {
            //setState(() {
            if (value == 1) {
              _star.remove(pair);
              _alreadySaved.value--;
              _starNumber.value--;
              _actionRecord.add({'action': '移除', 'word': pair.asPascalCase});
            } else {
              _star.add(pair);
              _alreadySaved.value++;
              _starNumber.value++;
              _actionRecord.add({'action': '收藏', 'word': pair.asPascalCase});
            }
            //});
          },
        );
      },
      valueListenable: _alreadySaved,
    );
  }

  Widget _starWordList() {
    return ValueListenableBuilder(
      builder: (BuildContext context, int value, Widget child) {
        // 只有在更新计数器时才会调用此生成器。
        return Expanded(
          child: ListView.builder(
            itemCount: _star.length,
            itemBuilder: (context, i) {
              return ListTile(
                title: Text(//${表达式}
                    _star[i].asPascalCase),
              );
            },
          ),
        );
      },
      valueListenable: _starNumber, //监控的变量
    );
  }

  void _pushNewScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          final dividedList = ListTile.divideTiles(
            context: context,
            tiles: _actionRecord.map(
              (record) {
                return ListTile(
                  title: Text(
                    '${record['action']}:${record['word']}',
                    style: TextStyle(
                      fontSize: 20,
                      color:
                          (record['action'] == '收藏') ? Colors.red : Colors.blue,
                    ),
                  ),
                );
              },
            ),
          ).toList();

          return Scaffold(
            appBar: AppBar(
              title: Text('操作记录'),
              centerTitle: true,
            ),
            body: ListView(
              children: dividedList,
            ),
          );
        },
      ),
    );
  }
}
