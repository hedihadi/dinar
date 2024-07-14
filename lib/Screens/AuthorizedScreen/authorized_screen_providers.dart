import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dinar/Screens/CalculatorScreen/calculator_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dinar/Functions/api_manager.dart';
import 'package:dinar/Functions/local_database_manager.dart';
import 'package:dinar/Functions/models.dart';
import 'package:dinar/Functions/theme.dart';
import 'package:flutter/services.dart' show rootBundle;

class LocalizationNotifier extends AsyncNotifier<List<Category>> {
  bool isCalculationItemSet = false;
  Future<List<Category>> getNetworkData() async {
    final response = await ApiManager.getDataFromDatabase('items');
    final parsedData = jsonDecode(response.body);
    List<Category> categories = [];
    for (final element in parsedData) {
      categories.add(Category.fromMap(element));
    }

    return categories;
  }

  Future<List<Category>?> getLocalData() async {
    final data = await LocalDatabaseManager.getCategories();

    return data;
  }

  @override
  Future<List<Category>> build() async {
    final localData = await getLocalData();
    if (localData != null) {
      updateDataFromNetwork();
      return localData;
    }
    final networkData = await getNetworkData();
    LocalDatabaseManager.saveCategories(networkData);
    return networkData;
  }

  Future<void> updateDataFromNetwork() async {
    getItems();
    final data = await getNetworkData();
    LocalDatabaseManager.saveCategories(data);
    state = AsyncData(data);
  }

  List<Item> getItems() {
    List<Item> items = [];
    if (state.hasValue) {
      for (final category in state.value!) {
        items.addAll(category.items ?? []);
      }
    }

    if (isCalculationItemSet == false) {
      LocalDatabaseManager.getSettingKey('calculation_item_id').then((value) {
        if (value != null) {
          final item = items.firstWhereOrNull((element) => element.id == value);
          if (item != null) {
            ref.read(selectedItemProvider.notifier).state = item;
          }
        }
      });
      isCalculationItemSet = true;
    }
    return items;
  }
}

final backendProvider = AsyncNotifierProvider<LocalizationNotifier, List<Category>>(() {
  return LocalizationNotifier();
});
