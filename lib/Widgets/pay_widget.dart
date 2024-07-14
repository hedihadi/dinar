import 'package:dinar/Functions/api_manager.dart';
import 'package:dinar/Functions/models.dart';
import 'package:dinar/Functions/utils.dart';
import 'package:dinar/Screens/MainScreen/main_screen_providers.dart';
import 'package:dinar/Widgets/buy_premium_widget.dart';
import 'package:dinar/Widgets/send_money_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

final mobileNumberProvider = StateProvider<String?>((ref) => null);

final isLoadingProvider = StateProvider<bool>((ref) => false);

class PayWidget extends ConsumerWidget {
  PayWidget({super.key});
  final maskFormatter = MaskTextInputFormatter(mask: '#### ### ## ##', filter: {"#": RegExp(r'[0-9]')}, type: MaskAutoCompletionType.lazy);
  final TextEditingController phoneController = TextEditingController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider);
    return Directionality(
      textDirection: ref.watch(directionalityProvider),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("ژمارە تەلەفۆنەکەت"),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 3.h),
              Text(
                "پێش ناردنی پارەکە، تکایە ژمارەی تەلەفۆنەکەت بنووسە کە پارەکەتی پێ دەنێریت",
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(hintText: '0770 234 21 98'),
                  inputFormatters: [maskFormatter],
                ),
              ),
              SizedBox(height: 2.h),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        ref.read(isLoadingProvider.notifier).state = true;
                        final number = maskFormatter.getMaskedText();
                        ref.read(mobileNumberProvider.notifier).state = number;
                        final revenuecatId = await Purchases.appUserID;
                        await ApiManager.sendDataToDatabase('user-mobile', data: {'mobile': number, 'revenuecat_id': revenuecatId});
                        ref.read(isLoadingProvider.notifier).state = false;
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => SendMoneyWidget()));
                      },
                      child: const Text("پاشەکەوتی بکە")),
            ],
          ),
        ),
      ),
    );
  }
}
