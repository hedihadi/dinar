import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinar/Functions/data.dart';
import 'package:dinar/Functions/models.dart';
import 'package:dinar/Functions/utils.dart';
import 'package:dinar/Screens/Home/currency_widget.dart';
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
import 'package:google_mobile_ads/google_mobile_ads.dart' as ad;

class CurrencyRow extends StatefulWidget {
  const CurrencyRow({Key? key}) : super(key: key);
  @override
  State<CurrencyRow> createState() => _CurrencyRowState();
}

class _CurrencyRowState extends State<CurrencyRow> {
  AdWidget? ad_widget;
  final ad.BannerAd banner = ad.BannerAd(
    adUnitId: 'ca-app-pub-3008670047597964/1366457297',
    size: ad.AdSize.banner,
    request: ad.AdRequest(),
    listener: ad.BannerAdListener(),
  );
  @override
  void initState() {
    super.initState();
    banner.load();
    ad_widget = AdWidget(ad: banner);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: GetIt.instance<Data>().currencies.length,
      itemBuilder: (context, index) {
        //we hardcode tman
        //   if(widget.currencies[index].flag=="assets/images/countries/iran.png"){
        //    return CurrencyRow(
        //   widget.currencies[index].suffix!,
        //   widget.currencies[index].flag!,
        //  widget.currencies[index].prices!.reversed.elementAt(0).price,
        // widget.currencies[index].prices!.reversed.elementAt(1).price,
        // widget.currencies[index].prices!.reversed.elementAt(0).timestamp,
        //  widget.currencies[index].prices!.reversed.elementAt(1).timestamp,
        // widget.currencies[index].baseAmount!,
        //
        //  widget.currencies[index].color!,
        //  suffix: "تمەن"
        //  );
        //   }
        return CurrencyWidget(GetIt.instance<Data>().currencies[index], last: index == (GetIt.instance<Data>().currencies.length - 1));
      },
      separatorBuilder: (context, index) {
        if (index == 0 && banner.responseInfo != null) {
          return SizedBox(width: banner.size.width.toDouble(), height: banner.size.height.toDouble(), child: ad_widget);
        }
        return Container();
      },
    );
  }
}
