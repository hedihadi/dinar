import 'dart:convert';
import 'dart:math';

import 'package:characters/src/extensions.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:RustCompanion/Functions/LocalStorageManager.dart';
import 'package:RustCompanion/utils/models.dart';
import 'package:RustCompanion/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ApiManager.dart';

Future<void> compute_notifications() async {
  //initialize local notifications
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails('1', 'Server Wipe',
      channelDescription: 'Sending Wipe Notifications', importance: Importance.max, priority: Priority.high, ticker: 'ticker');
  const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
  //initialize local notifications
//get the notifications list
  var notifications = await LocalStorageManager().load_notifications();
  final prefs = await SharedPreferences.getInstance();
  bool debug = prefs.getBool("debug") ?? false;
//clean up the list to only contain the enabled notifications.
  notifications = notifications.where((element) => element.enabled = true).toList();

//now compute the notifications
  for (var notification in notifications) {
    if (notification.notification_type == NotificationType.ServerWipes) {
      //check if server has wiped
      //to do this, we basically compare the [notification.server_last_wipe] with the notification.server.last_wipe
      if (notification.server!.last_wipe.millisecondsSinceEpoch != notification.server_last_wipe!.millisecondsSinceEpoch) {
        ///server has wiped, let's notify user
//this clusterfuck below is responsible to trim the server name so it's not too long
        int max_characters = 30;
        String server_name =
            "${notification.server!.name.characters.length > max_characters ? '${notification.server!.name.characters.take(max_characters)}...' : '${notification.server!.name}'}";
        await flutterLocalNotificationsPlugin.show(notification.id!, 'Rust Companion', '"$server_name" just Wiped!', platformChannelSpecifics,
            payload: 'item x');

        ///server has wiped, let's notify user

//now update [notification.server_last_wipe] so we won't send the notification next time this function runs
        notification.server_last_wipe = notification.server!.last_wipe;
        notifications[notifications.indexWhere((element) => element.id == notification.id!)] = notification;
        LocalStorageManager().save_notifications(notifications);
      }
    }

    if (notification.notification_type == NotificationType.PlayerJoinServer) {
      //first we get new info on the player
      final new_player_info = await ApiManager().getPlayerInfo(notification.player!.id);
      //now check if the player is currently online
      if (new_player_info!.online = true) {
        //now check if they're playing in [notification.server]
        if (new_player_info.sessions.first.server.id == notification.server!.id) {
          //now check if we've already sent a notification for this session
          if (new_player_info.sessions.first.id != notification.session_id) {
            //send notification
            int max_characters = 99;
            String server_name =
                "${notification.server!.name.characters.length > max_characters ? '${notification.server!.name.characters.take(max_characters)}...' : '${notification.server!.name}'}";
            await flutterLocalNotificationsPlugin.show(
                notification.id!, 'Rust Companion', '"${notification.player!.name}" joined "$server_name"', platformChannelSpecifics,
                payload: 'item x');
            //now update the session id to prevent sending the same notification again
            notification.session_id = new_player_info.sessions.first.id;
            notifications[notifications.indexWhere((element) => element.id == notification.id!)] = notification;
            LocalStorageManager().save_notifications(notifications);
          } else {
            if (debug == true) {
              await flutterLocalNotificationsPlugin.show(
                  Random().nextInt(99999),
                  'Rust Companion',
                  'PlayerJoin: session id is different notif=${notification.session_id} player=${new_player_info.sessions.first.id}',
                  platformChannelSpecifics,
                  payload: 'item x');
            }
          }
        } else {
          if (debug == true) {
            await flutterLocalNotificationsPlugin.show(
                Random().nextInt(99999),
                'Rust Companion',
                'PlayerJoin: server id is different, notif=${notification.server!.id} player=${new_player_info.sessions.first.server.id}',
                platformChannelSpecifics,
                payload: 'item x');
          }
        }
      } else {
        if (debug == true) {
          await flutterLocalNotificationsPlugin
              .show(Random().nextInt(99999), 'Rust Companion', 'PlayerJoin: player not online', platformChannelSpecifics, payload: 'item x');
        }
      }
    }

    if (notification.notification_type == NotificationType.PlayerLeaveServer) {
      //first we get new info on the player
      final new_player_info = await ApiManager().getPlayerInfo(notification.player!.id);
      final session = new_player_info!.sessions.first;

      ///check if last played session was the [notification.server]
      if (notification.session_id != session.id) {
        if (session.server.id == notification.server!.id) {
          //if [session.stop] is not null, that means player has left the server
          if (session.stop != null) {
            //send notification
            //int max_characters = 99;
            //String server_name =
            //    "${notification.server!.name.characters.length > max_characters ? '${notification.server!.name.characters.take(max_characters)}...' : '${notification.server!.name}'}";
            await flutterLocalNotificationsPlugin.show(
                notification.id!, 'Rust Companion', '"${notification.player!.name}" Left "${notification.server!.name}"!', platformChannelSpecifics,
                payload: 'item x');
            notification.session_id = session.id;
            notifications[notifications.indexWhere((element) => element.id == notification.id!)] = notification;
            LocalStorageManager().save_notifications(notifications);
          } else {
            if (debug == true) {
              await flutterLocalNotificationsPlugin
                  .show(notification.id!, 'Rust Companion', 'PlayerLeave: player is still playing', platformChannelSpecifics, payload: 'item x');
            }
          }
        } else {
          if (debug == true) {
            await flutterLocalNotificationsPlugin.show(notification.id!, 'Rust Companion',
                'PlayerLeave: server id is different notif=${notification.server!.id} player=${session.server.id}', platformChannelSpecifics,
                payload: 'item x');
          }
        }
      } else {
        if (debug == true) {
          await flutterLocalNotificationsPlugin.show(notification.id!, 'Rust Companion',
              'PlayerLeave: session id is different notif=${notification.session_id} player=${session.id}', platformChannelSpecifics,
              payload: 'item x');
        }
      }
    }
  }
}
