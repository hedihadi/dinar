import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:RustCompanion/Providers/PlayersProvider.dart';
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
import 'package:timeago/timeago.dart' as timeago;

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

class ServerInfo_PlayerWidget extends StatefulWidget {
  ServerInfo_PlayerWidget({Key? key, required this.player}) : super(key: key);
  Player player;
  @override
  State<ServerInfo_PlayerWidget> createState() => _MyServerState();
}

class _MyServerState extends State<ServerInfo_PlayerWidget> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(2.sp),
      child: Container(
        padding: EdgeInsets.all(5.sp),
        color: ColorManager().background1,
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
                    "${widget.player.name}",
                    style: TextStyle(fontSize: 15.sp, fontFamily: "RobotoMono", fontWeight: FontWeight.w600, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                Flexible(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                        onPressed: () async {
                          if (widget.player.favorited == false) {
                            context.read<PlayersProvider>().add_favorited_player(widget.player.id);
                            setState(() {
                              widget.player.favorited = true;
                            });
                          } else {
                            context.read<PlayersProvider>().remove_favorited_player(widget.player.id);
                            setState(() {
                              widget.player.favorited = false;
                            });
                          }
                        },
                        icon: widget.player.favorited == false
                            ? Icon(Icons.star_border, size: 25.sp, color: Colors.white)
                            : Icon(Icons.star, size: 25.sp, color: HexColor("#FFDE32")),
                        color: widget.player.favorited == false ? ColorManager().positive : ColorManager().negative),
                  ),
                )
              ],
            ),
            SizedBox(height: 1.h),
            (widget.player.online && widget.player.sessions.length != 0)
                ? ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ServerInfo(
                                  server: widget.player.sessions.first.server,
                                )),
                      );
                    },
                    child: Text(
                      "Open Server",
                      style: TextStyle(color: ColorManager().background1),
                    ),
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(ColorManager().accent)),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
