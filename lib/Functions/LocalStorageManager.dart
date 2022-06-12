import 'dart:convert';

import 'package:RustCompanion/utils/models.dart';
import 'package:RustCompanion/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ApiManager.dart';

class LocalStorageManager {
  Future<List<NotificationModel>> load_notifications() async {
    final prefs = await SharedPreferences.getInstance();
    List<NotificationModel> notifications = [];
    List<Map<String, dynamic>> _notifications_raw = [];
    _notifications_raw = List<Map<String, dynamic>>.from(jsonDecode(prefs.getString("notifications") ?? "[]"));
    for (var notification_raw in _notifications_raw) {
      NotificationModel notification = NotificationModel((notification_raw["notification_type"] as String).toNotificationType());
      notification.notification_type = (notification_raw["notification_type"] as String).toNotificationType();
      notification.id = notification_raw["id"];
      notification.enabled = notification_raw["enabled"];
      notification.session_id = notification_raw["session_id"];
      if (notification_raw.containsKey("server_id")) {
        notification.server = await ApiManager().getServerInfo(notification_raw["server_id"]);
        notification.server_last_wipe = DateTime.fromMillisecondsSinceEpoch(notification_raw["server_last_wipe"]);
      }
      if (notification_raw.containsKey("player_id")) {
        notification.player = await ApiManager().getPlayerInfo(notification_raw["player_id"]);
        notification.player_last_online = DateTime.fromMillisecondsSinceEpoch(notification_raw["player_last_online"]);
      }

      notifications.add(notification);
    }
    return notifications;
  }

  Future<void> save_notifications(List<NotificationModel> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    String a = jsonEncode(notifications.map((e) => e.toJson()).toList());
    await prefs.setString("notifications", a);
  }

  Future<bool> is_guide_disabled(int id) async {
    final prefs = await SharedPreferences.getInstance();
    List<int> disabled_guides = [];
    disabled_guides = List<int>.from(jsonDecode(prefs.getString("disabled_guides") ?? "[]"));
    if (disabled_guides.contains(id)) {
      return true;
    } else {
      return false;
    }
  }
  Future<bool> is_collect_data_enabled()async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("collect_data") ?? true;
  }
  Future<void> disable_guide(int id) async {
    final prefs = await SharedPreferences.getInstance();
    List<int> disabled_guides = [];
    disabled_guides = List<int>.from(jsonDecode(prefs.getString("disabled_guides") ?? "[]"));
    if (disabled_guides.contains(id) == false) {
      disabled_guides.add(id);
      await prefs.setString("disabled_guides", jsonEncode(disabled_guides));
    }
  }
}
