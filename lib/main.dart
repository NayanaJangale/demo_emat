import 'package:digitalgeolocater/constants/notification_channel.dart';
import 'package:digitalgeolocater/handlers/database_handler.dart';
import 'package:digitalgeolocater/handlers/notification_handler.dart';
import 'package:digitalgeolocater/page/self_tracking_page.dart';
import 'package:digitalgeolocater/page/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  NotificationHandler.processMessage(message.data);
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  NotificationChannel.CHANNEL_ID,
  NotificationChannel.CHANNEL_NAME,
  NotificationChannel.CHANNEL_DESCRIPTION,
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =FlutterLocalNotificationsPlugin();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(DigitalGeologater());
  DBHandler _dbHandler = DBHandler();
  int status = 0 ;
  _dbHandler.getTrackingStatus().then((res) {
    if(res!= null){
      status = res.Status;
    }
    if (status==0){
    }else{
      Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: true,
      );
      Workmanager().registerPeriodicTask(
        "1",
        "New Location Detected.",
        initialDelay: Duration(seconds: 25),
      );

    }
  });

}
class DigitalGeologater extends StatefulWidget {
  @override
  _DigitalGeologaterState createState() => _DigitalGeologaterState();
}

class _DigitalGeologaterState extends State<DigitalGeologater> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.green[400],
      statusBarBrightness: Brightness.dark,
    ));
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.lightBlueAccent[200],),
      home: SplashPage(),
    );
  }
}
