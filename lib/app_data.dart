import 'package:shared_preferences/shared_preferences.dart';
import 'models/user.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AppData {
  static AppData _current;
  static AppData get current {
    if (_current == null) {
      _current = AppData();
    }
    return _current;
  }
  FlutterLocalNotificationsPlugin _notificationPlugin;
  FlutterLocalNotificationsPlugin get notificationPlugin {
    if (_notificationPlugin == null) {
      var initializationSettingsAndroid =
      new AndroidInitializationSettings('@drawable/logo');

      var initializationSettingsIOS = new IOSInitializationSettings(
          onDidReceiveLocalNotification: (i, string1, string2, string3) async {
            print("received notifications");
          });

      var initializationSettings = new InitializationSettings(
         iOS: initializationSettingsIOS,android: initializationSettingsAndroid);

      _notificationPlugin = FlutterLocalNotificationsPlugin();
      _notificationPlugin.initialize(initializationSettings,
          onSelectNotification: (string) async {
            print("selected notification:" + string);
          });
    }

    return _notificationPlugin;
  }

  int client_No, Domain;
  String deviceId;
  User user;
  SharedPreferences preferences;



}
