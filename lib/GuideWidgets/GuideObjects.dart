import 'package:RustCompanion/utils/utils.dart';
import 'package:auto_start_flutter/auto_start_flutter.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

 class GuideWidgets {
  static List<Widget> notifications_guide = [
    ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        Text(
          "i'm glad you asked!",
          style: TextStyle(letterSpacing: 0.2.sp),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 1.h),
        Image(
          image: AssetImage("assets/images/companion_gladyouasked.jpg"),
        ),
        SizedBox(height: 1.h),
      ],
    ),
    ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        Text(
          "You can Setup many useful Notifications, such as when a Server Wipes.",
          style: TextStyle(letterSpacing: 0.2.sp),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 1.h),
        Image(
          image: AssetImage("assets/images/just_wiped_notification.jpg"),
        ),
        SizedBox(height: 1.h),
      ],
    ),
    Text("More To Come..."),
  ];

  static List<Widget> get_welcome_guide(BuildContext context) {
    List<Widget> welcome_guide = [
      ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          Text(
            "Hello There!",
            style: TextStyle(letterSpacing: 1.sp),
            textAlign: TextAlign.center,
          ),
          Text(
            "-general kenobi!",
            style: TextStyle(letterSpacing: 1.sp, fontSize: 5.sp, color: HexColor("#303030")),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Image(
            image: AssetImage("assets/images/companion_waving.jpg"),
          ),
          SizedBox(height: 1.h),
          Text(
            "Before we Start, let's have a talk...",
            style: TextStyle(letterSpacing: 0.2.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
        ],
      ),
      ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          Text(
            "I'm Gonna Need Some Permissions to Make Sure the App Will Work as Intended...",
            style: TextStyle(letterSpacing: 0.2.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Image(
            image: AssetImage("assets/images/companion_talking.jpg"),
          ),
          SizedBox(height: 1.h),
        ],
      ),
      ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          Text(
            "Don't Like to Give me Permissions? Thats OK! but the App may not Work as intended...",
            style: TextStyle(letterSpacing: 0.2.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Image(
            image: AssetImage("assets/images/companion_ok.jpg"),
          ),
          SizedBox(height: 1.h),
        ],
      ),
      ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          Text(
            "First i need Autostart Permission... so the App can check the Servers in background to send you Notifications!",
            style: TextStyle(letterSpacing: 0.2.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Image(
            image: AssetImage("assets/images/companion_talking.jpg"),
          ),
          SizedBox(height: 1.h),
          Text(
            "Don't forget that i Won't send you any Notifications Without your consent... You Decide what Notification should i send!",
            style: TextStyle(letterSpacing: 0.2.sp, color: Colors.blue),
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
                child: Text("Give Autostart Permission")),
          ),
          SizedBox(height: 1.h),
        ],
      ),
      ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          Text(
            "Now disable Battery Optimization for this App! because it interferes with me!",
            style: TextStyle(letterSpacing: 0.2.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Image(
            image: AssetImage("assets/images/companion_pointing.jpg"),
          ),
          SizedBox(height: 1.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: ElevatedButton(
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(HexColor("#303030"))),
                onPressed: () async {
                  await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
                },
                child: Text("Disable Battery Optimization")),
          ),
          SizedBox(height: 1.h),
        ],
      ),
      ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          Text(
            "Now i'll need Permission to make Calls on your Phone... just kidding we're done, enjoy the App!",
            style: TextStyle(letterSpacing: 0.2.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Image(
            image: AssetImage("assets/images/companion_six.jpg"),
          ),
          SizedBox(height: 1.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: ElevatedButton(
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(HexColor("#303030"))),
                onPressed: () async {
                  Navigator.pop(context);
                },
                child: Text("Close")),
          ),
          SizedBox(height: 1.h),
        ],
      ),
    ];
    return welcome_guide;
  }
}
