import 'package:RustCompanion/utils/ColorManager.dart';
import 'package:RustCompanion/utils/utils.dart';
import 'package:auto_start_flutter/auto_start_flutter.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class GuideWidgets {
  static List<Widget> get_welcome_guide(BuildContext context) {
    List<Widget> welcome_guide = [
      ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          Text(
            "Welcome!",
            style: TextStyle(letterSpacing: 1.sp, fontSize: 15.sp),
            textAlign: TextAlign.center,
          ),
          Text(
            "to make sure the Application can work as intended, you must grant the App some permissions",
            style: TextStyle(fontSize: 12.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Container(
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey[800]!,
                ),
                borderRadius: BorderRadius.all(Radius.circular(5.sp))),
            child: Padding(
              padding: EdgeInsets.all(5.sp),
              child: Column(
                children: [
                  Text(
                    "Application needs Autostart to check for Notifications in Background, you can specify the schedule in Settings.",
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: ElevatedButton(
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(HexColor("#303030"))),
                        onPressed: () async {
                          getAutoStartPermission();
                        },
                        child: Text("Give Autostart Permission")),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey[800]!,
                ),
                borderRadius: BorderRadius.all(Radius.circular(5.sp))),
            child: Padding(
              padding: EdgeInsets.all(5.sp),
              child: Column(
                children: [
                  Text(
                    "you must disable Battery Optimization for the App, otherwise it prevents the App from starting in background.",
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: ElevatedButton(
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(HexColor("#303030"))),
                        onPressed: () async {
                          await DisableBatteryOptimization.showEnableAutoStartSettings(
                              "Enable Auto Start", "Follow the steps and enable the auto start of this app");
                        },
                        child: Text("Disable Battery Optimization")),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    ];
    return welcome_guide;
  }
}
