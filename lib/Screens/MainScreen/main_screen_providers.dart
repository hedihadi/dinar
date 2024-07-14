import 'dart:convert';
import 'dart:io';

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
import 'package:dinar/Functions/local_database_manager.dart';
import 'package:dinar/Functions/models.dart';
import 'package:dinar/Functions/theme.dart';
import 'package:flutter/services.dart' show rootBundle;

class LocalizationNotifier extends AsyncNotifier<LocalizationType> {
  Map<String, dynamic> localizationData = {};
  @override
  Future<LocalizationType> build() async {
    final localization = await LocalDatabaseManager.getLocalization();

    //load the localization data from the file
    String data = await rootBundle.loadString('assets/localization.json');
    localizationData = Map<String, dynamic>.from(jsonDecode(data));

    return localization;
  }

  String translate(String text) {
    if (localizationData.keys.contains(text)) {
      if (state.hasValue == true) {
        {
          return localizationData[text]![state.asData!.value.name]!;
        }
      }
    }
    return text;
  }
}

final localizationProvider = AsyncNotifierProvider<LocalizationNotifier, LocalizationType>(() {
  return LocalizationNotifier();
});

final authProvider = FutureProvider<User>((ref) async {
  final sub = FirebaseAuth.instance.authStateChanges().listen((user) async {
    if (user == null) {
      final newUser = await FirebaseAuth.instance.signInAnonymously();
      ref.state = AsyncData(newUser.user!);
    } else {
      ref.state = AsyncData(user);
    }
  });
  ref.onDispose(() => sub.cancel());
  return ref.future;
});

final directionalityProvider = StateProvider<TextDirection>((ref) =>
    (ref.watch(localizationProvider).valueOrNull ?? LocalizationType.kurdish) == LocalizationType.english ? TextDirection.ltr : TextDirection.rtl);

class IsUserPremiumNotifier extends StateNotifier<bool> {
  bool didSendUserData = false;
  IsUserPremiumNotifier() : super(true) {
    checkUserForSubscriptions();
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      checkUserForSubscriptions();
    });
  }
  checkUserForSubscriptions() {
    Purchases.getCustomerInfo().then((value) async {
      if (value.entitlements.active.isNotEmpty) {
        state = true;
      } else {
        state = false;
      }
    });
  }
}

final isUserPremiumProvider = StateNotifierProvider<IsUserPremiumNotifier, bool>((ref) {
  return IsUserPremiumNotifier();
});
