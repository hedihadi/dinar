import 'dart:io';
import 'dart:math';

import 'package:RustCompanion/utils/ColorManager.dart';
import 'package:flutter/material.dart';
import 'package:RustCompanion/utils/models.dart';
import 'package:sizer/sizer.dart';
import 'package:timeago/timeago.dart';
import 'package:intl/intl.dart' as intll;

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
}

Future<bool> hasNetwork() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}

extension enumExtension on NotificationType {
  String notificationTypeToString() {
    switch (this) {
      case NotificationType.PlayerComesOnline:
        return "Player Comes Online";
      case NotificationType.PlayerGoesOffline:
        return "Player Goes Offline";
      case NotificationType.ServerWipes:
        return "Server Wipes";
      case NotificationType.PlayerJoinServer:
        return "Player Joins Server";

      case NotificationType.PlayerLeaveServer:
        return "Player Leaves Server";
    }
  }

  String notificationTypeToReadable() {
    switch (this) {
      case NotificationType.PlayerComesOnline:
        return "When Player Comes Online";
      case NotificationType.PlayerGoesOffline:
        return "Player Goes Offline";
      case NotificationType.ServerWipes:
        return "When Server Wipes";
      case NotificationType.PlayerJoinServer:
        return "Player Joins Server";

      case NotificationType.PlayerLeaveServer:
        return "Player Leaves Server";
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }

  NotificationType toNotificationType() {
    switch (this) {
      case "NotificationType.PlayerComesOnline":
        return NotificationType.PlayerComesOnline;
      case "NotificationType.PlayerGoesOffline":
        return NotificationType.PlayerGoesOffline;
      case "NotificationType.ServerWipes":
        return NotificationType.ServerWipes;
      case "NotificationType.PlayerJoinServer":
        return NotificationType.PlayerJoinServer;
      case "NotificationType.PlayerLeaveServer":
        return NotificationType.PlayerLeaveServer;
    }
    return NotificationType.PlayerLeaveServer;
  }
}

Widget tag(String text, Widget icon) {
  return Container(
    height: 4.h,
    padding: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 5.sp),
    decoration: BoxDecoration(
        color: HexColor("#8A6132"),
        border: Border.all(
          color: HexColor("#8A6132"),
        ),
        borderRadius: BorderRadius.all(Radius.circular(3.sp))),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        icon.runtimeType == Container ? Container() : SizedBox(width: 3.w),
        Text(text,
            style: TextStyle(
              fontFamily: "Roboto",
              fontWeight: FontWeight.w500,
              color: Colors.white,
            )),
      ],
    ),
  );
}

Widget tag_player(String text, Widget icon, background) {
  return Container(
    height: 4.h,
    padding: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 5.sp),
    decoration: BoxDecoration(
        color: background,
        border: Border.all(
          color: background,
        ),
        borderRadius: BorderRadius.all(Radius.circular(3.sp))),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        icon.runtimeType == Container ? Container() : SizedBox(width: 3.w),
        Text(text,
            style: TextStyle(
              fontFamily: "Roboto",
              fontWeight: FontWeight.w500,
              color: Colors.white,
            )),
      ],
    ),
  );
}
