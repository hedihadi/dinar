import 'dart:io';

import 'package:dinar/Functions/colors.dart';
import 'package:dinar/Functions/utils.dart';
import 'package:dinar/Providers/data_provider.dart';
import 'package:dinar/Providers/localization_provider.dart';
import 'package:dinar/Screens/Home/inline_ad.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:timeago/timeago.dart' as timeago;

class CurrencyList extends StatefulWidget {
  const CurrencyList({Key? key}) : super(key: key);

  @override
  State<CurrencyList> createState() => _CurrencyCardsState();
}

class _CurrencyCardsState extends State<CurrencyList> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, value, child) {
        return Theme(
          data: Theme.of(context).copyWith(
              textTheme: Theme.of(context)
                  .textTheme
                  .apply(
                    bodyColor: Colors.white,
                    displayColor: Colors.white,
                  )
                  .copyWith(bodySmall: TextStyle(color: Colors.blueGrey[100]))),
          child: ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: value.data.length,
            itemBuilder: (context, index) {
              final currency = value.data[index];
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 1.h),
                child: Card(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 2.5.h, horizontal: 4.w),
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
                                    height: 35.sp,
                                    child: CircleAvatar(
                                      backgroundImage: AssetImage(currency.flag),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 2.w),
                                    child: Text(
                                      "${localizePrice(currency.baseAmount, context)} ${currency.suffix.localize(context)}",
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                " ${localizePrice(timeago.format(currency.prices[0].timestamp.toDate(), locale: context.read<LocalizationProvider>().language), context)}",
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.start,
                              )
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              "${localizePrice(currency.prices[0].price.formatCurrency(), context)} ${"Dinars".localize(context)}",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            currency.prices[0].price == currency.prices[1].price
                                ? Container()
                                : Text("${"before".localize(context)}: ${localizePrice(currency.prices[1].price.formatCurrency(), context)} ",
                                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                          color: currency.prices[0].price - currency.prices[1].price == 0
                                              ? Theme.of(context).textTheme.bodySmall!.color
                                              : currency.prices[0].price - currency.prices[1].price < 0
                                                  ? Theme.of(context).success
                                                  : Theme.of(context).error,
                                        ),
                                    textAlign: TextAlign.center),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) {
              if (index == 0) {
                return InlineAd();
              }
              return Container();
            },
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
