import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinar/Functions/data.dart';
import 'package:dinar/Functions/models.dart';
import 'package:dinar/Functions/utils.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
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

class CalculatorScreen extends StatefulWidget {
  CalculatorScreen({
    Key? key,
  }) : super(key: key);

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  Currency selectedCurrency = Currency();
  TextEditingController amountController = TextEditingController(text: "5000");
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
          child: Container(
            color: HexColor("#000000"),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(5.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      dinarToCurrency ? Expanded(flex: 3, child: DinarDropdown()) : Expanded(flex: 3, child: CurrencyDropdown()),
                      IconButton(
                        onPressed: () async {
                          setState(() {
                            dinarToCurrency = !dinarToCurrency;
                            calculate("");
                          });
                          await FirebaseAnalytics.instance.logEvent(name: 'swap_currencies', parameters: {
                            "org": GetIt.instance<Data>().org,
                            "region": GetIt.instance<Data>().region,
                            "ip": GetIt.instance<Data>().ip,
                            "country": GetIt.instance<Data>().country,
                          });
                        },
                        icon: Icon(Icons.compare_arrows, color: Colors.white),
                      ),
                      !dinarToCurrency ? Expanded(flex: 3, child: DinarDropdown()) : Expanded(flex: 3, child: CurrencyDropdown()),
                    ],
                  ),
                ),
                Text(
                  dinarToCurrency
                      ? "${"Dinars to".localize(context)} ${selectedCurrency.name.localize(context)}"
                      : "${selectedCurrency.name.localize(context)} ${"to Dinars".localize(context)}",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: HexColor("#999999"), fontSize: 9.sp, fontFamily: "uniqaidar"),
                ),
                FittedBox(
                  fit: BoxFit.fitHeight,
                  child: IntrinsicWidth(
                    child: TextField(
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 35.sp, color: HexColor("#999999")),
                        autofocus: true,
                        controller: amountController,
                        showCursor: true,
                        readOnly: true),
                  ),
                ),
                SizedBox(height: 1.h),
                Container(
                  color: HexColor("#191919"),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Row(
                              children: [
                                Text("${selectedCurrency.baseAmount} ${selectedCurrency.suffix.localize(context)}",
                                    style: TextStyle(fontSize: 10.sp, color: selectedCurrency.color)),
                                Text("=${selectedCurrency.prices[0].price.round().formatCurrency()} ${"Dinars".localize(context)}",
                                    style: TextStyle(fontSize: 10.sp, color: Colors.grey[400])),

                                //Text(
                                //    "${intll.NumberFormat("#,###").format(widget.usdPrice)} ${('دینار').localize(language)}",
                                //    style: TextStyle(
                                //        fontSize: 10.sp,
                                //        color: Colors.grey[400])),
                              ],
                            ),
                          ])),
                      Align(alignment: Alignment.center, child: Text(fetchResultText(), style: TextStyle(fontSize: 17.sp, color: Colors.red[400]))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: GridView.count(
              //childAspectRatio: 1.2,
              childAspectRatio: 0.9,

              shrinkWrap: true,
              // Create a grid with 2 columns. If you change the scrollDirection to
              // horizontal, this produces 2 rows.
              crossAxisCount: 4,
              // Generate 100 widgets that display their index in the List.
              children: List.generate(16, (index) {
                return Padding(
                  padding: EdgeInsets.all(2.sp),
                  child: Container(
                      decoration: BoxDecoration(color: HexColor("#141414"), border: Border.all(color: Colors.black)), child: digitsWidget[index]),
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
    selectedCurrency = GetIt.instance<Data>().currencies[0];
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
    FirebaseAnalytics.instance.logEvent(name: 'calculate', parameters: {
      'currency': selectedCurrency.name,
      "org": GetIt.instance<Data>().org,
      "region": GetIt.instance<Data>().region,
      "ip": GetIt.instance<Data>().ip,
      "country": GetIt.instance<Data>().country,
    });
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
      decoration: BoxDecoration(color: HexColor("#191919"), borderRadius: BorderRadius.circular(10)),
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
                  style: TextStyle(color: HexColor("#999999"), fontSize: 14.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget CurrencyDropdown() {
    return Container(
      decoration: BoxDecoration(color: HexColor("#191919"), borderRadius: BorderRadius.circular(10)),
      child: DropdownButton<Currency>(
          value: selectedCurrency,
          onChanged: (newCurrency) {
            setState(() {
              selectedCurrency = newCurrency!;
            });
            calculate("");
          },
          underline: Container(),
          items: GetIt.instance<Data>().currencies.map((e) {
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
                    style: TextStyle(color: HexColor("#999999"), fontSize: 10.sp),
                  ),
                ],
              ),
            );
          }).toList()),
    );
  }

  TextStyle buttonsTextStyle = TextStyle(fontSize: 40, color: Colors.white);
}
