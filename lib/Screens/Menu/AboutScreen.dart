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
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => _SettingsState();
}

class _SettingsState extends State<AboutScreen> {
  bool collect_data = false;
  bool debug = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          "About",
          style: TextStyle(fontFamily: "RobotoMono", fontWeight: FontWeight.w600),
        ),
        backgroundColor: ColorManager().background1,
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          Container(
            height: 15.h,
            decoration: BoxDecoration(
              color: ColorManager().accent,
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(11.w), bottomLeft: Radius.circular(11.w)),
            ),
            child: Column(
              children: [
                SizedBox(height: 1.h),
                Text(
                  "Rust Companion",
                  style: TextStyle(fontFamily: "RobotoMono", fontSize: 20.sp, fontWeight: FontWeight.w600, color: ColorManager().favorited),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Version: 1.0.0",
                  style: TextStyle(fontFamily: "RobotoMono", fontSize: 10.sp, fontWeight: FontWeight.w600, color: Colors.grey[50]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(15.sp),
            child: ListView(
              shrinkWrap: true,
              children: [
                RichText(
                  text: TextSpan(
                    text: "Developed By: ",
                    style: TextStyle(fontFamily: "RobotoMono", fontSize: 10.sp, fontWeight: FontWeight.w600, color: Colors.grey[500]),
                    children: [
                      TextSpan(
                          text: "Hedi Hadi",
                          style: TextStyle(fontFamily: "RobotoMono", fontSize: 10.sp, fontWeight: FontWeight.w600, color: ColorManager().favorited)),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: "Design By: ",
                    style: TextStyle(fontFamily: "RobotoMono", fontSize: 10.sp, fontWeight: FontWeight.w600, color: Colors.grey[500]),
                    children: [
                      TextSpan(
                          text: "Aufa Lana",
                          style: TextStyle(fontFamily: "RobotoMono", fontSize: 10.sp, fontWeight: FontWeight.w600, color: ColorManager().favorited)),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "Recommendations? Critics? I'd love to hear from you!",
                  style: TextStyle(fontFamily: "Roboto", fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                ElevatedButton(
                  onPressed: () async {
                    String email = "mailto:hedihadi45@gmail.com";
                    if (await canLaunch(email)) {
                      await launch(email);
                    }
                  },
                  child: Text("Send Email"),
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(ColorManager().accent)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
