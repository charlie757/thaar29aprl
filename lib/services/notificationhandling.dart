import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';

class NotificationHandling {
  var tokenID;

  handleMessaging(BuildContext context) async {
    tokenID = await FirebaseMessaging.instance.getToken();
    print(tokenID);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('onMsgggggggg: ' + message.data.toString());

      RemoteNotification? notification = message.notification;
      AndroidNotification? androidNotification = message.notification?.android;
      if (androidNotification != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification!.title,
            notification.body,
            NotificationDetails(
                android: AndroidNotificationDetails(channel.id, channel.name,
                    color: const Color.fromRGBO(71, 79, 156, 1),
                    playSound: true,
                    icon: '@mipmap/ic_launcher')));
      }
    });

    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        (await FirebaseMessaging.instance.getInitialMessage());

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      if (initialMessage.data['screen'] == 'Update App') {
        print('iniiiiitiallllll: ' + initialMessage.data.toString());
        // launch(
        //     'https://play.google.com/store/apps/details?id=techsk.solutions.mny_champ',
        //     forceSafariVC: false,
        //     forceWebView: false);
      }
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['screen'] == 'Update App') {
        print('onOpennnnnnnnn: ' + message.data.toString());
        // launch(
        //     'https://play.google.com/store/apps/details?id=techsk.solutions.mny_champ',
        //     forceSafariVC: false,
        //     forceWebView: false);
      }

      RemoteNotification notification = message.notification!;
      AndroidNotification? androidNotification = message.notification?.android;
      if (androidNotification != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title!),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(notification.body!)],
                  ),
                ),
              );
            });
      }
    });
  }

  savetoFirestore() async {
    tokenID = await FirebaseMessaging.instance.getToken();
    await FirebaseFirestore.instance
        .collection('barbers')
        .add({'token-id': tokenID});
  }
}
