import 'dart:convert';
import 'dart:math';

import 'package:characters/src/extensions.dart';
import 'package:dinar/Functions/database_manager.dart';
import 'package:dinar/Functions/local_storage_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> compute_notifications() async {
  //initialize local notifications
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails('1', 'Currency Changes',
      channelDescription: 'sending Currency notifications on the your consent.',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker');
  const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
  //initialize local notifications
//get the notifications list
  var notifications = await LocalStorageManager().loadNotifications();
  final prefs = await SharedPreferences.getInstance();
  bool debug = prefs.getBool("debug") ?? false;
//clean up the list to only contain the enabled notifications.
  notifications = notifications.where((element) => element.enabled = true).toList();

//now compute the notifications
  for (var notification in notifications) {
//TODO
  }
}
