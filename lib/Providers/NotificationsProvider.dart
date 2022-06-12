import 'dart:convert';
import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:RustCompanion/Functions/ApiManager.dart';
import 'package:RustCompanion/Functions/LocalStorageManager.dart';
import 'package:RustCompanion/utils/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;
  add(NotificationModel notification) async {
    ///generate a random int for the new notification
    ///and then check if that id is already exists,
    ///if yes, regenerate a new id and assign to the object.
    ///so every notification will have a unique id.
    List<int> notifications = _notifications.map((e) => e.id!).toList();
    while (true) {
      int new_generated_id = Random().nextInt(99999);
      if (notifications.contains(new_generated_id) == false) {
        notification.id = new_generated_id;
        break;
      }
    }
    _notifications.add(notification);
    notifyListeners();
    LocalStorageManager().save_notifications(_notifications);

    if (await LocalStorageManager().is_collect_data_enabled()) {
      await FirebaseAnalytics.instance.logEvent(
        name: "notification_added",
        parameters: {
          "type": "${notification.notification_type.toString()}",
        },
      );
    }
  }

  set(List<NotificationModel> notifications) {
    _notifications = notifications;
    notifyListeners();
  }

  remove(int id) async {
    _notifications.removeWhere((element) => element.id == id);
    notifyListeners();
    LocalStorageManager().save_notifications(_notifications);
  }
}
