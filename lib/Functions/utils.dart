import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinar/Functions/get_it.dart';
import 'package:dinar/Functions/models.dart';
import 'package:dinar/Providers/localization_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/src/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:timeago/timeago.dart';
import 'package:intl/intl.dart' as intll;

calculateTextDirection(BuildContext context) {
  return context.read<LocalizationProvider>().language == "english" ? TextDirection.ltr : TextDirection.rtl;
}

localizePrice(String number, BuildContext context) {
  if (context.read<LocalizationProvider>().language == "english") {
    return number;
  }
  if (GetIt.instance<GlobalClass>().getSettings(SettingsData.UseEnglishNumbers) == true) {
    return number;
  }
  number = number.replaceAll('0', "٠");
  number = number.replaceAll('1', "١");
  number = number.replaceAll('2', "٢");
  number = number.replaceAll('3', "٣");
  number = number.replaceAll('4', "٤");
  number = number.replaceAll('5', "٥");
  number = number.replaceAll('6', "٦");
  number = number.replaceAll('7', "٧");
  number = number.replaceAll('8', "٨");
  number = number.replaceAll('9', "٩");
  return number;
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

extension IntExtension on num {
  String formatCurrency() {
    num number = this;
    final formatCurrency = intll.NumberFormat("#,##0.##");
    if (GetIt.instance<GlobalClass>().getSettings(SettingsData.RoundPrices) == true) {
      number = roundNumber(double.parse(this.toString()).toInt());
    }
    return formatCurrency.format(number).toString();
  }
}

int roundNumber(int number) {
  int a = number % 250;

  if (a > 0) {
    return (number ~/ 250) * 250 + 250;
  }

  return number;
}

List<Currency> parseData(Map<String, dynamic> datas) {
  List<Currency> data = [];
  List<Price> prices = [];
  for (var element in (datas)["iqdprices"].entries) {
    Timestamp timestamp = Timestamp.fromMillisecondsSinceEpoch(int.parse(element.key));
    Price dollarValue = Price(timestamp, element.value.toDouble());
    prices.add(dollarValue);
  }
  prices.sort((b, a) => a.timestamp.compareTo(b.timestamp));
  //add the price list to currency
  Currency cu = Currency();
  cu.color = Colors.green[400]!;
  cu.flag = "assets/images/countries/us.webp";
  cu.name = "US Dollars";
  cu.suffix = "Dollars";
  cu.prices = prices;
  cu.baseAmount = "100";
  cu.databaseName = "iqdprices";
  cu.conversionFactor = 100;
  data.add(cu);
  //////////////////////////////////////////////
  //////////////////////////////////////////////
  prices = [];
  for (var element in (datas)["tmanprices"].entries) {
    Timestamp timestamp = Timestamp.fromMillisecondsSinceEpoch(int.parse(element.key));
    Price dollarValue = Price(timestamp, element.value.toDouble());
    prices.add(dollarValue);
  }
  prices.sort((b, a) => a.timestamp.compareTo(b.timestamp));
  cu = Currency();
  cu.color = Colors.yellow[400]!;
  cu.flag = "assets/images/countries/iran.png";
  cu.name = "Iranian Toman";
  cu.suffix = "Tomans";
  cu.prices = prices;
  cu.databaseName = "tmanprice";
  cu.baseAmount = "100,000";
  cu.conversionFactor = 100000;
  data.add(cu);
  //////////////////////////////////////////////
  //////////////////////////////////////////////
  prices = [];
  for (var element in (datas)["turkishprices"].entries) {
    Timestamp timestamp = Timestamp.fromMillisecondsSinceEpoch(int.parse(element.key));
    Price dollarValue = Price(timestamp, element.value.toDouble());
    prices.add(dollarValue);
  }
  prices.sort((b, a) => a.timestamp.compareTo(b.timestamp));
  cu = Currency();
  cu.color = Colors.red[200]!;
  cu.flag = "assets/images/countries/turkey.png";
  cu.name = "Turkish Lira";
  cu.suffix = "Liras";
  cu.prices = prices;
  cu.databaseName = "turkishprices";
  cu.baseAmount = "100";
  cu.conversionFactor = 100;
  data.add(cu);
  //////////////////////////////////////////////
  //////////////////////////////////////////////
  prices = [];
  for (var element in (datas)["europrices"].entries) {
    Timestamp timestamp = Timestamp.fromMillisecondsSinceEpoch(int.parse(element.key));
    Price dollarValue = Price(timestamp, element.value.toDouble());
    prices.add(dollarValue);
  }
  prices.sort((b, a) => a.timestamp.compareTo(b.timestamp));
  cu = Currency();
  cu.color = Colors.amber[400]!;
  cu.flag = "assets/images/countries/europe.png";
  cu.name = "Euro";
  cu.suffix = "Euros";
  cu.prices = prices;
  cu.baseAmount = "100";
  cu.databaseName = "europrices";
  cu.conversionFactor = 100;
  data.add(cu);
  //////////////////////////////////////////////
  //////////////////////////////////////////////
  prices = [];
  for (var element in (datas)["britishprices"].entries) {
    Timestamp timestamp = Timestamp.fromMillisecondsSinceEpoch(int.parse(element.key));
    Price dollarValue = Price(timestamp, element.value.toDouble());
    prices.add(dollarValue);
  }
  prices.sort((b, a) => a.timestamp.compareTo(b.timestamp));

  cu = Currency();
  cu.color = Colors.amber[400]!;
  cu.flag = "assets/images/countries/uk.webp";
  cu.name = "British Pound";
  cu.suffix = "Pounds";
  cu.prices = prices;
  cu.databaseName = "britishprices";
  cu.baseAmount = "100";
  cu.conversionFactor = 100;
  data.add(cu);

  return data;
}
