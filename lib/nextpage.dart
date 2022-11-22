//NextPage ボトムナビゲーションバーの２つ目のページ（冷蔵庫の中にある食材一覧の画面）
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './main.dart';
import './main3_4.dart';
import './expired.dart';
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

import 'package:flutter/cupertino.dart';

// NextPage ボトムナビゲーションバーの２つ目のページ（冷蔵庫の中にある食材一覧の画面）
class NextPage extends StatefulWidget {
  const NextPage({Key? key}) : super(key: key);
  //final String title;
  @override
  State<NextPage> createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
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

  /*List<Refri2> _memolist3 = [];
  Stream<int> initializeDemo3() async* {
    _memolist3 = await Refri2.getMemos2();
  }*/

  //複数のテーブルを同時に取得するために必要な関数
  //https://qiita.com/ninoko1995/items/fe7115d8030a7a4cce0d
  Stream<Map<String, dynamic>> streamName2() {
    return initializeDemo().combineLatestAll([initializeDemo2()]).map((data) {
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

  var _isAscending = true;
  var _currentSortColumn = 0;

  //引っ張って更新https://note.com/hatchoutschool/n/n67eb3d9106f1
  Future _loadData() async {
    //Future.delay()を使用して擬似的に非同期処理を表現
    await Future.delayed(Duration(seconds: 2));

    //print('Loaded New Data');

    setState(() {
      //新しいデータを挿入して表示
      _memolist;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('賞味期限管理アプリ'),
        backgroundColor: Colors.green,
        //automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.android),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: ((context) => Expired_food())));
            },
          ),
        ],
      ),
      body: SizedBox(
        //children:[
        //Expanded(
        //child: DataTable(
        child: RefreshIndicator(
          onRefresh: () async {
            //print('Loading New Data');
            await _loadData();
          },
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
                //itemCount: _memolist.length,
                itemCount: _memolist.length,
                //itemCount: _memolist2.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Column(
                      //children: <Widget>[
                      children: <Widget>[
                        //if () ...[
                        //ifの順番を入れ替えたら動いた　count!=0が135行目、賞味期限の判定は136行目
                        //count!=0は動く
                        //https://zenn.dev/taji/articles/d1d94b5efbed35
                        //if (_memolist[index].count != 0) ...[
                        if (DateTime.parse(_now).isBefore(
                            DateTime.parse(_memolist[index].date))) ...[
                          //refriテーブルのid
                          /*Text(
                              'ID${_memolist[index].id.toString()}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),*/
                          //refriテーブルのdate
                          Text('${_memolist[index].date}'),
                          //refriテーブルのcount
                          //Text('count  ${_memolist[index].count.toString()}'),
                          //refriテーブルのname
                          //ここだけ_memolist2（materialテーブル）を使う
                          Text('name${_memolist[index].name}'),
                          //削除ボタン　これを押すとエラーになるので、後で変更する予定
                          SizedBox(
                            width: 76,
                            height: 25,
                            //RaisedButtonは古い　ElavatedButtonが推奨される
                            child: ElevatedButton(
                              child: Text('削除'),
                              onPressed: () async {
                                await Refri.deleteMemo(_memolist[index].id);
                                final List<Refri> memos =
                                    await Refri.getMemos();
                                setState(() {
                                  _memolist = memos;
                                });
                              },
                            ),
                          ),
                        ],
                        //],
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        //),
        //],
      ),
    );
  }
}
