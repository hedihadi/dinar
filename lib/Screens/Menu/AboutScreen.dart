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
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => _SettingsState();
}

class _SettingsState extends State<AboutScreen> {
  bool collect_data = false;
  bool debug = false;
  String version = "";
  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((value) {
      setState(() {
        version = "Version: ${value.version}";
      });
    });
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
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
        child: Container(
            child: ListView(
          children: [
            Image.asset("assets/images/ic_launcher.png", height: 15.h),
            Center(
                child: Text(
              "Rust Companion",
              style: TextStyle(color: ColorManager().title, fontSize: 20.sp, fontFamily: "BebasNeue"),
            )),
            Center(
                child: Text(
              version,
              style: TextStyle(color: Colors.grey[700], fontSize: 10.sp, fontFamily: "Roboto"),
              textAlign: TextAlign.center,
            )),
            Center(
                child: Text(
              "Track Players and Servers on your Phone!",
              style: TextStyle(color: Colors.grey[400], fontSize: 12.sp, fontFamily: "Roboto"),
              textAlign: TextAlign.center,
            )),
            SizedBox(height: 2.h),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5.sp)),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: Padding(
                padding: EdgeInsets.all(10.sp),
                child: ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    Wrap(
                      children: [
                        Icon(
                          Icons.tag_faces_sharp,
                          color: Colors.grey[400],
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          "like this app?",
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Wrap(
                              children: [
                                Icon(Icons.star_outlined, color: Colors.amber),
                                Icon(Icons.star_outlined, color: Colors.amber),
                                Icon(Icons.star_outlined, color: Colors.amber),
                                Icon(Icons.star_outlined, color: Colors.amber),
                                Icon(Icons.star_outlined, color: Colors.white),
                              ],
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              "Rate on Play Store",
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          ],
                        ),
                        Container(
                          color: Colors.grey[600],
                          height: 5.h,
                          width: 0.2.w,
                          margin: EdgeInsets.only(left: 5.w, right: 5.w),
                        ),
                        Column(
                          children: [
                            Icon(Icons.share, color: Colors.white),
                            SizedBox(height: 0.5.h),
                            Text("Share with Friends", style: TextStyle(color: Colors.grey[400])),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5.sp)),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: Padding(
                padding: EdgeInsets.all(5.sp),
                child: ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    Wrap(
                      children: [
                        Icon(
                          Icons.design_services_outlined,
                          color: Colors.grey[400],
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          "Developer",
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                    Text(
                      "Developed by: Hedi Hadi",
                      style: TextStyle(color: Colors.grey[700], fontSize: 9.sp),
                    ),
                    SizedBox(height: 1.h),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey[800],
                          child: IconButton(
                              onPressed: () async {
                                await launch("https://hedi.cf");
                              },
                              icon: Icon(
                                Icons.web,
                                color: Colors.grey[400],
                              )),
                        ),
                        SizedBox(width: 2.w),
                        CircleAvatar(
                          backgroundColor: Colors.grey[800],
                          child: IconButton(
                              onPressed: () async {
                                await launch("https://www.facebook.com/hediapo/");
                              },
                              icon: Icon(
                                Icons.facebook_sharp,
                                color: Colors.grey[400],
                              )),
                        ),
                        SizedBox(width: 2.w),
                        CircleAvatar(
                          backgroundColor: Colors.grey[800],
                          child: IconButton(
                              onPressed: () async {
                                await launch("mailto:hedihadi45@gmail.com");
                              },
                              icon: Icon(
                                Icons.email_outlined,
                                color: Colors.grey[400],
                              )),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5.sp)),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: Padding(
                padding: EdgeInsets.all(5.sp),
                child: ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    Wrap(
                      children: [
                        Icon(
                          Icons.design_services_outlined,
                          color: Colors.grey[400],
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          "UI Design",
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                    Text(
                      "UI Designed by: Aufa Lana",
                      style: TextStyle(color: Colors.grey[700], fontSize: 9.sp),
                    ),
                    SizedBox(height: 1.h),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey[800],
                          child: IconButton(
                              onPressed: () async {
                                await launch("https://www.instagram.com/auffa_lana/");
                              },
                              icon: Icon(
                                Icons.web,
                                color: Colors.grey[400],
                              )),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
