import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;

class LocalizationProvider with ChangeNotifier {
  Map<String, dynamic> localization_map = {};
  String language = "kurdish";

  ///below list is automatically populatd, just edit [localization.json].
  List<String> available_languages = [];
  LocalizationProvider() {
    //set default language if it haven't been chosen yet
    SharedPreferences.getInstance().then((prefs) async {
      if (!prefs.containsKey("language")) {
        prefs.setString("language", "kurdish");
      } else {
        language = prefs.getString("language")!;
      }

      ///now load [localization_map]
      String data = await rootBundle.loadString('assets/localization.json');
      localization_map = jsonDecode(data);
      for (var element in localization_map.entries.first.value.keys) {
        available_languages.add(element);
      }
      //manually add english because its the default one
      available_languages.add("english");

      notifyListeners();
    });
  }

  changeLanguage(String lang) async {
    FirebaseAnalytics.instance.logEvent(name: 'language_changed', parameters: {'language': lang});

    language = lang;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("language", lang);
    notifyListeners();
  }
}
