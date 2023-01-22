import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NoLocalDataException implements Exception {}

class NoInternetException implements Exception {}

//this error will be thrown when user tries to get new data from database but user's data is already up-to--date
class NoNewDataException implements Exception {}

enum AppState { Loading, NoInternet, Loaded }

enum SettingsData { OpenCalculatorOnStartup, RoundPrices, DarkTheme, UseEnglishNumbers }

class Currency {
  ///[name] is the main name of the currency,
  ///for example "british pounds" is a [name]
  late String name;

  ///[databaseName] is the name of the currency that we use in our database
  late String databaseName;

  ///the asset name of this currency's flag
  late String flag;

  ///[suffix] is used when we're showing values, for example
  ///if we show how much 5000 dinars, dinars here is the [suffix]
  late String suffix;

  ///[prices] has the price of this currency for each day,
  ///the first entry is the current value of the currency.
  late List<Price> prices;

  ///a distinguishable color that we use to personalize each currency
  late Color color;

  ///the below variable is used to determine how much of that currency
  ///we should use, for example if [baseAmount] is $100
  ///that means we write [price]=$100
  late String baseAmount;

  ///below variable is used in calculatorscreen, we basically
  ///multiply the dinar value with the below variable to
  ///calculate a currency to one another.
  late double conversionFactor;
}

class Price {
  Price(this.timestamp, this.price);
  Timestamp timestamp;
  double price;
}
