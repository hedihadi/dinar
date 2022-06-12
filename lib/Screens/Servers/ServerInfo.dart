import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:RustCompanion/Functions/ApiManager.dart';
import 'package:RustCompanion/Functions/LocalStorageManager.dart';
import 'package:RustCompanion/Screens/Players/PlayerWidget.dart';
import 'package:RustCompanion/Screens/Servers/ServerInfo_playerWidget.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/src/provider.dart';
import 'package:RustCompanion/Providers/ServersProvider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart' as intll;
import 'package:http/http.dart' as http;
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
import 'package:url_launcher/url_launcher.dart';

class ServerInfo extends StatefulWidget {
  ServerInfo({Key? key, required this.server}) : super(key: key);
  Server server;

  @override
  State<ServerInfo> createState() => _ServerInfoState();
}

class _ServerInfoState extends State<ServerInfo> {
  ScrollController scroll_controller = ScrollController(initialScrollOffset: 0);
  StreamController<Player> controller = StreamController<Player>.broadcast();
  TextEditingController filter_controller = TextEditingController();

  List<Player> players = [];
  List<Player> filtered_players = [];

  bool players_loading = false;
  @override
  void initState() {
    super.initState();
  }

  Future<void> loadPlayers() async {
    setState(() {
      players_loading = true;
      players.clear();
    });
    players = await ApiManager().getPlayersFromServer(widget.server.id, context);
    filtered_players = players;
    filter_controller.text = "";
    setState(() {
      players_loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager().background,
      appBar: AppBar(
          elevation: 0,
          backgroundColor: ColorManager().background1,
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
                ).createShader(Rect.fromLTRB(0, 0, rect.width * 0.2, rect.height * 0.9));
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
                        style: TextStyle(
                          color: ColorManager().title,
                          fontSize: 20.sp,
                          letterSpacing: 0.5.sp,
                        )),
                  ),
                  Flexible(
                    child: IconButton(
                        onPressed: () async {
                          if (widget.server.favorited == false) {
                            context.read<ServersProvider>().add_favorited_server(widget.server.id);
                            setState(() {
                              widget.server.favorited = true;
                            });
                          } else {
                            context.read<ServersProvider>().remove_favorited_server(widget.server.id);
                            setState(() {
                              widget.server.favorited = false;
                            });
                          }
                        },
                        icon: widget.server.favorited == false
                            ? Icon(Icons.star_border, size: 25.sp, color: Colors.white)
                            : Icon(Icons.star, size: 25.sp, color: HexColor("#FFDE32")),
                        color: widget.server.favorited == false ? ColorManager().positive : ColorManager().negative),
                  ),
                ]),
                SizedBox(
                  height: 2.h,
                ),
                Wrap(
                  spacing: 1.w,
                  runSpacing: 1.h,
                  children: [
                    tag(widget.server.type.toString().replaceAll("ServerType.", "").capitalize(), Container()),
                    tag(widget.server.wipe_type.toString().replaceAll("WipeType.", "").capitalize(), Container()),
                    tag("${widget.server.players}/${widget.server.max_players} ${widget.server.queued_players == 0 ? '' : ('(${widget.server.queued_players} queued)')}",
                        Icon(FontAwesomeIcons.userGroup)),
                    tag("${timeago.format(widget.server.last_wipe)}", Icon(FontAwesomeIcons.arrowRotateRight)),
                    tag("Next Wipe: ${timeago.format(widget.server.next_wipe, allowFromNow: true).replaceAll("from now", "")}", Container()),
                  ],
                ),
                SizedBox(height: 1.h),
                SizedBox(
                    height: 15.h,
                    child: Scrollbar(
                      controller: scroll_controller,
                      isAlwaysShown: true,
                      child: ListView(
                        controller: scroll_controller,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.sp),
                            color: ColorManager().background1,
                            child: Text(
                              widget.server.description.replaceAll("\\t", "      "),
                              style: TextStyle(color: Colors.grey[500], fontFamily: "RobotoMono", fontWeight: FontWeight.w400),
                            ),
                          )
                        ],
                      ),
                    )),
                SizedBox(height: 2.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 1.w),
                  child: Container(
                    padding: EdgeInsets.all(3.sp),
                    color: ColorManager().background1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("connect ${widget.server.ip}:${widget.server.port}",
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: TextStyle(color: ColorManager().title1, fontSize: 14.sp, letterSpacing: 1)),
                        IconButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: "connect ${widget.server.ip}:${widget.server.port}"));
                            },
                            icon: Icon(Icons.content_paste, color: ColorManager().accent, size: 20.sp))
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 30.w),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!await launch(widget.server.url)) throw 'Could not launch';
                      if (await LocalStorageManager().is_collect_data_enabled()) {
                        await FirebaseAnalytics.instance.logEvent(
                          name: "visited_website",
                          parameters: {
                            "serverid": "${widget.server.id}",
                          },
                        );
                      }
                    },
                    child: Text(
                      "Visit Website",
                      style: TextStyle(color: ColorManager().background1),
                    ),
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(ColorManager().accent)),
                  ),
                ),
                Divider(color: ColorManager().accent),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: players.length == 0
                      ? players_loading
                          ? Padding(
                              padding: EdgeInsets.symmetric(horizontal: 40.w),
                              child: SizedBox(
                                height: 10.sp,
                                width: 10.sp,
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () async {
                                loadPlayers();
                                if (await LocalStorageManager().is_collect_data_enabled()) {
                                  await FirebaseAnalytics.instance.logEvent(
                                    name: "loaded_players",
                                    parameters: {
                                      "serverid": "${widget.server.id}",
                                    },
                                  );
                                }
                              },
                              child: Text(
                                "Load Players",
                                style: TextStyle(color: ColorManager().background1),
                              ),
                              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(ColorManager().accent)),
                            )
                      : Container(
                          width: 40.w,
                          child: TextField(
                            onSubmitted: (str) {
                              if (filter_controller.text == null || filter_controller.text.length == 0 || filter_controller.text == "") {
                                filtered_players = players;
                                setState(() {});
                              }
                              filtered_players =
                                  players.where((element) => element.name.toLowerCase().contains(filter_controller.text.toLowerCase())).toList();
                              setState(() {});
                            },
                            controller: filter_controller,
                            style: TextStyle(color: ColorManager().accent),
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.search),
                                suffixIcon: IconButton(
                                    onPressed: () async {
                                      loadPlayers();
                                      if (await LocalStorageManager().is_collect_data_enabled()) {
                                        await FirebaseAnalytics.instance.logEvent(
                                          name: "players_refreshed",
                                          parameters: {
                                            "serverid": "${widget.server.id}",
                                          },
                                        );
                                      }
                                    },
                                    icon: Icon(Icons.refresh, color: Colors.grey[500])),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(3.sp),
                                  borderSide: BorderSide.none,
                                ),
                                labelStyle: TextStyle(color: Colors.grey[500]),
                                filled: true,
                                fillColor: ColorManager().background1,
                                labelText: "Search player name...",
                                floatingLabelBehavior: FloatingLabelBehavior.never),
                          ),
                        ),
                ),
                SizedBox(height: 1.h),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: filtered_players.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.all(2.sp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ServerInfo_PlayerWidget(
                            player: filtered_players[index],
                          )
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 10.h),
              ],
            ),
          )
        ],
      ),
    );
  }
}
