import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart' as intll;
import 'package:http/http.dart' as http;
import 'package:provider/src/provider.dart';
import 'package:RustCompanion/Providers/ServersProvider.dart';
import 'package:RustCompanion/Screens/Servers/ServerInfo.dart';
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
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_tags/flutter_tags.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsScreen> {
  bool collect_data = false;
  bool debug = false;
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        collect_data = prefs.getBool("collect_data")!;
        debug = prefs.getBool("debug")!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager().background,
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(fontFamily: "RobotoMono", fontWeight: FontWeight.w600),
        ),
        backgroundColor: ColorManager().background1,
      ),
      body: Padding(
        padding: EdgeInsets.all(15.sp),
        child: ListView(
          shrinkWrap: true,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: "Collect Data",
                          style: TextStyle(
                              fontFamily: "Roboto", fontWeight: FontWeight.w500, color: Colors.grey[200], fontSize: 13.sp, letterSpacing: 1.sp),
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          text: 'we collect your behavior to improve the app, no information such as your Servers or Players will be tracked.',
                          style: TextStyle(
                              fontFamily: "Roboto", fontWeight: FontWeight.w500, color: Colors.grey[500], fontSize: 9.sp, letterSpacing: 1.sp),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Switch(
                      activeColor: Colors.white,
                      thumbColor: MaterialStateProperty.all(ColorManager().accent),
                      inactiveTrackColor: Colors.grey[900],
                      activeTrackColor: ColorManager().accent,
                      value: collect_data,
                      onChanged: (val) async {
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setBool("collect_data", val);
                        setState(() {
                          collect_data = val;
                        });
                      }),
                )
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: "Debug Mode",
                          style: TextStyle(
                              fontFamily: "Roboto", fontWeight: FontWeight.w500, color: Colors.grey[200], fontSize: 13.sp, letterSpacing: 1.sp),
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          text:
                              'This App is still in Alpha Mode, Enable this to get detailed information on what the application is doing. WARNING: you will receive intense amount of messages and notifications',
                          style: TextStyle(
                              fontFamily: "Roboto", fontWeight: FontWeight.w500, color: Colors.grey[500], fontSize: 9.sp, letterSpacing: 1.sp),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Switch(
                      activeColor: Colors.white,
                      thumbColor: MaterialStateProperty.all(ColorManager().accent),
                      inactiveTrackColor: Colors.grey[900],
                      activeTrackColor: ColorManager().accent,
                      value: debug,
                      onChanged: (val) async {
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setBool("debug", val);
                        setState(() {
                          debug = val;
                        });
                      }),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
