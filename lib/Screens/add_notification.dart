import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinar/Functions/local_storage_manager.dart';
import 'package:dinar/Functions/models.dart';
import 'package:dinar/Functions/utils.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart' as intll;
import 'package:http/http.dart' as http;

import 'package:path_provider/path_provider.dart';
import 'dart:io' as dartio;
import 'package:google_mobile_ads/google_mobile_ads.dart' as ad;
import 'package:function_tree/function_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class AddNotification extends StatefulWidget {
  List<Currency> currencies = [];
  AddNotification({Key? key, required this.currencies}) : super(key: key);

  @override
  _NotifyScreenState createState() => _NotifyScreenState();
}

class _NotifyScreenState extends State<AddNotification> {
  late Currency selectedCurrency;
  TextEditingController textController = TextEditingController();
  double amount = 0;
  bool disabled = true;
  bool up = false;
  List<Alarm> alarms = [];
  RewardedAd? ad;

  @override
  void initState() {
    RewardedAd.load(
        request: AdRequest(),
        adUnitId: 'ca-app-pub-3008670047597964/9806122461',
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            this.ad = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
          },
        ));
    selectedCurrency = widget.currencies.first;
    amount = widget.currencies.first.prices[0].price;
    textController.addListener(() {
      setState(() {
        try {
          amount = double.parse(textController.text);
          amount > selectedCurrency.prices[0].price ? up = true : up = false;
        } on Exception catch (c) {
          print(c);
          amount = 0;
        }
        if (amount == selectedCurrency.prices[0].price || amount == 0) {
          disabled = true;
        } else {
          disabled = false;
        }
      });
    });
    FirebaseMessaging.instance.getToken().then((token) async {
      final fb = FirebaseFirestore.instance;
      final collection = await fb.collection("notifications").doc(token).collection("notifications").get();
      alarms = await LocalStorageManager().loadNotifications();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: calculateTextDirection(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Add Event".localize(context)),
          backgroundColor: HexColor("#252525"),
        ),
        backgroundColor: HexColor("#000000"),
        body: ListView(
          shrinkWrap: true,
          children: [
            Container(
              color: HexColor("#151515"),
              child: ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                        color: HexColor("#191919"),
                        child: DropdownButton<Currency>(
                            dropdownColor: HexColor("#151515"),
                            value: selectedCurrency,
                            onChanged: (newCurrency) {
                              setState(() {
                                selectedCurrency = newCurrency!;
                              });
                            },
                            underline: Container(),
                            items: widget.currencies.map((e) {
                              return DropdownMenuItem<Currency>(
                                alignment: Alignment.center,
                                value: e,
                                child: Container(
                                  color: HexColor("#151515"),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 5.sp),
                                      Text(
                                        e.suffix.localize(context),
                                        style: TextStyle(color: HexColor("#d9d9d9d9"), fontSize: 20.sp),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList()),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("${selectedCurrency.baseAmount} ${selectedCurrency.suffix.localize(context)} ",
                          style: TextStyle(color: selectedCurrency.color, fontSize: 10.sp, fontFamily: "uniqaidar"), textAlign: TextAlign.center),
                      Text("= ${selectedCurrency.prices[0].price.round().formatCurrency()} ${"Dinars".localize(context)}",
                          style: TextStyle(color: HexColor("#d8d8d8d8"), fontSize: 10.sp, fontFamily: "uniqaidar"), textAlign: TextAlign.center),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: TextField(
                      style: TextStyle(color: Colors.grey[600], fontSize: 20.sp, letterSpacing: 2.sp),
                      textAlign: TextAlign.center,
                      controller: textController,
                      decoration: InputDecoration(
                          icon: Icon(
                              disabled == false
                                  ? (amount > selectedCurrency.prices[0].price ? Icons.arrow_upward : Icons.arrow_downward)
                                  : Icons.remove,
                              color: disabled == false
                                  ? (amount > selectedCurrency.prices[0].price ? Colors.green[400] : Colors.red[400])
                                  : Colors.grey),
                          hintText: "Write a value".localize(context),
                          hintStyle: TextStyle(
                            color: HexColor("#888888"),
                            fontSize: 10.sp,
                          ),
                          fillColor: HexColor("#191919"),
                          filled: true),
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                      disabled
                          ? ""
                          : "${"when value of ".localize(context)} ${selectedCurrency.suffix.localize(context)} ${" becomes ".localize(context)} ${amount.formatCurrency()} ${"Dinars".localize(context)} ${up ? "or lower".localize(context) : "higher".localize(context)} ${"you'll be notified".localize(context)}",
                      style: TextStyle(color: HexColor("#999999"), fontSize: 9.sp, fontFamily: "uniqaidar"),
                      textAlign: TextAlign.center),
                  Padding(
                    padding: EdgeInsets.all(10.sp),
                    child: ElevatedButton(
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(0),
                          backgroundColor: MaterialStateProperty.all(disabled ? HexColor("#303030") : Colors.blue[800])),
                      onPressed: () async {
                        //SharedPreferences prefs =
                        //    await SharedPreferences.getInstance();
                        //Map<String, List> alarms = {};
                        //if (prefs.containsKey("alarms")) {
                        //  alarms =
                        //      Map.from(jsonDecode(prefs.getString('alarms')!));
                        //}
                        //alarms[selectedCurrency.name!] = [
                        //  amount,
                        //  amount > selectedCurrency.price! ? "up" : "down",
                        //  selectedCurrency.databaseName
                        //];
                        //print(alarms);
                        //await prefs.setString("alarms", jsonEncode(alarms));
                        //setState(() {
                        //  alarms = alarms;
                        //});
                        ad?.show(onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) async {
                              insertNotification();
                            }) ??
                            insertNotification();
                      },
                      child: Text("Add".localize(context),
                          style: TextStyle(color: HexColor("#d8d8d8d8"), fontSize: 10.sp, fontFamily: "uniqaidar"), textAlign: TextAlign.center),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Container(
              color: HexColor("#151515"),
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: alarms.length,
                  itemBuilder: (context, index) {
                    final style = TextStyle(color: HexColor("#d8d8d8d8"), fontSize: 10.sp, fontFamily: "uniqaidar");
                    return Padding(
                      padding: EdgeInsets.fromLTRB(2.w, 0, 2.w, 2.h),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: RichText(
                              text: TextSpan(
                                text: "when value of ".localize(context),
                                style: style,
                                children: <TextSpan>[
                                  TextSpan(text: " ${alarms[index].name.localize(context)}", style: style.copyWith(color: Colors.red[400])),
                                  TextSpan(text: " becomes ".localize(context), style: style),
                                  TextSpan(text: alarms[index].price.formatCurrency(), style: style.copyWith(color: Colors.red[400])),
                                  TextSpan(
                                      text:
                                          " ${alarms[index].type == 'down' ? 'or lower'.localize(context) : 'higher'.localize(context)} ${"you'll be notified".localize(context)} ",
                                      style: style),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                                child: Icon(Icons.remove_circle, color: Colors.red[400]),
                                onTap: () async {
                                  LocalStorageManager().removeNotification(alarms[index].id);
                                  setState(() {
                                    alarms.remove(alarms[index]);
                                  });
                                }),
                          )
                        ],
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }

  insertNotification() async {
    Alarm al = Alarm();
    al.name = selectedCurrency.name;
    al.databasename = selectedCurrency.databaseName;
    al.price = amount;
    al.type = amount > selectedCurrency.prices[0].price ? "up" : "down";
    al.id = Random().nextInt(999999999);
    alarms.add(al);
    await LocalStorageManager().addNotification(al);
    setState(() {});
    FirebaseAnalytics.instance.logEvent(name: 'setup_notify', parameters: {'currency': selectedCurrency.databaseName});
  }
}
