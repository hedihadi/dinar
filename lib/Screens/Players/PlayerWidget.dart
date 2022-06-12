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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

class PlayerWidget extends StatefulWidget {
  PlayerWidget({Key? key, required this.player}) : super(key: key);
  Player player;
  @override
  State<PlayerWidget> createState() => _MyServerState();
}

class _MyServerState extends State<PlayerWidget> {
  DateTime lastupdate = DateTime.now();
  bool animate = true;
  bool animate_completed = false;
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
    if (lastupdate != widget.player.lastupdate) {
      setState(() {
        animate = false;
        animate_completed = false;
      });
      Future.delayed(Duration(milliseconds: 250), () {
        animate = true;
        animate_completed = false;

        lastupdate = widget.player.lastupdate;
        if (this.mounted) {
          setState(() {});
        } else {
          lastupdate = DateTime.now();
        }
      });
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
      child: Container(
        decoration: BoxDecoration(
            color: ColorManager().background1,
            border: Border.all(
              color: ColorManager().background1,
            ),
            borderRadius: BorderRadius.all(Radius.circular(5.sp))),
        padding: EdgeInsets.all(2.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  flex: 5,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5.w, 0, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${widget.player.name}",
                          style: TextStyle(fontSize: 15.sp, fontFamily: "RobotoMono", fontWeight: FontWeight.w600, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        widget.player.online
                            ? Text(
                                "Playing since: ${timeago.format(widget.player.playing_since)}",
                                style: TextStyle(fontSize: 10.sp, fontFamily: "Roboto", fontWeight: FontWeight.w400, color: ColorManager().positive),
                              )
                            : Text(
                                "Offline since: ${timeago.format(widget.player.sessions.first.stop ?? DateTime.now())}",
                                style: TextStyle(fontSize: 10.sp, fontFamily: "Roboto", fontWeight: FontWeight.w400, color: ColorManager().negative),
                              ),
                      ],
                    ),
                  ),
                ),
                animate_completed
                    ? Flexible(
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
                    : Flexible(
                        child: Align(
                            alignment: Alignment.topRight,
                            child: AnimatedOpacity(
                              onEnd: () {
                                setState(() {
                                  animate_completed = true;
                                });
                              },
                              curve: Curves.linear,
                              opacity: animate == false ? 1.0 : 0.0,
                              duration: animate == false ? Duration(seconds: 0) : Duration(milliseconds: 500),
                              child: CircleAvatar(backgroundColor: ColorManager().positive),
                            )))
              ],
            ),
            SizedBox(height: 1.h),
            (widget.player.online && widget.player.sessions.length != 0)
                ? GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ServerInfo(
                                  server: widget.player.sessions.first.server,
                                )),
                      );
                    },
                    child: tag("${widget.player.sessions.first.server.name}", Icon(FontAwesomeIcons.server)))
                : Container(),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
