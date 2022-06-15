import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:dinar/Functions/colors.dart';
import 'package:dinar/Functions/compute_notifications.dart';
import 'package:dinar/Functions/data.dart';
import 'package:dinar/Functions/database_manager.dart';
import 'package:dinar/Functions/models.dart';
import 'package:dinar/Functions/utils.dart';
import 'package:dinar/Providers/localization_provider.dart';
import 'package:dinar/Screens/loading.dart';
import 'package:dinar/Screens/main_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart' as intll;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io' as dartio;
import 'package:google_mobile_ads/google_mobile_ads.dart' as ad;
import 'package:function_tree/function_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

Future<void> runBackgroundTask() async {
  await compute_notifications();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  ad.MobileAds.instance.initialize();
  // ad.MobileAds.instance.updateRequestConfiguration(RequestConfiguration(testDeviceIds: ["E00E3C49D5ADD897C777922D286C66FD"]));
  try {
    await AndroidAlarmManager.initialize();
    await AndroidAlarmManager.periodic(const Duration(minutes: 60), 0, runBackgroundTask,
        rescheduleOnReboot: true, allowWhileIdle: true, exact: true);
  } catch (c) {
    await FirebaseAnalytics.instance.logEvent(name: 'error_initialize_alarm', parameters: {"error": c});
  }

  ///initiate [LocalizationManager]
  GetIt.instance.registerSingleton<Data>(Data());

  runApp(Sizer(builder: (context, orientation, deviceType) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocalizationProvider()),
      ],
      child: MaterialApp(
        themeMode: ThemeMode.system,
        darkTheme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: HexColor("#111111"),
        ),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: "uniqaidar"),
        home: Loading(),
      ),
    );
  }));
}
