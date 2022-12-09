//参考にしたサイト
//https://qiita.com/takois/items/6cf59811d3af5b1d33aa
//https://dev-yakuza.posstree.com/flutter/widget/sqflite/#%E6%97%A2%E5%AD%98db%E3%82%92%E4%BD%BF%E3%81%86%E5%A0%B4%E5%90%88

//わかりやすい説明https://417.run/pg/flutter-dart/flutter-sqlite-import/
import 'dart:io' as io;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:blobs/blobs.dart';

//assetカラムからデータベースを取得する
Future<Database> get database async {
  var databasesPath = await getDatabasesPath();
  //var path = join(databasesPath, 'assets/myref3.db');
  var path = join(databasesPath, 'assets/myref.db');
  // データベースが存在するかどうかを確認する
  var exists = await databaseExists(path);
  if (!exists) {
    // 親ディレクトリが存在することを確認する
    try {
      await io.Directory(dirname(path)).create(recursive: true);
    } catch (_) {}
    // アセットからコピー
    //var data = await rootBundle.load(join('assets', 'myref3.db'));
    var data = await rootBundle.load(join('assets', 'myref.db'));
    List<int> bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    // 書き込まれたバイトを書き込み、フラッシュする
    await io.File(path).writeAsBytes(bytes, flush: true);
  }
  //DBファイルを開く
  return await openDatabase(path);
}

//クラス
class Refri {
  final int id;
  final int count;
  final String date;
  final String name;

  Refri({
    required this.id,
    required this.count,
    required this.date,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'count': count,
      'date': date,
      'name': name,
    };
  }

  @override
  String toString() {
    //return 'refri{id: $id, count:$count,date:$date,name$name}';
    return 'refri{id: $id,count: $count,date:$date,name$name}';
  }

  //挿入
  static Future<void> insertMemo(Refri refri) async {
    final Database db = await database;
    await db.insert(
      'refri',
      refri.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //取得
  static Future<List<Refri>> getMemos() async {
    /*var _now = DateTime.now();
    DateFormat outputFormat = DateFormat('yyyy-MM-dd-Hm');
    String nowDate = outputFormat.format(_now);*/
    final Database db = await database;
    //const String sql1 = 'SELECT * FROM refri GROUP BY nowDate';
    List<Map<String, dynamic>> map2 = await db.query('refri');
    //List<Map<String, dynamic>> map2 = List<Map<String, dynamic>>.from(maps);
    //maps.sort((a,b)=>DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
    //日付が古い順に並べる
    return List.generate(map2.length, (i) {
      return Refri(
        id: map2[i]['id'],
        count: map2[i]['count'],
        date: map2[i]['date'],
        name: map2[i]['name'],
      );
    });
  }

  //更新
  static Future<void> updateMemo(Refri refri) async {
    // Get a reference to the database.
    final db = await database;
    await db.update(
      'refri',
      refri.toMap(),
      where: "id = ?",
      whereArgs: [refri.id],
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  //削除
  static Future<void> deleteMemo(int id) async {
    final db = await database;
    await db.delete(
      'refri',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  //日付順を取得
  static Future<List<Refri>> getMemosDates() async {
    /*var _now = DateTime.now();
    DateFormat outputFormat = DateFormat('yyyy-MM-dd-Hm');
    String nowDate = outputFormat.format(_now);*/
    final Database db = await database;
    //const String sql1 = 'SELECT * FROM refri GROUP BY nowDate';
    List<Map<String, dynamic>> maps = await db.query('refri');
    List<Map<String, dynamic>> map2 = List<Map<String, dynamic>>.from(maps);
    //maps.sort((a,b)=>DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
    //日付が古い順に並べる
    map2.sort((a, b) =>
        DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));
    return List.generate(map2.length, (i) {
      return Refri(
        id: map2[i]['id'],
        count: map2[i]['count'],
        date: map2[i]['date'],
        name: map2[i]['name'],
      );
    });
  }
}
