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
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_tags/flutter_tags.dart';

class AddNewPlayer_Player extends StatefulWidget {
  AddNewPlayer_Player({Key? key, required this.player}) : super(key: key);
  Player player;
  @override
  State<AddNewPlayer_Player> createState() => _MyServerState();
}

class _MyServerState extends State<AddNewPlayer_Player> {
  late Player player;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    player = widget.player;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.sp),
      child: Container(
        padding: EdgeInsets.all(10.sp),
        color: ColorManager().background1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              player.name,
              style: TextStyle(fontSize: 15.sp, color: ColorManager().title),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 1.h),
            Text(
              "Sessions:-",
              style: TextStyle(fontSize: 13.sp, color: ColorManager().title1),
              textAlign: TextAlign.left,
            ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: player.sessions.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [Text(player.sessions[index].server.name)],
                );
              },
            ),
            ElevatedButton(
              onPressed: () {
                //Navigator.push(
                //  context,
                //  MaterialPageRoute(
                //      builder: (context) => ServerInfo(
                //            server: server,
                //          )),
                //);
              },
              child: Text("Open"),
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(HexColor("#264653"))),
            )
          ],
        ),
      ),
    );
  }
}
