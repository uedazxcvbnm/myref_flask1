/*クラス名
MyStatefulWidget　画面下部のバーを作るときに必要なクラス　画面を表示しているクラスではない
MyHomePage　食品の登録画面
*/
//StreamBuilderを使おうとしたけど、エラーが出たのでコメントしてます
import 'package:flutter/material.dart';
import './nextpage.dart';
import './provider.dart';
import './main3_4.dart';
import './recipe_recommend1.dart';
import './database_myref.dart';
import './database_material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:stream_transform/stream_transform.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:blobs/blobs.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './local_notification.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final GlobalKey<NavigatorState> navBarGlobalKey = GlobalKey<NavigatorState>();

LocalNotifications localNotifications = new LocalNotifications();

//BottomNavigationBar
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ProviderScope(child: MyApp()),
  );
  //これが抜けてた
  localNotifications.Initialization();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static const String _title = 'BottomNavBar Code Sample';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BottomNavBar Code Sample',
      home: MyStatefulWidget(),
      initialRoute: '/',
      routes: {
        //'/': (context) => MyHomePage(),
        '/page2': (context) => NextPage(),
      },
    );
  }
}

//画面上部のバー　食材を種類ごとに分類する画面に移動するボタン
class TabInfo {
  String label;
  Widget widget;
  TabInfo(this.label, this.widget);
}

//MyStatefulWidget　ボトムナビゲーションバーを作るときに必要なクラス（画面下部のバー）
class MyStatefulWidget extends StatefulWidget {
  //constが必要
  const MyStatefulWidget({Key? key}) : super(key: key);
  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

//画面下部のバー　画面移動するボタン
//画面下部のバー　画面移動するボタン
class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _selectedIndex = 0;
  var _childPageList = <Widget>[
    //食品の登録画面
    MyHomePage(),
    //食品を表示する画面
    NextPage(),
    //賞味期限が切れそうな食品で作った料理の紹介画面
    RecipePage(),
    //設定画面
    homePage4(),
  ];
  //画面移動するボタンの関数　画面下部のバー
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  //画面下部のバー　https://zenn.dev/urasan/articles/5bb85a54fb23fb
  //https://qiita.com/taki4227/items/e3c7e640b7986a80b2f9

  //https://qiita.com/canisterism/items/d648da85c300a3751db0 に変更
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DEMO'),
        backgroundColor: Colors.green,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _childPageList,
      ),
      backgroundColor: Colors.green,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        //画面を移動するボタン
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            //Flutter3なのでここではlabelを使うべき
            label: 'ラベル1',
            //バーの色はここで設定する
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ラベル2',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'ラベル3',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'ラベル4',
            backgroundColor: Colors.green,
          ),
        ],
        // 選択したときはオレンジ色にする
        //color: Colors.green,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.white,
        // タップできるように
        onTap: _onItemTapped,
      ),
    );
  }
}

//食品の登録画面（追加画面）MyHomePage　ボトムナビゲーションバーの１つ目のページ（食品を登録する画面）
class HomeWidget extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<HomeWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePage();
}

//https://flutter.keicode.com/basics/tabbarview.php
class _MyHomePage extends State<MyHomePage> {
//class _MyHomePage extends ConsumerWidget {
  //食品を種類ごとに分類して表示する画面に、移動するボタン
  /*final List<TabInfo> _tabs = [
    TabInfo("野菜・果物", Page1()),
    TabInfo("肉・魚", Page2()),
    //TabInfo("インスタント食品", Page3()),
    //TabInfo("頻繁に買う食品", Page4()),
  ];*/

  //複数のテーブルを同時に取得するために必要な関数を作るために定義したリスト
  List<Refri> _memoList = [];
  Stream<int> initializeDemo() async* {
    _memoList = await Refri.getMemos();
  }

  List<Material_db> _memolist2 = [];
  Stream<int> initializeDemo2() async* {
    _memolist2 = await Material_db.getMaterial();
  }

  //複数のテーブルを同時に取得するために必要な関数
  //https://qiita.com/ninoko1995/items/fe7115d8030a7a4cce0d
  Stream<Map<String, dynamic>> streamName() {
    return initializeDemo().combineLatestAll([initializeDemo2()]).map((data) {
      return {
        "initializeDemo()": data[0],
        "initializeDemo2()": data[1],
        "initializeDemo3()": data[2],
      };
    });
  }

  var _selectedvalue = null;

  //documentID
  var documentID = 0;

  // タイトルインプットテキストコントローラー
  TextEditingController titleTextEditingController = TextEditingController();
  // 内容インプットテキストコントローラー
  TextEditingController contentsTextEditingController = TextEditingController();
  // ローカル通知の初期化
  LocalNotifications localNotifications = new LocalNotifications();

  var _counter = 0;

