import 'dart:io';
import 'dart:math';

import 'package:dinar/Providers/localization_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/src/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:timeago/timeago.dart';
import 'package:intl/intl.dart' as intll;

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

calculateTextDirection(BuildContext context) {
  return context.read<LocalizationProvider>().language == "english" ? TextDirection.ltr : TextDirection.rtl;
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
  String localize(BuildContext context) {
    var localization_map = context.read<LocalizationProvider>().localization_map;
    var language = context.read<LocalizationProvider>().language;

    //default localization is english, thus return the same text if its english.
    if (language == "english") {
      return this;
    }

    if (localization_map.containsKey(this)) {
      if (localization_map[this]!.containsKey(language)) {
        return localization_map[this]![language]!;
      }
    }

    ///if the code reaches here, that means the localization does not contain the requested text
    ///thus, simply return the same text.
    return this;
  }
}

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

class CustomEnglish extends EnMessages {
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => 'لەمەوبەر';
  @override
  String suffixFromNow() => 'دوای';
  @override
  String lessThanOneMinute(int seconds) => 'کەمێک لەمەوبەر';
  @override
  String aboutAMinute(int minutes) => 'یەک خولەک';
  @override
  String minutes(int minutes) => '$minutes خولەک';
  @override
  String aboutAnHour(int minutes) => 'نزیکەی کاتژمێرێک';
  @override
  String hours(int hours) => '$hours کاتژمێر';
  @override
  String aDay(int hours) => 'ڕۆژێک';
  @override
  String days(int days) => '$days ڕۆژ';
  @override
  String aboutAMonth(int days) => 'نزیکەی مانگێک';
  @override
  String months(int months) => '$months مانگ';
  @override
  String aboutAYear(int year) => 'نزیکەی ساڵێک';
  @override
  String years(int years) => '$years ساڵ';
  @override
  String wordSeparator() => ' ';
}

double dp(double val, int places) {
  num mod = pow(10.0, places);
  return ((val * mod).round().toDouble() / mod);
}

extension IntExtension on num {
  String formatCurrency() {
    final formatCurrency = intll.NumberFormat("#,##0.##");
    return formatCurrency.format(this).toString();
  }
}
