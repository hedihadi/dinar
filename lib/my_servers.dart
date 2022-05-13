import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rustwipe/ServerInfo.dart';
import 'package:rustwipe/my_server.dart';
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

class MyServers extends StatefulWidget {
  MyServers({Key? key, required this.servers, required this.scaffold_key})
      : super(key: key);
  List<Server> servers;
  GlobalKey<ScaffoldState> scaffold_key;
  @override
  State<MyServers> createState() => _MyServersState();
}

class _MyServersState extends State<MyServers> {
  List<Server> servers = [];
  StreamController<Response> controller =
      StreamController<Response>.broadcast();
  late ApiManager api_manager;
  late StreamSubscription listen;
  Key key = GlobalKey();
  @override
  void dispose() {
    super.dispose();
    listen.cancel();
    controller.close();
  }

  @override
  void initState() {
    super.initState();
    api_manager = ApiManager(controller: controller);
    listen = controller.stream.listen((response) async {
      if ((response.response_type) == ResponseType.error) {
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          widget.scaffold_key.currentState!.showSnackBar(new SnackBar(
              content: Text("error ${response.details ?? "default"}")));
        });
        Future.delayed(Duration(seconds: 60), () async {
          var prefs = await SharedPreferences.getInstance();
          api_manager.getFavoritedServers(prefs);
        });
      }
      if (response.server != null) {
        if (servers.map((e) => e.id).toList().contains(response.server!.id) ==
            false) {
          servers.add(response.server!);
          setState(() {});
        }
        var prefs = await SharedPreferences.getInstance();

        api_manager.getFavoritedServers(prefs);
      }
    });
    SharedPreferences.getInstance().then((prefs) {
      api_manager.getFavoritedServers(prefs);
    });

    ;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
          key: key,
          shrinkWrap: true,
          itemCount: servers.length,
          itemBuilder: (context, index) {
            return MyServer(server: servers[index], controller: controller);
          }),
    );
  }
}
