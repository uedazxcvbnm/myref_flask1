//NextPage ボトムナビゲーションバーの２つ目のページ（冷蔵庫の中にある食材一覧の画面）
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:stream_transform/stream_transform.dart';
import 'package:blobs/blobs.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;

// NextPage ボトムナビゲーションバーの２つ目のページ（冷蔵庫の中にある食材一覧の画面）
class RecipePage extends StatefulWidget {
  const RecipePage({Key? key}) : super(key: key);
  //final String title;
  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  //非同期関数定義
  int apple_counter = 0;
  var _now = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          /*Container(
            padding: EdgeInsets.all(8),
            child: Text('ログイン情報：${user.email}'),
          ),*/
          Expanded(
            // FutureBuilder
            // 非同期処理の結果を元にWidgetを作れる
            child: StreamBuilder<QuerySnapshot>(
              // 投稿メッセージ一覧を取得（非同期処理）
              // 投稿日時でソート
              stream:
                  FirebaseFirestore.instance.collection('recipe').snapshots(),
              builder: (context, snapshot) {
                // データが取得できた場合
                //if (snapshot.hasData) {
                //final List<DocumentSnapshot> documents = snapshot.data!.docs;
                /*final recipes =
                    FirebaseFirestore.instance.collection('recipe').snapshots();*/
                // 取得した投稿メッセージ一覧を元にリスト表示
                final List<DocumentSnapshot> documents = snapshot.data!.docs;
                return GridView.count(
                  /*gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, //カラム数
                  ),*/
                  crossAxisCount: 2,
                  children: documents.map((document) {
                    //itemCount: recipes.length,
                    //itemBuilder: (context, index) {
                    //return Scaffold(
                    return Card(
                      //child: documents.map((document) {
                      child: GestureDetector(
                        child: InkWell(
                          //SpringButtonType.WithOpacity,
                          //タップエフェクト　色がピンクにならないけど、色は透明の方がいい
                          //https://www.choge-blog.com/programming/flutterinkwelltapeffectcolor/
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            var url = Uri.parse(document['URL']);
                            await launchUrl(url);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Image.network(document['image']),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      //}).toList(),
                    );
                    //);
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}











//NextPage ボトムナビゲーションバーの２つ目のページ（冷蔵庫の中にある食材一覧の画面）
/*import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:stream_transform/stream_transform.dart';
import 'package:blobs/blobs.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;

import './database_myref.dart';
import './database_myref2.dart';
import './database_material.dart';
import './expired.dart';

// NextPage ボトムナビゲーションバーの２つ目のページ（冷蔵庫の中にある食材一覧の画面）
class Recipe extends StatefulWidget {
  const Recipe({Key? key}) : super(key: key);
  //final String title;
  @override
  State<Recipe> createState() => _RecipePageState();
}

class _RecipePageState extends State<Recipe> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // デフォルト表示
            Text('Default'),
            Text('Default')
          ],
        ),
      ),
    );
  }
  /*var _selectedValue = '機能１';
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

  List<Refri2> _memolist3 = [];
  Stream<int> initializeDemo3() async* {
    _memolist3 = await Refri2.getMemos2();
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
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, //カラム数
                ),
                itemCount: _memolist2.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: GestureDetector(
                      child: InkWell(
                        //SpringButtonType.WithOpacity,
                        //タップエフェクト　色がピンクにならないけど、色は透明の方がいい
                        //https://www.choge-blog.com/programming/flutterinkwelltapeffectcolor/
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          var url = Uri.parse('${_memolist[index].date}');
                          await launchUrl(url);
                        },
                        child: Container(
                          width: 60,
                          height: 70,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network('${_memolist[index].date}'),
                            ],
                          ),
                        ),
                      ),
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
  }*/
}*/
