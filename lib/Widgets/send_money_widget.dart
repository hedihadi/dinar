import 'package:dinar/Functions/api_manager.dart';
import 'package:dinar/Functions/models.dart';
import 'package:dinar/Functions/utils.dart';
import 'package:dinar/Screens/MainScreen/main_screen_providers.dart';
import 'package:dinar/Widgets/buy_premium_widget.dart';
import 'package:dinar/Widgets/select_payment_method_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SendMoneyWidget extends ConsumerWidget {
  SendMoneyWidget({super.key});
  final maskFormatter = MaskTextInputFormatter(mask: '#### ### ## ##', filter: {"#": RegExp(r'[0-9]')}, type: MaskAutoCompletionType.lazy);
  final TextEditingController phoneController = TextEditingController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final price = ref.watch(premiumTypeProvider);
    final paymentMethod = ref.watch(paymentMethodProvider);
    String? numberToCall;
    switch (paymentMethod) {
      case PaymentMethod.asiacell:
        numberToCall = "*123*${price?.getPrice()}*07712035599#";
        break;
      case PaymentMethod.korek:
        numberToCall = "*215*07511288911*${price?.getPrice()}#";
        break;
      case null:
        break;
      case PaymentMethod.fastpay:
        break;
    }
    return Directionality(
      textDirection: ref.watch(directionalityProvider),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("پارەکە بنێرە"),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 3.h),
              if (numberToCall != null)
                Center(
                  child: Text(
                    "بۆ ناردنی پارەکە، پەیوەندی بەم ژمارەیەوە بکە:-",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              if (numberToCall != null)
                Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          numberToCall,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                  ),
                ),
              if (paymentMethod == PaymentMethod.fastpay)
                Center(
                  child: Text(
                    "تکایە لە فاستپەی بڕی ${price?.getPrice()} بنێرە بۆ ئەم ژمارەیەی خوارەوە",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              if (paymentMethod == PaymentMethod.fastpay)
                Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          "0751 128 89 11",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                  ),
                ),
              if (numberToCall != null)
                Center(
                  child: Text(
                    "یان پەنجە بە دوگمەکەی خوارەوە بنێ",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              if (numberToCall != null)
                ElevatedButton(
                    onPressed: () {
                      launchUrlString("tel:${Uri.encodeComponent(numberToCall!)}");
                    },
                    child: const Text("ژمارەکە بکەوە")),
              const Divider(),
              Center(
                child: Text(
                  "دوای ناردنی پارەکە، لەماوەی ٢٤ کاتژمێر هەژمارەکەت دەبێتە ئەندام!",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
