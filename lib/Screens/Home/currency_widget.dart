import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinar/Functions/data.dart';
import 'package:dinar/Functions/models.dart';
import 'package:dinar/Functions/utils.dart';
import 'package:dinar/Providers/localization_provider.dart';
import 'package:dinar/Screens/add_notification.dart';
import 'package:dinar/Screens/chart.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/src/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:intl/intl.dart' as intll;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' as dartio;
import 'package:google_mobile_ads/google_mobile_ads.dart' as ad;
import 'package:function_tree/function_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sizer/sizer.dart';

class CurrencyWidget extends StatefulWidget {
  CurrencyWidget(this.currency, {this.last = false});
  Currency currency;
  bool last;
  @override
  State<CurrencyWidget> createState() => _CurrencyWidgetState();
}

class _CurrencyWidgetState extends State<CurrencyWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Container(
        decoration: BoxDecoration(
          color: HexColor("#202020"),
          borderRadius:
              BorderRadius.only(bottomRight: Radius.circular(widget.last ? 25.sp : 0), bottomLeft: Radius.circular(widget.last ? 25.sp : 0)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 20.sp,
                        child: CircleAvatar(
                          backgroundImage: AssetImage(widget.currency.flag),
                        ),
                      ),
                      Text("${widget.currency.baseAmount} ${widget.currency.suffix.localize(context)}",
                          style: TextStyle(color: widget.currency.color, fontSize: 10.sp, fontFamily: "uniqaidar"), textAlign: TextAlign.center),
                    ],
                  ),
                  Text(" ${timeago.format(widget.currency.prices[0].timestamp.toDate(), locale: context.read<LocalizationProvider>().language)}",
                      style: TextStyle(color: HexColor("#888888"), fontSize: 9.sp, fontFamily: "uniqaidar"), textAlign: TextAlign.center),
                ],
              ),
            ),
            Column(
              children: [
                Text("${widget.currency.prices[0].price.formatCurrency()} ${"Dinars".localize(context)}",
                    style: TextStyle(color: HexColor("#d6d6d6"), fontSize: 13.sp, fontFamily: "uniqaidar"), textAlign: TextAlign.center),
                widget.currency.prices[0].price == widget.currency.prices[1].price
                    ? Container()
                    : Text("${"before".localize(context)}: ${widget.currency.prices[1].price.formatCurrency()} ",
                        style: TextStyle(
                            color: widget.currency.prices[0].price - widget.currency.prices[1].price == 0
                                ? HexColor("#999999")
                                : widget.currency.prices[0].price - widget.currency.prices[1].price < 0
                                    ? Colors.green[400]
                                    : HexColor("#ff8f8f"),
                            fontSize: 8.sp,
                            fontFamily: "uniqaidar"),
                        textAlign: TextAlign.center),
              ],
            ),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                          "${(widget.currency.prices[0].price - widget.currency.prices[1].price).round().abs().formatCurrency()} ${"Dinars".localize(context)}",
                          style: TextStyle(
                              color: widget.currency.prices[0].price - widget.currency.prices[1].price == 0
                                  ? HexColor("#999999")
                                  : widget.currency.prices[0].price - widget.currency.prices[1].price < 0
                                      ? HexColor("#ff8f8f")
                                      : Colors.green[400],
                              fontSize: 12.sp,
                              fontFamily: "uniqaidar"),
                          textAlign: TextAlign.center),
                    ],
                  ),
                  Icon(
                    widget.currency.prices[0].price - widget.currency.prices[1].price == 0
                        ? Icons.remove
                        : widget.currency.prices[0].price - widget.currency.prices[1].price < 0
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                    color: widget.currency.prices[0].price - widget.currency.prices[1].price == 0
                        ? HexColor("#999999")
                        : widget.currency.prices[0].price - widget.currency.prices[1].price < 0
                            ? HexColor("#ff8f8f")
                            : Colors.green[400],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
