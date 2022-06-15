import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinar/Functions/colors.dart';
import 'package:dinar/Functions/data.dart';
import 'package:dinar/Functions/utils.dart';
import 'package:dinar/Screens/Menu/about_screen.dart';
import 'package:dinar/Screens/Menu/settings_screen.dart';
import 'package:dinar/Screens/calculator.dart';
import 'package:dinar/Screens/Home/home.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:sizer/sizer.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedTab = 0;
  List<Widget> tabWidgets = [];
  bool autostart_enabled = false;
  bool batteryoptimization_enabled = false;
  @override
  void initState() {
    tabWidgets = [HomeScreen(), CalculatorScreen()];
    initialize();
  }

  initialize() async {
    batteryoptimization_enabled = await DisableBatteryOptimization.isBatteryOptimizationDisabled ?? false;
    autostart_enabled = await DisableBatteryOptimization.isAutoStartEnabled ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("")),
      drawer: Drawer(
        child: Container(
          width: 30.w,
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: backgroundColor1,
                ),
                child: Column(
                  children: [
                    Text(
                      "Dinar - دینار",
                      style: TextStyle(color: Colors.red[400], fontSize: 20.sp, fontFamily: "uniqaidar"),
                    ),
                    SizedBox(height: 2.h),
                    GestureDetector(
                      onTap: () async {
                        await DisableBatteryOptimization.showEnableAutoStartSettings(
                            "Enable Auto Start", "Follow the steps and enable the auto start of this app");
                        setState(() async {
                          batteryoptimization_enabled = await DisableBatteryOptimization.isBatteryOptimizationDisabled ?? false;
                          autostart_enabled = await DisableBatteryOptimization.isAutoStartEnabled ?? false;
                        });
                      },
                      child: tag(
                          '${autostart_enabled ? "Autostart is enabled".localize(context) : "please enable Autostart".localize(context)}',
                          Icon(autostart_enabled ? FontAwesomeIcons.check : FontAwesomeIcons.xmark,
                              color: autostart_enabled ? Colors.green[400] : Colors.red[300])),
                    ),
                    SizedBox(height: 1.h),
                    GestureDetector(
                      onTap: () async {
                        await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
                        setState(() async {
                          batteryoptimization_enabled = await DisableBatteryOptimization.isBatteryOptimizationDisabled ?? false;
                          autostart_enabled = await DisableBatteryOptimization.isAutoStartEnabled ?? false;
                        });
                      },
                      child: tag(
                          '${batteryoptimization_enabled ? "please disable Battery Optimization".localize(context) : "Battery Optimization is disabled".localize(context)}',
                          Icon(batteryoptimization_enabled == false ? FontAwesomeIcons.check : FontAwesomeIcons.xmark,
                              color: batteryoptimization_enabled == false ? Colors.green[400] : Colors.red[300])),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text(
                  'Settings'.localize(context),
                  style: TextStyle(fontFamily: "Roboto", fontWeight: FontWeight.w500, color: Colors.grey[200], fontSize: 13.sp, letterSpacing: 1.sp),
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
                  'About'.localize(context),
                  style: TextStyle(fontFamily: "Roboto", fontWeight: FontWeight.w500, color: Colors.grey[200], fontSize: 13.sp, letterSpacing: 1.sp),
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
      bottomNavigationBar: Directionality(
        textDirection: calculateTextDirection(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 0.01.h,
              color: Colors.red[900],
            ),
            BottomNavigationBar(
              backgroundColor: HexColor("#151515"),
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home'.localize(context),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calculate),
                  label: 'Calculator'.localize(context),
                ),
              ],
              currentIndex: selectedTab,
              selectedItemColor: Colors.red,
              unselectedItemColor: HexColor("#808080"),
              onTap: (index) async {
                setState(() {
                  selectedTab = index;
                });
                await FirebaseAnalytics.instance.logEvent(name: 'change_screen', parameters: {
                  'screen': selectedTab == 0 ? "homescreen" : "calculatorscreen",
                  "org": GetIt.instance<Data>().org,
                  "region": GetIt.instance<Data>().region,
                  "ip": GetIt.instance<Data>().ip,
                  "country": GetIt.instance<Data>().country,
                });
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        children: tabWidgets,
        index: selectedTab,
      ),
    );
  }
}
