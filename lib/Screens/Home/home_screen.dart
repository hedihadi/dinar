import 'package:dinar/Functions/utils.dart';
import 'package:dinar/Screens/Home/currency_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sizer/sizer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: calculateTextDirection(context),
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 1.w),
          child: ListView(
            children: [
              CurrencyList(),
            ],
          )),
    );
  }
}
