import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinar/Functions/colors.dart';
import 'package:dinar/Functions/models.dart';
import 'package:dinar/Functions/utils.dart';
import 'package:dinar/Providers/data_provider.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart' as intll;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' as dartio;
import 'package:google_mobile_ads/google_mobile_ads.dart' as ad;
import 'package:function_tree/function_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sizer/sizer.dart';
import 'package:timeago/timeago.dart' as timeago;

class CalculatorScreen extends StatefulWidget {
  CalculatorScreen({
    Key? key,
  }) : super(key: key);

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  Currency selectedCurrency = Currency();
  TextEditingController amountController = TextEditingController(text: "0");
  String equationResult = '';
  String result = '';
  bool dinarToCurrency = true;
  FocusNode focusNode = FocusNode();
  TextEditingController dollarValueController = TextEditingController();
  List<Widget> digitsWidget = [];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(5.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    dinarToCurrency ? Expanded(flex: 3, child: DinarDropdown()) : Expanded(flex: 3, child: CurrencyDropdown(context)),
                    IconButton(
                      onPressed: () async {
                        setState(() {
                          dinarToCurrency = !dinarToCurrency;
                          calculate("");
                        });
                      },
                      icon: Icon(Icons.compare_arrows),
                    ),
                    !dinarToCurrency ? Expanded(flex: 3, child: DinarDropdown()) : Expanded(flex: 3, child: CurrencyDropdown(context)),
                  ],
                ),
              ),
              Text(
                dinarToCurrency
                    ? "${"Dinars to".localize(context)} ${selectedCurrency.name.localize(context)}"
                    : "${selectedCurrency.name.localize(context)} ${"to Dinars".localize(context)}",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              IntrinsicWidth(
                child: TextField(
                    onChanged: (value) => setState(() {
                          amountController.text = localizePrice(value, context);
                        }),
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.headlineLarge,
                    autofocus: true,
                    controller: amountController,
                    showCursor: true,
                    readOnly: true),
              ),
              SizedBox(height: 1.h),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Padding(
                            padding: EdgeInsets.only(right: 1.w),
                            child: Row(
                              children: [
                                Text("${localizePrice(selectedCurrency.baseAmount, context)} ${selectedCurrency.suffix.localize(context)}",
                                    style: Theme.of(context).textTheme.bodyMedium),
                                Text(
                                    "=${localizePrice(selectedCurrency.prices[0].price.round().formatCurrency(), context)} ${"Dinars".localize(context)}",
                                    style: Theme.of(context).textTheme.bodyMedium),

                                //Text(
                                //    "${intll.NumberFormat("#,###").format(widget.usdPrice)} ${('دینار').localize(language)}",
                                //    style: TextStyle(
                                //        fontSize: 10.sp,
                                //        color: Colors.grey[400])),
                              ],
                            ),
                          ),
                        ])),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 0.5.h),
                        child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              localizePrice(fetchResultText(), context),
                              style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: GridView.count(
              //childAspectRatio: 1.2,
              childAspectRatio: 1,

              shrinkWrap: true,
              // Create a grid with 2 columns. If you change the scrollDirection to
              // horizontal, this produces 2 rows.
              crossAxisCount: 4,
              // Generate 100 widgets that display their index in the List.
              children: List.generate(16, (index) {
                return Padding(
                  padding: EdgeInsets.all(2.sp),
                  child: Container(child: digitsWidget[index]),
                );
              }),
            ),
          ),
        ),
        //Container(
        //  height: 123,
        //  color: Colors.green,
        //),
      ],
    );
  }

  String fetchResultText() {
    if (dinarToCurrency) {
      return "$result ${selectedCurrency.suffix.localize(context)} $equationResult ${"Dinars".localize(context)}";
    } else {
      return "$result ${"Dinars".localize(context)}  $equationResult ${selectedCurrency.suffix.localize(context)}";
    }
  }

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('kurdish', CustomEnglish());
    timeago.setLocaleMessages('ar', timeago.ArMessages());
    timeago.setLocaleMessages('arabic', timeago.ArMessages());

    focusNode.addListener(() {
      fetchText();
    });
    selectedCurrency = Provider.of<DataProvider>(context, listen: false).data[0];
    initialize();
    calculate("");
    digitsWidget = [
      TextButton(
          onPressed: () {
            calculate("7");
          },
          child: Text(
            "7",
            style: buttonsTextStyle,
          )),
      TextButton(
          onPressed: () {
            calculate("8");
          },
          child: Text(
            "8",
            style: buttonsTextStyle,
          )),
      TextButton(
          onPressed: () {
            calculate("9");
          },
          child: Text(
            "9",
            style: buttonsTextStyle,
          )),
      TextButton(
          onPressed: () {
            calculate("÷");
          },
          child: Text("÷", style: buttonsTextStyle.copyWith(color: Colors.amber[800]))),
      TextButton(
          onPressed: () {
            calculate("4");
          },
          child: Text(
            "4",
            style: buttonsTextStyle,
          )),
      TextButton(
          onPressed: () {
            calculate("5");
          },
          child: Text(
            "5",
            style: buttonsTextStyle,
          )),
      TextButton(
          onPressed: () {
            calculate("6");
          },
          child: Text(
            "6",
            style: buttonsTextStyle,
          )),
      TextButton(
          onPressed: () {
            calculate("×");
          },
          child: Text(
            "×",
            style: buttonsTextStyle.copyWith(color: Colors.amber[800]),
          )),
      TextButton(
          onPressed: () {
            calculate("1");
          },
          child: Text(
            "1",
            style: buttonsTextStyle,
          )),
      TextButton(
          onPressed: () {
            calculate("2");
          },
          child: Text(
            "2",
            style: buttonsTextStyle,
          )),
      TextButton(
          onPressed: () {
            calculate("3");
          },
          child: Text(
            "3",
            style: buttonsTextStyle,
          )),
      TextButton(
          onPressed: () {
            calculate("-");
          },
          child: Text(
            "-",
            style: buttonsTextStyle.copyWith(color: Colors.amber[800]),
          )),
      TextButton(
          onPressed: () {
            calculate(".");
          },
          child: Text(
            ".",
            style: buttonsTextStyle,
          )),
      TextButton(
          onPressed: () {
            calculate("0");
          },
          child: Text(
            "0",
            style: buttonsTextStyle,
          )),
      TextButton(
        onPressed: () {
          calculate("(");
        },
        onLongPress: () {
          calculate("((");
        },
        child: Icon(Icons.backspace, color: Colors.redAccent[400]),
      ),
      TextButton(
          onPressed: () {
            calculate("+");
          },
          child: Text(
            "+",
            style: buttonsTextStyle.copyWith(color: Colors.amber[800]),
          )),
    ];
  }

  Future<void> initialize() async {
    final instance = await SharedPreferences.getInstance();

    setState(() {});
  }

  void fetchText() {
    final formatCurrency = intll.NumberFormat("#,##0.##");
    String str = amountController.text;

    if (str == "") {
      str = "0";
    }
    str = str.replaceAll(",", "");
    String temporary = "";
    final strings = str.split("");
    str = "";
    for (String ss in strings) {
      if (ss == "*" || ss == "-" || ss == "+" || ss == "/") {
        if (temporary != "") {
          str = "$str${formatCurrency.format(double.parse(temporary)).toString()}";
        }
        str = str + ss;
        temporary = "";
      } else {
        temporary = temporary + ss;
      }
    }
    if (temporary != "") {
      str = "$str${formatCurrency.format(double.parse(temporary)).toString()}";
    }
    amountController.text = str;
  }

  void calculate(String string) {
    if (string == "((") {
      setState(() {
        amountController.text = "";
        equationResult = "";
        result = "0";
      });
      return;
    }
    if (string == "(") {
      setState(() {
        amountController.text = amountController.text.substring(0, amountController.text.length - 1);
      });
      string = "";
    }
    final formatCurrency = intll.NumberFormat("#,##0.##");
    String str = amountController.text + string;
    if (str == "") {
      str = "0";
    }
    if (string == ".") {
      amountController.text = str;
      return;
    }
    str = str.replaceAll(",", "");
    String temporary = "";
    final strings = str.split("");
    str = "";
    for (String ss in strings) {
      if (ss == "×" || ss == "-" || ss == "+" || ss == "÷") {
        if (temporary != "") {
          str = "$str${formatCurrency.format(double.parse(temporary)).toString()}";
        }
        str = str + ss;
        temporary = "";
      } else {
        temporary = temporary + ss;
      }
    }
    if (temporary != "") {
      str = "$str${formatCurrency.format(double.parse(temporary)).toString()}";
    }
    amountController.text = str;
    str = str.replaceAll(",", "");
    str = str.replaceAll("×", "*");
    str = str.replaceAll("÷", "/");
    str = str.interpret().toString();
    double doubleResult = double.parse(str);
    setState(() {
      equationResult = "= " + formatCurrency.format(doubleResult).toString();
    });

    if (dinarToCurrency == true) {
      doubleResult = doubleResult * (selectedCurrency.conversionFactor / selectedCurrency.prices[0].price);
    } else {
      doubleResult = doubleResult * (selectedCurrency.prices[0].price / selectedCurrency.conversionFactor);
    }
    setState(() {
      String strResult = doubleResult.toStringAsFixed(2);
      final formatCurrency = intll.NumberFormat("#,##0.##");
      result = formatCurrency.format(double.parse(strResult));
    });
  }

  Widget DinarDropdown() {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: DropdownButton(
        onChanged: (a) {},
        underline: SizedBox(),
        value: "",
        icon: Container(),
        items: [
          DropdownMenuItem(
            alignment: Alignment.center,
            value: "",
            child: Row(
              children: [
                SizedBox(
                  height: 20.sp,
                  child: CircleAvatar(
                    backgroundImage: AssetImage('assets/images/countries/iraq.png'),
                  ),
                ),
                SizedBox(width: 2.sp),
                Text(
                  "Dinars".localize(context),
                  style: TextStyle(fontSize: 14.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget CurrencyDropdown(context) {
    return Container(
      decoration: BoxDecoration(),
      child: DropdownButton<Currency>(
          dropdownColor: Theme.of(context).scaffoldBackgroundColor,
          value: selectedCurrency,
          onChanged: (newCurrency) {
            setState(() {
              selectedCurrency = newCurrency!;
            });
            calculate("");
          },
          underline: Container(),
          items: Provider.of<DataProvider>(context).data.map((e) {
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
                    e.name.localize(context),
                    style: TextStyle(fontSize: 10.sp),
                  ),
                ],
              ),
            );
          }).toList()),
    );
  }

  TextStyle buttonsTextStyle = TextStyle(fontSize: 40);
}
