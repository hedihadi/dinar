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
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_tags/flutter_tags.dart';

class AddNewServer_Server extends StatefulWidget {
  AddNewServer_Server({Key? key, required this.server}) : super(key: key);
  Server server;
  @override
  State<AddNewServer_Server> createState() => _MyServerState();
}

class _MyServerState extends State<AddNewServer_Server> {
  late Server server;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    server = widget.server;
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
                    style: TextStyle(fontSize: 15.sp, color: Colors.orange[400]),
                    textAlign: TextAlign.center,
                  ),
                ),
                Flexible(
                  child: Align(
                    alignment: Alignment.topRight,
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
                            ? Icon(Icons.star_outline, size: 25.sp)
                            : Icon(
                                Icons.star,
                                size: 25.sp,
                              ),
                        color: widget.server.favorited == false ? ColorManager().not_favorited : ColorManager().favorited),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Wrap(
              spacing: 1.w,
              runSpacing: 1.h,
              children: [
                tag(server.type.toString().replaceAll("ServerType.", "").capitalize(), Container()),
                tag(server.wipe_type.toString().replaceAll("WipeType.", "").capitalize(), Container()),
                tag("${server.players}/${server.max_players} ${server.queued_players == 0 ? '' : ('(${server.queued_players} queued)')}",
                    Icon(FontAwesomeIcons.userGroup)),
                tag("${timeago.format(server.last_wipe)}", Icon(FontAwesomeIcons.arrowRotateRight)),
                tag("Next Wipe: ${timeago.format(server.next_wipe, allowFromNow: true).replaceAll("from now", "")}", Container()),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ServerInfo(
                            server: widget.server,
                          )),
                );
              },
              child: Text(
                "Open",
                style: TextStyle(color: ColorManager().background1),
              ),
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(ColorManager().accent)),
            ),
          ],
        ),
      ),
    );
  }
}
