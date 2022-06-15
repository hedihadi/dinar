import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinar/Functions/colors.dart';
import 'package:dinar/Functions/utils.dart';
import 'package:dinar/Providers/localization_provider.dart';

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

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsScreen> {
  bool collect_data = false;
  String language = "kurdish";
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        collect_data = prefs.getBool("collect_data") ?? true;
      });
    });
    language = context.read<LocalizationProvider>().language;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: calculateTextDirection(context),
      child: Scaffold(
        backgroundColor: HexColor("111111"),
        appBar: AppBar(
          title: Text(
            "Settings".localize(context),
            style: TextStyle(fontFamily: "RobotoMono", fontWeight: FontWeight.w600),
          ),
          backgroundColor: backgroundColor1,
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
                            text: "Collect Data".localize(context),
                            style: TextStyle(
                                fontFamily: "Roboto", fontWeight: FontWeight.w500, color: Colors.grey[200], fontSize: 13.sp, letterSpacing: 1.sp),
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            text:
                                'we keep track of your behavior in the Application, to identify errors or which section has audience, to improve the Application.'
                                    .localize(context),
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
                        thumbColor: MaterialStateProperty.all(Colors.white),
                        inactiveTrackColor: Colors.grey[900],
                        activeTrackColor: Colors.white,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: "Language".localize(context),
                          style: TextStyle(
                              fontFamily: "Roboto", fontWeight: FontWeight.w500, color: Colors.grey[200], fontSize: 13.sp, letterSpacing: 1.sp),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    decoration: BoxDecoration(color: HexColor("#191919"), borderRadius: BorderRadius.circular(10)),
                    child: DropdownButton<String>(
                      onChanged: (a) {
                        setState(() {
                          language = a!;
                        });
                        context.read<LocalizationProvider>().changeLanguage(language);
                      },
                      underline: SizedBox(),
                      value: language,
                      icon: Icon(Icons.arrow_drop_down),
                      items: context.read<LocalizationProvider>().available_languages.map((e) {
                        return DropdownMenuItem(
                          alignment: Alignment.center,
                          value: e,
                          child: Text(
                            e.localize(context),
                            style: TextStyle(color: HexColor("#999999"), fontSize: 14.sp),
                          ),
                        );
                      }).toList(),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
