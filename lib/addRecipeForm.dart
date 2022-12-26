import 'package:flutter/material.dart';
import './recipeApi.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class addRecipeForm extends StatefulWidget {
  const addRecipeForm({Key? key}) : super(key: key);

  @override
  State<addRecipeForm> createState() => _addRecipeFormState();
}

var now = DateTime.now();

int now_seconds = (now.millisecondsSinceEpoch ~/ 1000);

class _addRecipeFormState extends State<addRecipeForm> {
  bool _validateName = false;
  bool _validateContact = false;

  var food_list = <String>[];

  @override
  Widget build(BuildContext context) {
    int now_seconds = (now.millisecondsSinceEpoch ~/ 1000);
    return Scaffold(
      appBar: AppBar(
        title: Text('賞味期限管理アプリ'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
              icon: Icon(Icons.update),
              onPressed: () {
                setState(() {
                  var now = DateTime.now();
                  now_seconds = (now.millisecondsSinceEpoch ~/ 1000);
                });
              }),
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                for (int i = 0; i < food_list.length; i++) {
                  var result = RecipeApi().addFood(food_list[i]);
                  Navigator.pop(context, result);
                }
              }),
        ],
      ),
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
              stream: FirebaseFirestore.instance
                  .collection('refri')
                  .orderBy('date_seconds', descending: false)
                  .where("date_seconds", isGreaterThanOrEqualTo: now_seconds)
                  .snapshots(),
              //.startAtDocument(_now)
              //.startAt([Timestamp.fromDate(_now)])
              builder: (context, snapshot) {
                // データが取得できた場合
                if (snapshot.hasData) {
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  // 取得した投稿メッセージ一覧を元にリスト表示
                  return ListView(
                    children: documents.map((document) {
                      return Card(
                        child: ListTile(
                            title: Text(document['name'].toString()),
                            subtitle: Text(document['date'].toString()),
                            trailing: IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () async {
                                //リストに追加
                                food_list.add(document['name'].toString());
                                //food_list.removeLast();
                                food_list = food_list.toSet().toList();
                              },
                            )
                            //],
                            ),
                      );
                    }).toList(),
                  );
                }
                // データが読込中の場合
                return Center(
                  child: Text('読込中...'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
