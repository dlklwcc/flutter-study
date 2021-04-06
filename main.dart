import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart'; //english_words: ^4.0.0

ValueNotifier<int> counter1 = ValueNotifier<int>(0);
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello Flutter',
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

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('你好，Flutter'),
        actions: [
          IconButton(
            icon: Icon(Icons.replay),
            onPressed: () {
              counter1.value += 1;
            },
          ),
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
        Text('不要看我'),
        _suggestionWordList(),
        _starWordList(),
      ],
    );
  }

  Widget _suggestionWordList() {
    _suggestions.addAll(generateWordPairs().take(1));
    return Expanded(
      //ListView放入column等容器会导致不显示容器，使用expanded包裹即可解决
      child: ListView.builder(
        //padding: const EdgeInsets.all(16.0),
        //itemCount: 10, //ListView条目数
        //shrinkWrap: true, //false时listview会充满，true为自动
        //physics: NeverScrollableScrollPhysics(), //控制listview是否能滚动
        itemBuilder: (context, i) {
          if (i.isOdd) return new Divider();
          final index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildWordRow(_suggestions[index]);
        },
      ),
    );
  }

  Widget _buildWordRow(WordPair pair) {
    final _alreadySaved = _star.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase, //Wordpair中的值
      ),
      trailing: Icon(
        _alreadySaved ? Icons.star : Icons.star_border,
        color: _alreadySaved ? Colors.yellow : null,
      ),
      onTap: () {
        setState(() {
          if (_alreadySaved) {
            _star.remove(pair);
          } else {
            _star.add(pair);
          }
        });
      },
    );
  }

  Widget _starWordList() {
    return ValueListenableBuilder(
      builder: (BuildContext context, int value, Widget child) {
        // 只有在更新计数器时才会调用此生成器。
        return Expanded(
          child: ListView.builder(
            itemCount: _star.length + 1,
            itemBuilder: (context, i) {
              return ListTile(
                title: Text((i == 0)
                    ? '已收藏${_star.length}个单词' //${表达式}
                    : _star[i - 1].asPascalCase),
              );
            },
          ),
        );
      },
      valueListenable: counter1, //监控的变量
    );
  }
}
