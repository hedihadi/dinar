import 'package:dinar/Functions/models.dart';
import 'package:flutter/material.dart';

class Data with ChangeNotifier {
  List<Currency> currencies = [];
  String language = 'kurdish';
  String region = '0';
  String ip = "0";
  String org = "0";
  String country = "0";
  String android_version = "";
  String sdk_version = "";
  String manufacturer = "";
}
