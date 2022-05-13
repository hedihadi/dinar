import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
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
extension StringExtension on String {
    String capitalize() {
      return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
    }
}
Widget tag(String text, Color color) {
    return Container(
      padding: EdgeInsets.all(2.sp),
      decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: color,
          ),
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Text(text, style: TextStyle(color: Colors.white)),
    );
  }