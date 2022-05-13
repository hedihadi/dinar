import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:url_launcher/url_launcher.dart';

class ServerInfo extends StatefulWidget {
  ServerInfo({Key? key, required this.server}) : super(key: key);
  Server server;

  @override
  State<ServerInfo> createState() => _ServerInfoState();
}

class _ServerInfoState extends State<ServerInfo> {
  ScrollController scroll_controller = ScrollController(initialScrollOffset: 0);
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      final List<int> items = List<int>.from(
          jsonDecode(prefs.getString("favorited_servers") ?? "[]"));
      if (items.contains(widget.server.id)) {
        setState(() {
          widget.server.favorited = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#101010"),
      appBar: AppBar(
          elevation: 0,
          backgroundColor: HexColor("#202020"),
          centerTitle: true,
          title: Text(widget.server.name, overflow: TextOverflow.ellipsis)),
      body: Stack(
        children: [
          ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue, Colors.transparent],
                ).createShader(
                    Rect.fromLTRB(0, 0, rect.width * 0.2, rect.height * 0.9));
              },
              blendMode: BlendMode.dstATop,
              child: CachedNetworkImage(
                imageUrl: widget.server.header_image,
              )),
          Padding(
            padding: EdgeInsets.fromLTRB(2.w, 0, 2.w, 0),
            child: ListView(
              children: [
                SizedBox(
                  height: 20.h,
                ),
                Row(children: [
                  Flexible(
                    flex: 5,
                    child: Text(widget.server.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          letterSpacing: 2,
                        )),
                  ),
                  Flexible(
                      child: IconButton(
                          onPressed: () async {
                            var prefs = await SharedPreferences.getInstance();
                            final List<int> items = List<int>.from(jsonDecode(
                                prefs.getString("favorited_servers") ?? "[]"));
                            if (widget.server.favorited == false) {
                              items.add(widget.server.id);
                            } else {
                              items.remove(widget.server.id);
                            }
                            prefs.setString(
                                "favorited_servers", jsonEncode(items));
                            prefs = await SharedPreferences.getInstance();
                            print(prefs.getString("favorited_servers"));
                            setState(() {
                              widget.server.favorited =
                                  !widget.server.favorited;
                            });
                          },
                          icon: widget.server.favorited == false
                              ? Icon(Icons.bookmark_add)
                              : Icon(Icons.bookmark_remove),
                          color: widget.server.favorited == false
                              ? Colors.green[400]
                              : Colors.red[300])),
                ]),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Checkbox(
                        fillColor: MaterialStateProperty.all(Colors.red[300]),
                        value: widget.server.warn_when_wipe,
                        onChanged: (val) async {
                          final prefs = await SharedPreferences.getInstance();
                          final List<int> items = List<int>.from(jsonDecode(
                              prefs.getString("warn_when_wipe_servers") ??
                                  "[]"));
                          if (val == false) {
                            if (items.contains(widget.server.id)) {
                              items.remove(widget.server.id);
                            }
                          } else {
                            if (!items.contains(widget.server.id)) {
                              items.add(widget.server.id);
                            }
                          }
                          prefs.setString(
                              "warn_when_wipe_servers", jsonEncode(items));

                          setState(() {
                            widget.server.warn_when_wipe =
                                !widget.server.warn_when_wipe;
                          });
                        }),
                    Text(
                      "Warn me When Server Wipes",
                      style: TextStyle(color: Colors.red[300]),
                    ),
                  ],
                ),
                SizedBox(
                  height: 2.h,
                ),
                Wrap(
                  spacing: 1.w,
                  runSpacing: 1.h,
                  children: [
                    tag(
                        widget.server.type
                            .toString()
                            .replaceAll("ServerType.", "")
                            .capitalize(),
                        Colors.blueGrey[800]!),
                    tag(
                        widget.server.wipe_type
                            .toString()
                            .replaceAll("WipeType.", "")
                            .capitalize(),
                        Colors.brown[600]!),
                    tag("Players: ${widget.server.players}/${widget.server.max_players} ${widget.server.queued_players == 0 ? '' : ('(${widget.server.queued_players} queued)')}",
                        Colors.cyan[900]!),
                    tag("Last Wipe: ${timeago.format(widget.server.last_wipe)}",
                        Colors.green[900]!),
                    tag("Next Wipe: ${timeago.format(widget.server.next_wipe, allowFromNow: true).replaceAll("from now", "")}",
                        Colors.purple[900]!),
                  ],
                ),
                SizedBox(height: 1.h),
                SizedBox(
                    height: 199,
                    child: Scrollbar(
                      controller: scroll_controller,
                      isAlwaysShown: true,
                      child: ListView(
                        controller: scroll_controller,
                        children: [
                          Container(
                            padding: EdgeInsets.all(5.sp),
                            color: HexColor("#202020"),
                            child: Text(
                              widget.server.description
                                  .replaceAll("\\t", "      "),
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    )),
                Padding(
                  padding: EdgeInsets.all(10.sp),
                  child: Container(
                    padding: EdgeInsets.all(10.sp),
                    color: HexColor("#202020"),
                    child: Text(
                        "connect ${widget.server.ip}:${widget.server.port}",
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            letterSpacing: -0.5)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!await launch(widget.server.url))
                        throw 'Could not launch';
                    },
                    child: Text("Visit Website"),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(HexColor("#264653"))),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
