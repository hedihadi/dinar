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
import 'package:RustCompanion/Functions/ApiManager.dart';
import 'package:RustCompanion/Screens/Notifications/AddNotification/AddNotification_ServerWidget.dart';
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

class SelectServer extends StatefulWidget {
  const SelectServer({Key? key}) : super(key: key);

  @override
  State<SelectServer> createState() => _AddNewServerState();
}

class _AddNewServerState extends State<SelectServer> {
  TextEditingController search_controller = TextEditingController();
  final ApiManager api_manager = ApiManager();
  ScrollController scroll_controller = ScrollController();
  List<Server> servers = [];
  int key = 0;
  StreamController<Response> controller = StreamController<Response>.broadcast();
  @override
  void initState() {
    super.initState();
    controller.stream.listen((event) {
      if (event.key == key) {
        servers.add(event.server!);
        servers.sort((b, a) => a.players.compareTo(b.players));
        setState(() {});
      }
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
          title: Text("Select A Server", overflow: TextOverflow.ellipsis)),
      body: ListView(
        shrinkWrap: true,
        children: [
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: TextFormField(
              controller: search_controller,
              decoration: InputDecoration(
                filled: true,
                fillColor: ColorManager().background1,
                labelText: "Search for Server's Name",
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: ElevatedButton(
                onPressed: () {
                  key = Random().nextInt(999999);
                  setState(() {
                    servers.clear();
                  });
                  //api_manager.searchServers(search_controller.text, key, controller, context);
                },
                child: Text("Search")),
          ),
          ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: servers.length,
              itemBuilder: (context, index) {
                return SelectServer_Server(server: servers[index]);
              }),
        ],
      ),
    );
  }
}
