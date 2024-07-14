import 'dart:convert';
import 'dart:io';

import 'package:dinar/Screens/ItemScreen/item_screen.dart';
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

final itemProvider = FutureProvider.family<List<ItemEntry>, Item>((ref, item) async {
  final dateFrame = ref.watch(dateFrameProvider);
  final response = await ApiManager.getDataFromDatabase('items/${item.id}', queries: {'days': dateFrame});
  final parsedData = jsonDecode(response.body);
  List<ItemEntry> itemEntries = [];
  for (final element in parsedData) {
    itemEntries.add(ItemEntry.fromMap(element));
  }
  return itemEntries;
});
