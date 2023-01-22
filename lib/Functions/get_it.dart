import 'package:dinar/Functions/models.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalClass {
  SharedPreferences? prefs;
  GlobalClass() {
    SharedPreferences.getInstance().then((value) => prefs = value);
  }
  getSettings(SettingsData settingsData) {
    switch (settingsData) {
      case SettingsData.OpenCalculatorOnStartup:
        return prefs?.getInt('OpenCalculatorOnStartup') ?? 0;

      case SettingsData.RoundPrices:
        return prefs?.getBool('RoundPrices') ?? true;

      case SettingsData.DarkTheme:
        return prefs?.getBool('DarkTheme') ?? null;
      case SettingsData.UseEnglishNumbers:
        return prefs?.getBool('UseEnglishNumbers') ?? false;
    }
  }

  setSettings(SettingsData settingsData, dynamic data) {
    FirebaseAnalytics.instance.logEvent(name: 'settings_changed', parameters: {'settingsData': settingsData.toString(), 'data': data});
    switch (settingsData) {
      case SettingsData.OpenCalculatorOnStartup:
        return prefs?.setInt('OpenCalculatorOnStartup', data);

      case SettingsData.RoundPrices:
        return prefs?.setBool('RoundPrices', data);
      case SettingsData.DarkTheme:
        return prefs?.setBool('DarkTheme', data);
      case SettingsData.UseEnglishNumbers:
        return prefs?.setBool('UseEnglishNumbers', data);
    }
  }
}
