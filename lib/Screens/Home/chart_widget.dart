import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinar/Functions/models.dart';
import 'package:dinar/Functions/utils.dart';
import 'package:dinar/Screens/Home/chart.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:intl/intl.dart' as intll;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' as dartio;
import 'package:google_mobile_ads/google_mobile_ads.dart' as ad;
import 'package:function_tree/function_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sizer/sizer.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChartWidget extends StatefulWidget {
  List<Currency> currencies = [];
  ChartWidget({this.currencies = const [], Key? key}) : super(key: key);

  @override
  _ChartManagerState createState() => _ChartManagerState();
}

class _ChartManagerState extends State<ChartWidget> {
  late Currency selectedCurrency;
  bool loaded = false;
  @override
  void initState() {
    super.initState();

    initialize();
  }

  Future<void> initialize() async {
    final instance = await SharedPreferences.getInstance();
    if (instance.containsKey("selectedchart")) {
      final oldSelected = instance.getString("selectedchart");
      for (var currency in widget.currencies) {
        if (currency.name == oldSelected!) {
          selectedCurrency = currency;
        }
      }
    } else {
      selectedCurrency = widget.currencies[0];
    }
    setState(() {
      loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return loaded == false
        ? Container()
        : Container(
            padding: EdgeInsets.all(2.sp),
            decoration: BoxDecoration(
              color: HexColor("#131313"),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              border: Border.all(
                width: 2.sp,
                color: HexColor("#222222"),
                style: BorderStyle.solid,
              ),
            ),
            child: ListView(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                Center(
                  child: DropdownButton<Currency>(
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
                          child: Row(
                            children: [
                              SizedBox(
                                height: 20.sp,
                                child: CircleAvatar(
                                  backgroundImage: AssetImage(e.flag),
                                ),
                              ),
                              SizedBox(width: 2.sp),
                              Text(
                                e.suffix.localize(context),
                                style: TextStyle(color: HexColor("#999999"), fontSize: 12.sp),
                              ),
                            ],
                          ),
                        );
                      }).toList()),
                ),
                Chart(selectedCurrency.prices,
                    "${"Value of".localize(context)} ${selectedCurrency.suffix.localize(context)} ${"in the last 30 days".localize(context)}"),
              ],
            ));
  }
}
