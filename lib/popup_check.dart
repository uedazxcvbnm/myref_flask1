//popUpPage 登録画面で入力したものを最終確認する画面
// alertdialog https://www.kamo-it.org/blog/flutter-dialog/
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './main.dart';
import './page1.dart';
import './page2.dart';
import './nextpage.dart';
import './main3_4.dart';
import './provider.dart';
/*import './page3.dart';
import './page4.dart';*/
import './database_myref.dart';
import './database_material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:stream_transform/stream_transform.dart';
import './main.dart';
import 'package:blobs/blobs.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

//final BottomNavigationBar navigationBar = navBarGlobalKey.currentWidget;


// popUPPage 登録された食品の最終確認画面
class popUpPage extends StatefulWidget {
  const popUpPage({Key? key}) : super(key: key);
  //final String title;
  @override
  State<popUpPage> createState() => _popUpState();
}

class _popUpState extends State<popUpPage> {
  var _selectedValue = '機能１';
  var _usStates = ["機能１", "機能２", "機能３"];

  //メモリスト
  List<Refri> _memolist = [];
  Stream<int> initializeDemo() async* {
    _memolist = await Refri.getMemos();
  }

  List<Material_db> _memolist2 = [];
  Stream<int> initializeDemo2() async* {
    _memolist2 = await Material_db.getMaterial();
  }

  List<Refri> _memolist3 = [];
  Stream<int> initializeDemo3() async* {
    _memolist3 = await Refri.getMemos();
  }

  //複数のテーブルを同時に取得するために必要な関数
  //https://qiita.com/ninoko1995/items/fe7115d8030a7a4cce0d
  Stream<Map<String, dynamic>> streamName2() {
    return initializeDemo()
        .combineLatestAll([initializeDemo2(), initializeDemo3()]).map((data) {
      return {
        "initializeDemo": data[0],
        "initializeDemo2": data[1],
        "initializeDemo3()": data[2],
      };
    });
  }

  //id番号
  var _selectedvalue_id;

  //非同期関数定義
  int apple_counter = 0;
  var _now = DateFormat('yyyy-MM-dd').format(DateTime.now());

  //ポップアップ表示はできそうにない
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      /*appBar: AppBar(
        title: Text('賞味期限管理アプリ'),
        backgroundColor: Colors.green,
      ),*/
      //body: center(からbody: SizedBox( に変更したらうまくいった
      content: SizedBox(
        width: 200,
        child: StreamBuilder(
          stream: streamName2(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // 非同期処理未完了 = 通信中
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            //表示画面
            return ListView.builder(
              itemCount: _memolist.length,
              //itemCount: _memolist2.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Column(
                    children: <Widget>[
                      //refriテーブルのid
                      Text(
                        'ID${_memolist[index].id.toString()}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      //refriテーブルのdate
                      Text('${_memolist[index].date}'),
                      //refriテーブルのcount
                      Text('count  ${_memolist[index].count.toString()}'),
                      //refriテーブルのname
                      Text('name${_memolist[index].name}'),
                      //削除ボタン　これを押すとエラーになるので、後で変更する予定
                      SizedBox(
                        width: 76,
                        height: 25,
                        //RaisedButtonは古い　ElavatedButtonが推奨される
                        child: ElevatedButton(
                          child: Text('削除'),
                          onPressed: () async {
                            var _counter = _memolist[index].count - 1;
                            var update_refri3 = Refri(
                                id: _memolist[index].id,
                                count: _counter,
                                date: _memolist[index].date,
                                name: _memolist[index].name);
                            await Refri.updateMemo(update_refri3);
                            final List<Refri> memos = await Refri.getMemos();
                            setState(() {
                              _memolist = memos;
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 200,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: Text('いいえ'),
          onPressed: () {
            //前のページに戻る
            Navigator.pop(context);
          },
        ),
        //これをボタン化すれば解決する
        ElevatedButton(
          child: Text('はい'),
          onPressed: () {
            //1
            Navigator.pushNamed(context, '/page2');
            //Navigator.of(context, rootNavigator: true).pushNamed("/page2");
            //2
            /*Navigator.push(
                context,
                MaterialPageRoute(
                    // （2） 実際に表示するページ(ウィジェット)を指定する
                    builder: (context) => NextPage()));*/
            //3
            //Provider.of<NavBarProvider>(context).currentPage = 1;
            //4
            /*final BottomNavigationBar navigationBar = navBarGlobalKey.currentWidget;
              //initialIndex = 0;
              navigationBar.onTap(3);*/
            //MaterialPageRoute(builder: (context) => NextPage());
          },
        ),
      ],
    );
  }
}
