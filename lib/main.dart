import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rustwipe/my_servers.dart';
import 'package:rustwipe/servers_list.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  ad.MobileAds.instance.initialize();
  ad.MobileAds.instance.updateRequestConfiguration(RequestConfiguration(
      testDeviceIds: ["E00E3C49D5ADD897C777922D286C66FD"]));
  runApp(Sizer(builder: (context, orientation, deviceType) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark().copyWith(
        appBarTheme: AppBarTheme(color: Colors.grey[900]),
        scaffoldBackgroundColor: HexColor("#131313"),
        textTheme: TextTheme(
          bodyText1: TextStyle(),
          bodyText2: TextStyle(),
        ).apply(
          bodyColor: Colors.blue,
          displayColor: Colors.blue,
        ),
      ),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "uniqaidar",
      ),
      home: MainScreen(),
    );
  }));
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Server> servers = [];
  StreamController<Response> controller =
      StreamController<Response>.broadcast();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  int _selected_index = 0;
  List<Widget> widgets = [];

  @override
  void initState() {
    super.initState();
    controller.stream.listen((response) {
      if ((response.response_type) == ResponseType.error) {
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          _scaffoldKey.currentState!.showSnackBar(new SnackBar(
              content: Text("error ${response.details ?? "default"}")));
        });
      }
      if (response.server != null) {
        servers.add(response.server!);
      }
    });
    ApiManager(controller: controller).initGetServers();
    widgets = [
      StreamBuilder<Response>(
          stream: controller.stream,
          builder: (context, AsyncSnapshot<Response> snapshot) {
            return ServersList(servers: servers);
          }),
      MyServers(servers: servers, scaffold_key: _scaffoldKey)
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#101010"),
      key: _scaffoldKey,
      appBar: AppBar(),
      body: IndexedStack(
        index: _selected_index,
        children: widgets,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Servers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'My Servers',
          ),
        ],
        currentIndex: _selected_index,
        selectedItemColor: Colors.amber[800],
        onTap: (int index) {
          setState(() {
            _selected_index = index;
          });
        },
      ),
    );
  }
}
