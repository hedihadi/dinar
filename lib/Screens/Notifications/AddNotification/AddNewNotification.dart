import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:RustCompanion/Screens/Notifications/AddNotification/NotificationTypes/ServerWipes.dart';
import 'package:RustCompanion/Screens/Notifications/AddNotification/NotificationTypes/PlayerLeaveJoinServer.dart';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart' as intll;
import 'package:http/http.dart' as http;
import 'package:provider/src/provider.dart';
import 'package:RustCompanion/Functions/ApiManager.dart';
import 'package:RustCompanion/Providers/NotificationsProvider.dart';
import 'package:RustCompanion/Screens/Notifications/AddNotification/SelectServer.dart';

import 'package:RustCompanion/utils/ColorManager.dart';
import 'package:RustCompanion/utils/models.dart';
import 'package:RustCompanion/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as dartio;
import 'package:google_mobile_ads/google_mobile_ads.dart' as ad;
import 'package:function_tree/function_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AddNewNotification extends StatefulWidget {
  const AddNewNotification({Key? key}) : super(key: key);

  @override
  State<AddNewNotification> createState() => _AddNewNotificationState();
}

class _AddNewNotificationState extends State<AddNewNotification> {
  NotificationType selected_type = NotificationType.ServerWipes;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager().background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ColorManager().background1,
        centerTitle: true,
        title: Text(
          "Add New Notification",
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: ColorManager().minor),
        ),
      ),
      body: Container(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(child: Text("Notification Type:-", style: TextStyle(color: ColorManager().minor))),
                    SizedBox(width: 3.w),
                    Flexible(
                      child: DropdownButton<NotificationType>(
                        value: selected_type,
                        style: TextStyle(color: ColorManager().accent),
                        underline: Container(
                          height: 2,
                          color: ColorManager().accent,
                        ),
                        onChanged: (NotificationType? newValue) {
                          setState(() {
                            selected_type = newValue!;
                          });
                        },
                        items: NotificationType.values.map<DropdownMenuItem<NotificationType>>((NotificationType value) {
                          return DropdownMenuItem<NotificationType>(
                            value: value,
                            child: Text(
                              value.notificationTypeToString(),
                              style: TextStyle(color: ColorManager().accent),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                )),
            Builder(
              builder: (context) {
                switch (selected_type) {
                  case NotificationType.PlayerComesOnline:
                    break;
                  case NotificationType.PlayerGoesOffline:
                    // TODO: Handle this case.
                    break;
                  case NotificationType.ServerWipes:
                    return ServerWipes();
                  case NotificationType.PlayerJoinServer:
                    return PlayerLeaveJoinServer(player_leave_or_join: PlayerLeaveOrJoin.Join);
                  case NotificationType.PlayerLeaveServer:
                    return PlayerLeaveJoinServer(player_leave_or_join: PlayerLeaveOrJoin.Leave);
                }
                return Container();
              },
            )
          ],
        ),
      ),
    );
  }
}
