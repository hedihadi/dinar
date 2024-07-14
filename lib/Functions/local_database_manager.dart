import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dinar/Functions/models.dart';

class LocalDatabaseManager {
  static Future<LocalizationType> getLocalization() async {
    var box = await Hive.openBox('settings');
    final data = LocalizationType.values.byName(box.get('localization', defaultValue: LocalizationType.kurdish.name));
    return data;
  }

  static Future<List<Category>?> getCategories() async {
    var box = await Hive.openBox('database');
    final data = box.get('categories');
    if (data == null) return null;
    final parsedData = jsonDecode(data);
    List<Category> categories = [];
    for (final element in parsedData) {
      categories.add(Category.fromMap(element));
    }
    return categories;
  }
  
  static Future<void> saveCategories(List<Category> categories) async {
    final data = categories.map((e) => e.toMap()).toList();
    var box = await Hive.openBox('database');
    await box.put('categories', jsonEncode(data));
  }

  static Future<void> saveLocalization(LocalizationType localization) async {
    var box = await Hive.openBox('settings');
    await box.put('localization', localization.name);
  }

  static Future<dynamic> getSettingKey(String key) async {
    var box = await Hive.openBox('settings');
    return box.get(key);
  }

  static Future<void> saveSettingKey(String key, dynamic value) async {
    var box = await Hive.openBox('settings');
    await box.put(key, value);
  }
}
