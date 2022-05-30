import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:RustCompanion/Providers/AddNewNotificationProvider.dart';
import 'package:RustCompanion/Providers/PlayersProvider.dart';
import 'package:RustCompanion/Providers/RefreshPlayersProvider.dart';
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
import 'package:RustCompanion/Functions/ApiManager.dart';
import 'package:RustCompanion/Functions/BackgroundNotificationmanager.dart';
import 'package:RustCompanion/MainScreen.dart';
import 'package:RustCompanion/Providers/NotificationsProvider.dart';
import 'package:RustCompanion/Providers/RefreshServersProvider.dart';
import 'package:RustCompanion/Providers/ServersProvider.dart';
import 'package:RustCompanion/Screens/Notifications/AddNotification/AddNewNotification.dart';
import 'package:RustCompanion/Screens/Servers/AddNewServer.dart';
import 'package:RustCompanion/Screens/Servers/Servers.dart';
import 'package:RustCompanion/Screens/Notifications/Notifications.dart';
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
import 'package:provider/provider.dart';

Future<void> runBackgroundTask() async {
  await compute_notifications();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  ad.MobileAds.instance.initialize();
  ad.MobileAds.instance.updateRequestConfiguration(RequestConfiguration(testDeviceIds: ["E00E3C49D5ADD897C777922D286C66FD"]));
  await AndroidAlarmManager.initialize();
  await AndroidAlarmManager.periodic(const Duration(minutes: 1), 0, runBackgroundTask, rescheduleOnReboot: true, allowWhileIdle: true, exact: true);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ServersProvider()),
        ChangeNotifierProvider(create: (_) => RefreshServersProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
        ChangeNotifierProvider(create: (_) => PlayersProvider()),
        ChangeNotifierProvider(create: (_) => RefreshPlayersProvider()),
        ChangeNotifierProvider(create: (_) => AddNewNotificationProvider()),
      ],
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp(
            themeMode: ThemeMode.dark,
            darkTheme: ThemeData.dark().copyWith(
              iconTheme: IconThemeData(size: 15.sp, color: Colors.white),
              accentColor: ColorManager().accent,
              colorScheme: ThemeData.dark().colorScheme.copyWith(primary: Colors.amber, secondary: Colors.grey[300]),
              appBarTheme: AppBarTheme(color: Colors.grey[900]),
              scaffoldBackgroundColor: HexColor("#131313"),
              textTheme: TextTheme(
                bodyText1: TextStyle(),
                bodyText2: TextStyle(),
              ).apply(
                bodyColor: Colors.blue,
                displayColor: Colors.blue,
              ),
            ),
            debugShowCheckedModeBanner: false,
            home: MainScreen(),
          );
        },
      ),
    ),
  );
}
