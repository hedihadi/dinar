import 'dart:math';

import 'package:RustCompanion/Functions/LocalStorageManager.dart';
import 'package:RustCompanion/GuideWidgets/GuideObjects.dart';
import 'package:RustCompanion/utils/utils.dart';
import 'package:auto_start_flutter/auto_start_flutter.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class GuideManager {
  ///show guide will show a guide notification and will return when the dialog is closed
  ///[id] is used to keep track of the different guides, if user checks [dont_show_guide_again] the [id] will be used to identify the guide
  static Future<void> show_guide(int id, BuildContext context, List<Widget> widgets, bool barrierDismissible) async {
    //first check if this guide is disabled
    if (await LocalStorageManager().is_guide_disabled(id)) {
      return;
    }
    int page = 0;
    bool dont_show_guide_again = false;
    AlertDialog alert = AlertDialog(
      contentPadding: EdgeInsets.all(10.sp),
      //padd: EdgeInsets.all(0),

      backgroundColor: HexColor("#222222"),
      title: Text("Notifications?", style: TextStyle(color: Colors.amber), textAlign: TextAlign.center),
      content: SizedBox(
        height: 60.h,
        width: 90.w,
        child: StatefulBuilder(
          builder: (context, setState) {
            return AnimatedSwitcher(
              switchInCurve: Curves.fastOutSlowIn,
              duration: Duration(milliseconds: 500),
              child: ListView(
                key: ValueKey<int>(Random().nextInt(2222)),
                shrinkWrap: true,
                children: [
                  widgets[page],
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      (page == 0)
                          ? Container()
                          : ElevatedButton(
                              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(HexColor("#303030"))),
                              onPressed: () {
                                setState(() {
                                  page = page - 1;
                                });
                              },
                              child: Text("Last")),
                      page >= widgets.length - 1
                          ? Container()
                          : ElevatedButton(
                              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(HexColor("#303030"))),
                              onPressed: () {
                                setState(() {
                                  page = page + 1;
                                });
                              },
                              child: Text("Next")),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Checkbox(
                        value: dont_show_guide_again,
                        onChanged: (bool) async {
                          await LocalStorageManager().disable_guide(id);
                          setState(() {
                            dont_show_guide_again = bool ?? false;
                          });
                        },
                      ),
                      Text(
                        "don't show Guide again",
                        style: TextStyle(fontSize: 9.sp),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
    await showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return SizedBox(height: 60.h, width: 90.w, child: alert);
      },
    );
  }
}
