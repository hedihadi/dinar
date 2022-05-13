import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rustwipe/ServerInfo.dart';
import 'package:rustwipe/utils/ApiManager.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart' as intll;
import 'package:http/http.dart' as http;
import 'package:rustwipe/utils/colors.dart';
import 'package:rustwipe/utils/models.dart';
import 'package:rustwipe/utils/utils.dart';
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

class MyServer extends StatefulWidget {
  MyServer({Key? key, required this.server, required this.controller})
      : super(key: key);
  Server server;
  StreamController<Response> controller;
  @override
  State<MyServer> createState() => _MyServerState();
}

class _MyServerState extends State<MyServer> {
  late Server server;
  late StreamSubscription listen;
  bool animate = false;
  @override
  void dispose() {
    super.dispose();
    listen.cancel();
  }

  @override
  void initState() {
    server = widget.server;
    super.initState();
    listen = widget.controller.stream.listen((response) {
      if (response.server != null) {
        if (response.server!.id == server.id) {
          server = response.server!;
          animate = false;
          setState(() {});
          Future.delayed(Duration(milliseconds: 100), () {
            animate = true;
            setState(() {});
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.sp),
      child: Container(
        padding: EdgeInsets.all(10.sp),
        color: HexColor("#202020"),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  flex: 5,
                  child: Text(
                    "#${server.rank} ${server.name}",
                    style:
                        TextStyle(fontSize: 15.sp, color: Colors.orange[400]),
                    textAlign: TextAlign.center,
                  ),
                ),
                Flexible(
                    child: Align(
                        alignment: Alignment.topRight,
                        child: AnimatedOpacity(
                          opacity: animate == false ? 1.0 : 0.0,
                          duration: animate == false
                              ? Duration(seconds: 0)
                              : Duration(seconds: 1),
                          child: CircleAvatar(backgroundColor: Colors.green),
                        )))
              ],
            ),
            SizedBox(height: 1.h),
            Wrap(
              spacing: 1.w,
              runSpacing: 1.h,
              children: [
                tag(
                    server.type
                        .toString()
                        .replaceAll("ServerType.", "")
                        .capitalize(),
                    Colors.blueGrey[800]!),
                tag(
                    server.wipe_type
                        .toString()
                        .replaceAll("WipeType.", "")
                        .capitalize(),
                    Colors.brown[600]!),
                tag("Players: ${server.players}/${server.max_players} ${server.queued_players == 0 ? '' : ('(${server.queued_players} queued)')}",
                    Colors.cyan[900]!),
                tag("Last Wipe: ${timeago.format(server.last_wipe)}",
                    Colors.green[900]!),
                tag("Next Wipe: ${timeago.format(server.next_wipe, allowFromNow: true).replaceAll("from now", "")}",
                    Colors.purple[900]!),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ServerInfo(
                            server: server,
                          )),
                );
              },
              child: Text("Open"),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(HexColor("#264653"))),
            )
          ],
        ),
      ),
    );
  }
}
