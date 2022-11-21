import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// ローカル通知管理
class LocalNotifications {
  // ローカル通知管理
  static FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin =
      null;

  /// 初期化
  Future<void> Initialization(
      {String iconImage = '@mipmap/ic_launcher'}) async {
    // 初期化していたら処理しないようにする
    if (flutterLocalNotificationsPlugin != null) {
      return;
    }

    // タイムゾーン設定
    await initTimeZone();
    // ローカル通知の初期化
    // Android
    AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings(iconImage);
    // iOS
    /*IOSInitializationSettings iOSInitializationSettings =
        IOSInitializationSettings(
      // バックグラウンドや終了時にローカル通知のバナーをクリックした際に動く処理
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );*/
    // 端末ごとの通知設定を登録する
    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      //iOS: iOSInitializationSettings,
    );
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin!.initialize(
      initializationSettings,
      //onSelectNotification: onSelectNotification,
    );

    return;
  }

  /// タイムゾーンを設定する
  Future<void> initTimeZone() async {
    tz.initializeTimeZones();
    var tokyo = tz.getLocation('Asia/Tokyo');
    tz.setLocalLocation(tokyo);
  }

  /// 通知バナーをクリックした際に呼ばれる
  Future<void> onSelectNotification(String? payload) async {}

  /// アプリがバックグラウンドや終了時に通知バナーがタップされたときに呼ばれる
  Future<void> onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {}

  /// 通知を設定する
  Future<bool> SetLocalNotification(String title, String body, DateTime dayTime,
      {String channelID = "TextEditorLocalNotification",
      String ChannelName = "TextEditor_SpecifiedNotification",
      String icon = "@mipmap/ic_launcher"}) async {
    // 初期化してなかったら処理しないようにする
    if (flutterLocalNotificationsPlugin == null) {
      return false;
    }

    try {
      // 通知の時刻設定
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        dayTime.year,
        dayTime.month,
        dayTime.day,
        dayTime.hour,
        dayTime.minute,
      );

      // 通知の詳細な設定
      NotificationDetails notificationDetails = NotificationDetails(
        // Android側
        android: AndroidNotificationDetails(
          channelID, // 通知のID
          ChannelName, // 通知のチャンネル名（例：定期通知、不特定通知を分けるなど
          channelDescription: 'memo_notification_des', // 通知の詳細
          icon: icon,
        ),
        // iOS側
        //iOS: IOSNotificationDetails(),
      );

      await flutterLocalNotificationsPlugin!.zonedSchedule(
          1, //　IDは通知ごとに同じIDを使う
          title, // タイトル
          body, // 内容
          scheduledDate,
          notificationDetails,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
    } catch (e) {
      // なにかのエラーで失敗した
      print(e.toString());
      return false;
    }

    // 通知に成功した
    return true;
  }
}
