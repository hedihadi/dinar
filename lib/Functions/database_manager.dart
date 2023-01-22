import 'dart:convert';

import 'package:dinar/Functions/models.dart';
import 'package:dinar/Functions/utils.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseManager {
  Future<List<Currency>> getLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('data')) {
      var data = Map<String, dynamic>.from(jsonDecode(prefs.getString('data')!));
      return parseData(data);
    }

    //we don't have data, return null
    throw new NoLocalDataException();
  }

  Future<List<Currency>> getDataFromDatabase() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var hasInternet = await hasNetwork();
    if (hasInternet) {
      //user has internet, let's get data from firebase
      final firebase = FirebaseDatabase.instance.reference();

      final updateServer = (await firebase.child("update").get()).value;
      final updateLocal = prefs.getInt("update") ?? 0;
      //if updateServer != updateLocal, that means new data is available on the database.
      if (updateLocal != updateServer) {
        Map<String, dynamic> data = {};
        data["britishprices"] = (await firebase.child("britishprices").get()).value;
        data["europrices"] = (await firebase.child("europrices").get()).value;
        data["iqdprices"] = (await firebase.child("iqdprices").get()).value;
        data["tmanprices"] = (await firebase.child("tmanprices").get()).value;
        data["turkishprices"] = (await firebase.child("turkishprices").get()).value;
        //save the new data
        prefs.setString("data", jsonEncode(data));
        prefs.setInt("update", int.parse(updateServer.toString()));

        return parseData(data);
      }
      //user is up-to-date, throw exception.
      throw new NoNewDataException();
    }
    //user has no internet, throw exception
    throw new NoInternetException();
  }
}
