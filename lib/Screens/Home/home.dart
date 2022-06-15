import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinar/Functions/data.dart';
import 'package:dinar/Functions/models.dart';
import 'package:dinar/Functions/utils.dart';
import 'package:dinar/Screens/Home/chart_widget.dart';
import 'package:dinar/Screens/Home/currency_row.dart';
import 'package:dinar/Screens/add_notification.dart';
import 'package:dinar/Screens/chart.dart';

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

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AdWidget? adWidget2;

  final ad.BannerAd banner2 = ad.BannerAd(
    adUnitId: 'ca-app-pub-3008670047597964/2494307335',
    size: ad.AdSize.largeBanner,
    request: ad.AdRequest(),
    listener: ad.BannerAdListener(),
  );
  @override
  void initState() {
    banner2.load();
    timeago.setLocaleMessages('kurdish', CustomEnglish());
    timeago.setLocaleMessages('ar', timeago.ArMessages());
    timeago.setLocaleMessages('arabic', timeago.ArMessages());
    adWidget2 = AdWidget(ad: banner2);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: 1.h),
        Container(
          padding: EdgeInsets.all(5.sp),
          decoration: BoxDecoration(
            color: HexColor("#131313"),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
            border: Border.all(
              width: 2.sp,
              color: HexColor("#222222"),
              style: BorderStyle.solid,
            ),
          ),
          child: ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              Padding(
                padding: EdgeInsets.all(5.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Currency Values".localize(context),
                        style: TextStyle(color: HexColor("#d9d9d9"), fontSize: 12.sp, fontFamily: "uniqaidar"), textAlign: TextAlign.center),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddNotification(currencies: GetIt.instance<Data>().currencies)),
                        );
                      },
                      child: CircleAvatar(
                        child: Icon(
                          Icons.alarm_add_outlined,
                          color: Colors.red[400],
                        ),
                        backgroundColor: HexColor("#252525"),
                      ),
                    ),
                  ],
                ),
              ),
              CurrencyRow(),
            ],
          ),
        ),
        SizedBox(height: 1.h),
        banner2.responseInfo == null
            ? Container()
            : SizedBox(width: banner2.size.width.toDouble(), height: banner2.size.height.toDouble(), child: adWidget2),
        ChartWidget(
          currencies: GetIt.instance<Data>().currencies,
        )
      ],
    );
  }
}
