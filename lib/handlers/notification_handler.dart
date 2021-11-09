import 'dart:async';
import 'package:digitalgeolocater/app_data.dart';
import 'package:digitalgeolocater/constants/notification_channel.dart';
import 'package:digitalgeolocater/constants/notification_topics.dart';
import 'package:digitalgeolocater/handlers/database_handler.dart';
import 'package:digitalgeolocater/models/user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHandler {
  static Future<dynamic> processMessage(Map<String, dynamic> message) async {
    try {
    //  String sectionID = message["section_id"] ?? '';
      if (message != null ){
        String title = message["title"] ?? '';
        String desc = message["body"] ?? '';
        int userNo = int.parse(message["userNo"] ?? '0');

        User user ;
        if (userNo != '') {
          user = await DBHandler().getUserByUserNo(userNo);
          if (user != null&& user.UserNo == userNo) {
            showNotification(
              int.parse("1"),
              title,
              desc,
            );
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  static void showNotification(
      int notificationID, String title, String message) {
    try {
      var android = new AndroidNotificationDetails(
            NotificationChannel.CHANNEL_ID,
            NotificationChannel.CHANNEL_NAME,
            NotificationChannel.CHANNEL_DESCRIPTION,
          );

      //9975688404
      var ios = new IOSNotificationDetails();

      NotificationDetails notificationDetails = NotificationDetails(android: android,iOS: ios);

      AppData.current.notificationPlugin.show(
            notificationID,
            title,
            message,
            notificationDetails,
          );
    } catch (e) {
      print(e);
    }
  }

  static void subscribeTopics(FirebaseMessaging firebaseMessaging) {
    firebaseMessaging.subscribeToTopic(NotificationTopics.EMPLOYEELEAVE);
    firebaseMessaging.subscribeToTopic(NotificationTopics.EMPLOYEELEAVEAPPROVAL);

  }
}
