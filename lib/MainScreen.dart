import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:RustCompanion/GuideWidgets/GuideManager.dart';
import 'package:RustCompanion/Providers/PlayersProvider.dart';
import 'package:RustCompanion/Providers/RefreshPlayersProvider.dart';
import 'package:RustCompanion/Screens/Menu/AboutScreen.dart';
import 'package:RustCompanion/Screens/Menu/SettingsScreen.dart';
import 'package:RustCompanion/Screens/Players/AddNewPlayer.dart';
import 'package:RustCompanion/Screens/Players/Players.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';

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
import 'package:RustCompanion/Functions/ApiManager.dart';
import 'package:RustCompanion/Functions/LocalStorageManager.dart';
import 'package:RustCompanion/GuideWidgets/GuideObjects.dart';
import 'package:RustCompanion/Providers/NotificationsProvider.dart';
import 'package:RustCompanion/Providers/RefreshServersProvider.dart';
import 'package:RustCompanion/Providers/ServersProvider.dart';
import 'package:RustCompanion/Screens/Notifications/AddNotification/AddNewNotification.dart';
import 'package:RustCompanion/Screens/Servers/AddNewServer.dart';
import 'package:RustCompanion/Screens/Servers/Servers.dart';
import 'package:RustCompanion/Screens/Notifications/Notifications.dart';
import 'package:RustCompanion/utils/ColorManager.dart';
import 'package:RustCompanion/utils/models.dart';
import 'package:RustCompanion/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as dartio;
import 'package:google_mobile_ads/google_mobile_ads.dart' as ad;
import 'package:function_tree/function_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import 'package:auto_start_flutter/auto_start_flutter.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Widget? floating_action_button;
  int _selected_index = 0;
  List<Widget> widgets = [];
  bool loaded = false;
  bool autostart_enabled = false;
  bool batteryoptimization_enabled = false;

  @override
  void initState() {
    super.initState();
    widgets = [
      Servers(),
      Players(),
      Notifications(),
    ];
    initialize();
  }

  ///this function basically reads the local storage data
  ///and parses them into objects and pushes it into the providers.
  initialize() async {
    final prefs = await SharedPreferences.getInstance();
    //setting up batteryoptimization_enabled and autostart_enabled
    batteryoptimization_enabled = await DisableBatteryOptimization.isBatteryOptimizationDisabled ?? false;
    autostart_enabled = await DisableBatteryOptimization.isAutoStartEnabled ?? false;

    //setting up favorited servers
    List<int> favorited_servers = [];
    favorited_servers = List<int>.from(jsonDecode(prefs.getString("favorited_servers") ?? "[]"));
    context.read<ServersProvider>().set_favorited_servers(favorited_servers);
    //setting up favorited servers

    //setting up favorited players
    List<int> favorited_players = [];
    favorited_players = List<int>.from(jsonDecode(prefs.getString("favorited_players") ?? "[]"));
    context.read<PlayersProvider>().set_favorited_players(favorited_players);
    //setting up favorited players

    //setting up notifications
    var notifications = await LocalStorageManager().load_notifications();
    context.read<NotificationsProvider>().set(notifications);
    //setting up notifications

    //retrieve updated data for [favorited_servers] and [favorited_players]
    await ApiManager().getFavoritedServers(context);
    await ApiManager().getFavoritedPlayers(context);

    //app is ready, show it!
    setState(() {
      loaded = true;
    });
    //ask for some minor permissions
    await Permission.notification.request();
    //guide the user to give us the needed permissions
    GuideManager.show_guide(384837437, context, GuideWidgets.get_welcome_guide(context), true);

    //listen to server refresh
    context.read<RefreshServersProvider>().addListener(() async {
      await ApiManager().getFavoritedServers(context);
    });

    //listen to player refresh
    context.read<RefreshPlayersProvider>().addListener(() async {
      await ApiManager().getFavoritedPlayers(context);
    });

    //setup settings if they don't exist, so they won't be null
    if (prefs.containsKey("debug") == false) {
      prefs.setBool("debug", false);
    }
    if (prefs.containsKey("collect_data") == false) {
      prefs.setBool("collect_data", true);
    }
    if (prefs.containsKey("notifications_frequency") == false) {
      prefs.setInt("notifications_frequency", 5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return loaded == false
        ? Center(child: CircularProgressIndicator(color: ColorManager().title))
        : Scaffold(
            backgroundColor: ColorManager().background,
            key: _scaffoldKey,
            drawer: Drawer(
              child: Container(
                width: 30.w,
                child: ListView(
                  // Important: Remove any padding from the ListView.
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      decoration: BoxDecoration(
                        color: ColorManager().background1,
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Rust Companion",
                            style: TextStyle(color: ColorManager().title, fontSize: 20.sp, fontFamily: "BebasNeue"),
                          ),
                          SizedBox(height: 2.h),
                          GestureDetector(
                            onTap: () {
                              DisableBatteryOptimization.showEnableAutoStartSettings(
                                  "Enable Auto Start", "Follow the steps and enable the auto start of this app");
                            },
                            child: tag(
                                "Autostart is ${autostart_enabled ? 'enabled' : 'disabled'}",
                                Icon(autostart_enabled ? FontAwesomeIcons.check : FontAwesomeIcons.xmark,
                                    color: autostart_enabled ? ColorManager().accent : Colors.red[300])),
                          ),
                          SizedBox(height: 1.h),
                          GestureDetector(
                            onTap: () {
                              DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
                            },
                            child: tag(
                                "Battery Optimization is ${batteryoptimization_enabled ? 'enabled' : 'disabled'}",
                                Icon(batteryoptimization_enabled == false ? FontAwesomeIcons.check : FontAwesomeIcons.xmark,
                                    color: batteryoptimization_enabled == false ? ColorManager().accent : Colors.red[300])),
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      
                      title: Text(
                        'Settings',
                        style: TextStyle(
                            fontFamily: "Roboto", fontWeight: FontWeight.w500, color: Colors.grey[200], fontSize: 13.sp, letterSpacing: 1.sp),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SettingsScreen()),
                        );
                      },
                    ),
                    Divider(),
                    ListTile(
                      title: Text(
                        'About',
                        style: TextStyle(
                            fontFamily: "Roboto", fontWeight: FontWeight.w500, color: Colors.grey[200], fontSize: 13.sp, letterSpacing: 1.sp),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AboutScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            appBar: AppBar(
              title: Text(
                widgets[_selected_index].runtimeType.toString(),
                style: TextStyle(fontFamily: "RobotoMono", fontWeight: FontWeight.w600),
              ),
              backgroundColor: ColorManager().background1,
            ),
            body: IndexedStack(
              index: _selected_index,
              children: widgets,
            ),
            bottomNavigationBar: BottomNavigationBar(
              iconSize: 20.sp,
              backgroundColor: HexColor("#151515"),
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.server),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.userGroup),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.bell),
                  label: '',
                ),
              ],
              currentIndex: _selected_index,
              selectedItemColor: ColorManager().accent,
              onTap: (int index) {
                setState(() {
                  _selected_index = index;
                });
              },
            ),
            floatingActionButton: floatingActionButton(),
          );
  }

  Widget floatingActionButton() {
    if (widgets[_selected_index].runtimeType == Servers) {
      return FloatingActionButton(
          elevation: 0.0,
          child: Icon(Icons.add, color: Colors.white),
          backgroundColor: ColorManager().accent,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddNewServer()),
            );
          });
    } else if (widgets[_selected_index].runtimeType == Notifications) {
      return FloatingActionButton(
          elevation: 0.0,
          child: Icon(Icons.add, color: Colors.white),
          backgroundColor: ColorManager().accent,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddNewNotification()),
            );
          });
    } else if (widgets[_selected_index].runtimeType == Text) {
      return FloatingActionButton(
          elevation: 0.0,
          child: Icon(Icons.add, color: Colors.white),
          backgroundColor: ColorManager().accent,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddNewPlayer()),
            );
          });
    } else {
      return Container();
    }
  }
}
