import 'dart:convert';

import 'package:dinar/Functions/models.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../Functions/get_it.dart';

class ThemeProvider with ChangeNotifier {
  bool? darkTheme;
  ThemeProvider() {
    SharedPreferences.getInstance().then((value) {
      darkTheme = value.getBool('DarkTheme') ?? null;
    });
    darkTheme = GetIt.instance<GlobalClass>().getSettings(SettingsData.DarkTheme);
  }
  changeTheme(bool theme) {
    darkTheme = theme;
    notifyListeners();
  }
}
