import 'dart:convert';
import 'dart:ffi';

import 'package:dinar/Functions/database_manager.dart';
import 'package:dinar/Functions/get_it.dart';
import 'package:dinar/Functions/models.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;

class DataProvider with ChangeNotifier {
  List<Currency> data = [];
  AppState appState = AppState.Loading;

  DataProvider() {
    getData();
  }

  setData(_data) {
    data = _data;
    appState = AppState.Loaded;
    notifyListeners();
  }

  Future<void> getData() async {
    List<Currency>? _data;
    try {
      _data = await DatabaseManager().getLocalData();
      setData(_data);
      retrieveDatabaseData(true);
    } on NoLocalDataException {
      retrieveDatabaseData(false);
    }
  }

  retrieveDatabaseData(bool localDataAvailable) async {
    List<Currency>? _data;

    try {
      _data = await DatabaseManager().getDataFromDatabase();
      setData(_data);
    } on NoInternetException {
      if (localDataAvailable == false) {
        appState = AppState.NoInternet;
        notifyListeners();
      }
    } on NoNewDataException {
      appState = AppState.Loaded;
      notifyListeners();
    }
  }
}
