import 'dart:convert';

import 'package:dinar/Functions/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageManager {
  loadNotifications() async {
    List<Alarm> alarms = [];
    final prefs = await SharedPreferences.getInstance();
    final notifications_json = jsonDecode(prefs.getString("alarms") ?? "{}");
    for (var notification_json in notifications_json) {
      Alarm alarm = Alarm();
      alarm.parse(notification_json);
      alarms.add(alarm);
    }
    return alarms;
  }

  addNotification(Alarm alarm) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications_json = jsonDecode(prefs.getString("alarms") ?? "{}");
    notifications_json.add((alarm.toMap()));
    await prefs.setString("alarms", jsonEncode(notifications_json));
  }

  removeNotification(int id) async {
    List<Alarm> alarms = [];
    final prefs = await SharedPreferences.getInstance();
    final notifications_json = jsonDecode(prefs.getString("alarms") ?? "{}");
    for (var notification_json in notifications_json) {
      Alarm alarm = Alarm();
      alarm.parse(notification_json);
      alarms.add(alarm);
    }
    alarms.removeWhere((element) => element.id == id);
    notifications_json.clear();
    for (var alarm in alarms) {
      notifications_json.add(alarm.toMap());
    }
    await prefs.setString("alarms", jsonEncode(notifications_json));
  }
}