  Widget build(BuildContext context) {
    return Scaffold(
      //length: _tabs.length,
      //title: 'Grid List',
      //child: Scaffold(
      appBar: AppBar(
        title: Text('賞味期限管理アプリ'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: StreamBuilder(
          stream: streamName(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // 非同期処理未完了 = 通信中
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            //食品の登録画面
            //https://flutter.ctrnost.com/layout/body/grid/
            return GridView.builder(
              //crossAxisCount: 2,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, //カラム数
              ),
              itemCount: _memolist2.length, //要素数
              itemBuilder: (context, index) {
                //return Container(
                return Card(
                  child: Column(
                    children: <Widget>[
                      //materialテーブルのid
                      Text('ID${_memolist2[index].id.toString()}'),
                      //materialテーブルのexday 保存期間の基準
                      //参考サイトhttps://foo-d.info/vegetables/
                      Text(
                        '${_memolist2[index].exday.toString()}日後',
                      ),
                      //refriテーブルのname
                      Text('${_memolist2[index].name}'),
                      //画像表示 materialテーブルのimage

                      //食品のカウントアップをするボタン　食品の個数を登録
                      GestureDetector(
                        child: InkWell(
                          //SpringButtonType.WithOpacity,
                          //タップエフェクト　色がピンクにならないけど、色は透明の方がいい
                          //https://www.choge-blog.com/programming/flutterinkwelltapeffectcolor/
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            //今日の日付
                            var now = DateTime.now();
                            var _now = DateFormat('yyyy-MM-dd').format(now);
                            DateTime past_sqlite = DateFormat('yyyy-MM-dd')
                                .parse(_memolist2[index].date.toString());
                            //stringからDateTimeに変換
                            var _nowDate = DateTime.parse(_now);
                            if (_nowDate != past_sqlite) {
                              _counter = 0;
                              var update_refri2 = Material_db(
                                id: _memolist2[index].id,
                                name: _memolist2[index].name,
                                kana: _memolist2[index].kana,
                                category: _memolist2[index].category,
                                exday: _memolist2[index].exday,
                                image: _memolist2[index].image,
                                count: _counter,
                                date: past_sqlite.toString(),
                              );

                              //データベースをアップデート
                              await Material_db.updateMaterial(update_refri2);
                              //}
                              //データの取得
                              final List<Material_db> memos2 =
                                  await Material_db.getMaterial();

                              super.setState(() {
                                _memolist2 = memos2;
                              });

                              if (_memolist2[index].count < 1) {
                                /*await FirebaseFirestore.instance
                                            .collection('refri')
                                            .doc('id_abc')
                                            .set({
                                          'id': 4,
                                          'date': '2022/10/7',
                                          'name': 'オクラ',
                                        });*/

                                //一時的なテスト 10日前
                                //https://qiita.com/seiboy/items/7b632103088c5ed65082
                                //_nowDate = _nowDate.add(Duration(days: 1) * -1);
                                //_nowDate =_nowDate.add(Duration(days: 1) * 1);
                                //_nowDate=_nowDate.add(Duration(days:2)*1);

                                //firebaseで使用する場合、var sql3の定義が悪かった
                                //var sql3 = material[index].id;
                                int sql4 = _memolist2[index].exday;

                                //賞味期限の計算　賞味期限＝今日の日付+materialテーブルのexdayカラム
                                var _time = _nowDate.add(Duration(days: sql4));
                                var _expireday =
                                    DateFormat('yyyy-MM-dd').format(_time);

                                final int expire_seconds =
                                    (_time.millisecondsSinceEpoch ~/ 1000);

                                //通知が来る日の設定：賞味期限が切れる日の一日前
                                var alert_time =
                                    _time.add(Duration(days: 1) * -1);

                                documentID++;

                                _counter = _counter + 1;
                                var update_refri2 = Material_db(
                                  id: _memolist2[index].id,
                                  name: _memolist2[index].name,
                                  kana: _memolist2[index].kana,
                                  category: _memolist2[index].category,
                                  exday: _memolist2[index].exday,
                                  image: _memolist2[index].image,
                                  count: _counter,
                                  date: _nowDate.toString(),
                                );

                                //データベースをアップデート
                                await Material_db.updateMaterial(update_refri2);
                                //}
                                //データの取得
                                final List<Material_db> memos2 =
                                    await Material_db.getMaterial();

                                super.setState(() {
                                  _memolist2 = memos2;
                                });
                                //通知：alert_timeは、食材の賞味期限が切れる一日前
                                bool isComppleted = await localNotifications
                                    .SetLocalNotification(
                                        titleTextEditingController.text,
                                        contentsTextEditingController.text,
                                        alert_time);

                                await FirebaseFirestore.instance
                                    .collection('refri')
                                    .doc(documentID.toString())
                                    .set({
                                  //'id': material[index].id.toString(),
                                  //'id': documentID,
                                  //'id': _counter,
                                  //'date': _time,
                                  'date': _expireday,
                                  'date_seconds': expire_seconds,
                                  //'name': material[index].name.toString(),
                                  'name': _memolist2[index].name,
                                });
                              }
                            }
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            child: Image.asset('${_memolist2[index].image}'),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      //),
    );
  }
}
