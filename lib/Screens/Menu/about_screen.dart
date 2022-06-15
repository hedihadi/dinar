import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinar/Functions/utils.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:intl/intl.dart' as intll;
import 'package:http/http.dart' as http;

import 'package:path_provider/path_provider.dart';
import 'dart:io' as dartio;
import 'package:google_mobile_ads/google_mobile_ads.dart' as ad;
import 'package:function_tree/function_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor("#252525"),
      ),
      backgroundColor: HexColor("#191919"),
      body: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
            child: Container(
                child: ListView(
              children: [
                Image.asset("assets/images/ic_launcher.png", height: 15.h),
                Center(
                    child: Text(
                  "Dinar - دینار",
                  style: TextStyle(color: Colors.white, fontSize: 15.sp),
                )),
                Center(
                    child: Text(
                  "دینار - بۆ ئاسانکاری وەرگرتنی نرخی دراوەکان و هەژمارکردنیان",
                  style: TextStyle(color: Colors.grey[700], fontSize: 12.sp),
                  textAlign: TextAlign.center,
                )),
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
                              Icons.tag_faces_sharp,
                              color: Colors.grey[400],
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              "ئەپلیکەیشنەکەت بەدڵە؟",
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final InAppReview inAppReview = InAppReview.instance;
                                if (await inAppReview.isAvailable()) {
                                  inAppReview.requestReview();
                                } else {
                                  inAppReview.openStoreListing(appStoreId: 'com.hedihadi.dinar');
                                }
                              },
                              child: Column(
                                children: [
                                  Wrap(
                                    children: [
                                      Icon(Icons.star_outlined, color: Colors.amber),
                                      Icon(Icons.star_outlined, color: Colors.amber),
                                      Icon(Icons.star_outlined, color: Colors.amber),
                                      Icon(Icons.star_outlined, color: Colors.white),
                                      Icon(Icons.star_outlined, color: Colors.white),
                                    ],
                                  ),
                                  Text(
                                    "نمرە بدە لە Play Store",
                                    style: TextStyle(color: Colors.grey[400]),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 7.h,
                              width: 1.0,
                              color: Colors.white30,
                              margin: const EdgeInsets.only(left: 10.0, right: 10.0),
                            ),
                            GestureDetector(
                              onTap: () async {
                                await FlutterShare.share(
                                  title: 'Dinar - دینار',
                                  linkUrl: 'https://play.google.com/store/apps/details?id=com.hedihadi.dinar',
                                );
                              },
                              child: Column(
                                children: [
                                  Icon(Icons.share, color: Colors.white),
                                  Text("بڵاوی بکەوە", style: TextStyle(color: Colors.grey[400])),
                                ],
                              ),
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
                              "گەشەپێدەر",
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          ],
                        ),
                        Text(
                          "بۆ هەر کێشە و پێشنیارێک نامە بنێرە",
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
              ],
            )),
          )),
    );
  }
}
