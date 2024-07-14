import 'package:dinar/Functions/models.dart';
import 'package:dinar/Functions/utils.dart';
import 'package:dinar/Screens/MainScreen/main_screen_providers.dart';
import 'package:dinar/Widgets/buy_premium_widget.dart';
import 'package:dinar/Widgets/pay_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

final paymentMethodProvider = StateProvider<PaymentMethod?>((ref) => null);

class SelectPaymentMethodWidget extends ConsumerWidget {
  const SelectPaymentMethodWidget({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Directionality(
      textDirection: ref.watch(directionalityProvider),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("جۆری پارەدان"),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 3.h),
              Text(
                "بە چ ڕێگایەک دەتەوێت پارە بدەیت؟",
                style: Theme.of(context).textTheme.titleSmall,
              ),
              SizedBox(height: 2.h),
              Center(
                child: ElevatedButton(
                    style: ButtonStyle(
                      padding: const MaterialStatePropertyAll(EdgeInsets.zero),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0))),
                    ),
                    onPressed: () async {
                      ref.read(paymentMethodProvider.notifier).state = PaymentMethod.asiacell;
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  PayWidget()));
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[HexColor("#ffc196"), HexColor("#ff7295")],
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(80.0)),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                          child: Text(
                            "باڵانسی ئاسیاسێڵ",
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).scaffoldBackgroundColor),
                          )),
                    )),
              ),
              SizedBox(height: 1.h),
              Center(
                child: ElevatedButton(
                    style: ButtonStyle(
                      padding: const MaterialStatePropertyAll(EdgeInsets.zero),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0))),
                    ),
                    onPressed: () async {
                      ref.read(paymentMethodProvider.notifier).state = PaymentMethod.korek;
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  PayWidget()));
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[HexColor("#ffc196"), HexColor("#ff7295")],
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(80.0)),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                          child: Text(
                            "باڵانسی کۆڕەک",
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).scaffoldBackgroundColor),
                          )),
                    )),
              ),
              SizedBox(height: 1.h),
              Center(
                child: ElevatedButton(
                    style: ButtonStyle(
                      padding: const MaterialStatePropertyAll(EdgeInsets.zero),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0))),
                    ),
                    onPressed: () async {
                      ref.read(paymentMethodProvider.notifier).state = PaymentMethod.fastpay;
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  PayWidget()));
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[HexColor("#ffc196"), HexColor("#ff7295")],
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(80.0)),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                          child: Text(
                            "فاستپەی",
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).scaffoldBackgroundColor),
                          )),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
