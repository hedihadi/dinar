import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinar/Functions/models.dart';
import 'package:dinar/Functions/utils.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/src/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data.dart';

class DatabaseManager {
  BuildContext? build_context;
  Future<InitializeResponseType> initialize(BuildContext context) async {
    build_context = context;
    final prefs = await SharedPreferences.getInstance();

    ///check if user is connected to internet
    ///if not connected, then skip data requesting and instantly use local data
    var has_internet = await hasNetwork();
    if (has_internet == false) {
      //user has no internet, attempt to use local data
      if (prefs.containsKey("data")) {
        //we have local data, we can retrieve and use it
        final data = jsonDecode(prefs.getString("data")!);
        fetch_data(data);
        return InitializeResponseType.success_no_internet;
      } else {
        //we dont have local data and internet is not available either, show error
        return InitializeResponseType.no_internet;
      }
    }

    //we have internet connection, let's try to retrieve new data
    //first check if our local data is outdated
    if (prefs.containsKey("update")) {
      //we have the update variable
      //retrieve update variable from firebase and compare it to the local one
      //if they're different, then our local data is outdated
      final fb = FirebaseDatabase.instance.reference();

      final update_server = (await fb.child("update").get()).value;
      final update_local = prefs.getInt("update");
      final local_data = jsonDecode(prefs.getString("data") ?? "");
      if (update_local != update_server || local_data == null) {
        ///local data is outdated, update it
        Map<String, dynamic> local_data = {};
        local_data["britishprices"] = (await fb.child("britishprices").get()).value;
        local_data["europrices"] = (await fb.child("europrices").get()).value;
        local_data["iqdprices"] = (await fb.child("iqdprices").get()).value;
        local_data["tmanprices"] = (await fb.child("tmanprices").get()).value;
        local_data["turkishprices"] = (await fb.child("turkishprices").get()).value;
        //save the data
        prefs.setString("data", jsonEncode(local_data));
        //also update the update variable
        prefs.setInt("update", update_server);
        //now fetch data and return
        fetch_data(local_data);
        return InitializeResponseType.success;
      } else {
        //local data is up-to date, use it
        final data = jsonDecode(prefs.getString("data")!);
        fetch_data(data);
        return InitializeResponseType.success;
      }
    } else {
      //we dont have update variable, so just retrieve data from firebase
      Map<String, dynamic> local_data = {};
      final fb = FirebaseDatabase.instance.reference();

      final update_server = (await fb.child("update").get()).value;

      local_data["britishprices"] = (await fb.child("britishprices").get()).value;
      local_data["europrices"] = (await fb.child("europrices").get()).value;
      local_data["iqdprices"] = (await fb.child("iqdprices").get()).value;
      local_data["tmanprices"] = (await fb.child("tmanprices").get()).value;
      local_data["turkishprices"] = (await fb.child("turkishprices").get()).value;
      //save the data
      prefs.setString("data", jsonEncode(local_data));
      //also update the update variable
      prefs.setInt("update", update_server);
      //now fetch data and return
      fetch_data(local_data);
      return InitializeResponseType.success;
    }
  }

  void fetch_data(Map<String, dynamic> datas) {
    List<Price> prices = [];
    for (var element in (datas)["iqdprices"].entries) {
      Timestamp timestamp = Timestamp.fromMillisecondsSinceEpoch(int.parse(element.key));
      Price dollarValue = Price(timestamp, element.value.toDouble());
      prices.add(dollarValue);
    }
    prices.sort((b, a) => a.timestamp.compareTo(b.timestamp));
    //add the price list to currency
    Currency cu = Currency();
    cu.color = Colors.green[400]!;
    cu.flag = "assets/images/countries/us.webp";
    cu.name = "US Dollars";
    cu.suffix = "Dollars";
    cu.prices = prices;
    cu.baseAmount = "100";
    cu.databaseName = "iqdprices";
    cu.conversionFactor = 100;
    GetIt.instance<Data>().currencies.add(cu);
    //////////////////////////////////////////////
    //////////////////////////////////////////////
    prices = [];
    for (var element in (datas)["tmanprices"].entries) {
      Timestamp timestamp = Timestamp.fromMillisecondsSinceEpoch(int.parse(element.key));
      Price dollarValue = Price(timestamp, element.value.toDouble());
      prices.add(dollarValue);
    }
    prices.sort((b, a) => a.timestamp.compareTo(b.timestamp));
    cu = Currency();
    cu.color = Colors.yellow[400]!;
    cu.flag = "assets/images/countries/iran.png";
    cu.name = "Iranian Toman";
    cu.suffix = "Tomans";
    cu.prices = prices;
    cu.databaseName = "tmanprice";
    cu.baseAmount = "100,000";
    cu.conversionFactor = 100000;
    GetIt.instance<Data>().currencies.add(cu);
    //////////////////////////////////////////////
    //////////////////////////////////////////////
    prices = [];
    for (var element in (datas)["turkishprices"].entries) {
      Timestamp timestamp = Timestamp.fromMillisecondsSinceEpoch(int.parse(element.key));
      Price dollarValue = Price(timestamp, element.value.toDouble());
      prices.add(dollarValue);
    }
    prices.sort((b, a) => a.timestamp.compareTo(b.timestamp));
    cu = Currency();
    cu.color = Colors.red[200]!;
    cu.flag = "assets/images/countries/turkey.png";
    cu.name = "Turkish Lira";
    cu.suffix = "Liras";
    cu.prices = prices;
    cu.databaseName = "turkishprices";
    cu.baseAmount = "100";
    cu.conversionFactor = 100;
    GetIt.instance<Data>().currencies.add(cu);
    //////////////////////////////////////////////
    //////////////////////////////////////////////
    prices = [];
    for (var element in (datas)["europrices"].entries) {
      Timestamp timestamp = Timestamp.fromMillisecondsSinceEpoch(int.parse(element.key));
      Price dollarValue = Price(timestamp, element.value.toDouble());
      prices.add(dollarValue);
    }
    prices.sort((b, a) => a.timestamp.compareTo(b.timestamp));
    cu = Currency();
    cu.color = Colors.amber[400]!;
    cu.flag = "assets/images/countries/europe.png";
    cu.name = "Euro";
    cu.suffix = "Euros";
    cu.prices = prices;
    cu.baseAmount = "100";
    cu.databaseName = "europrices";
    cu.conversionFactor = 100;
    GetIt.instance<Data>().currencies.add(cu);
    //////////////////////////////////////////////
    //////////////////////////////////////////////
    prices = [];
    for (var element in (datas)["britishprices"].entries) {
      Timestamp timestamp = Timestamp.fromMillisecondsSinceEpoch(int.parse(element.key));
      Price dollarValue = Price(timestamp, element.value.toDouble());
      prices.add(dollarValue);
    }
    prices.sort((b, a) => a.timestamp.compareTo(b.timestamp));

    cu = Currency();
    cu.color = Colors.amber[400]!;
    cu.flag = "assets/images/countries/uk.webp";
    cu.name = "British Pound";
    cu.suffix = "Pounds";
    cu.prices = prices;
    cu.databaseName = "britishprices";
    cu.baseAmount = "100";
    cu.conversionFactor = 100;
    GetIt.instance<Data>().currencies.add(cu);
  }
}
