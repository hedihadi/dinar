import 'package:dinar/Functions/models.dart';
import 'package:dinar/Functions/utils.dart';
import 'package:dinar/Screens/MainScreen/main_screen_providers.dart';
import 'package:dinar/Widgets/select_payment_method_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sizer/sizer.dart';

import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

final premiumTypeProvider = StateProvider<PremiumType?>((ref) => null);

final timerProvider = StreamProvider<int>((ref) {
  final stopwatch = Stopwatch()..start();
  return Stream.periodic(const Duration(milliseconds: 1000), (count) {
    return stopwatch.elapsed.inSeconds;
  });
});

final customerInfoProvider = FutureProvider((ref) async {
  ref.watch(isUserPremiumProvider);
  ref.watch(timerProvider);
  final customerInfo = await Purchases.getCustomerInfo();
  return customerInfo;
});

class BuyPremiumWidget extends ConsumerWidget {
  const BuyPremiumWidget({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerInfo = ref.watch(customerInfoProvider);
    final isUserPremium = ref.watch(isUserPremiumProvider);
    return Directionality(
      textDirection: ref.watch(directionalityProvider),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("ببە ئەندام"),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 3.h),
              Center(
                child: Text(
                  isUserPremium ? "تۆ پلانت هەیە!" : "پلانێک بکڕە",
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 23.sp, fontFamily: "roboto", fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 3.h),
              isUserPremium
                  ? Center(
                      child: Text("ئەندامێتیت تەواو دەبێت دوای ${timeago.format(
                        DateTime.parse("${customerInfo.valueOrNull!.allExpirationDates.entries.lastOrNull?.value}"),
                        locale: 'ku',
                        allowFromNow: true,
                      )}"),
                    )
                  : const BenefitsWidget(),
              const Spacer(),
              const RestorePurchasesButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class BenefitsWidget extends ConsumerWidget {
  const BenefitsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "بە کڕینی پلانێک",
          style: Theme.of(context).textTheme.titleSmall,
        ),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          children: const [
            BenefitCard(text: "ڕیکلامە بێزارکەرەکان بسڕەوە"),
            // BenefitCard(text: "better charts (coming soon)"),
            BenefitCard(text: "پشتگیری  ئەپلیکەیشنەکە بکە"),
          ],
        ),
        ElevatedButton(
            style: ButtonStyle(
              padding: const MaterialStatePropertyAll(EdgeInsets.zero),
              shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0))),
            ),
            onPressed: () async {
              ref.read(premiumTypeProvider.notifier).state = PremiumType.threeMonths;
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SelectPaymentMethodWidget()));
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
                child: Row(
                  children: [
                    SizedBox(width: 7.w),
                    Icon(FontAwesomeIcons.crown, size: 5.h),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "سێ مانگ",
                                style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).scaffoldBackgroundColor),
                              ),
                              Text(
                                "3,000 دینار",
                                style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).scaffoldBackgroundColor),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "",
                                style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Theme.of(context).scaffoldBackgroundColor),
                              ),
                              Text(
                                "",
                                style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Theme.of(context).scaffoldBackgroundColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 5.w),
                  ],
                ),
              ),
            )),
        SizedBox(height: 1.h),
        ElevatedButton(
            style: ButtonStyle(
              padding: const MaterialStatePropertyAll(EdgeInsets.zero),
              shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0))),
            ),
            onPressed: () async {
              ref.read(premiumTypeProvider.notifier).state = PremiumType.sixMonths;
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SelectPaymentMethodWidget()));
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
                child: Row(
                  children: [
                    SizedBox(width: 7.w),
                    Icon(FontAwesomeIcons.crown, size: 5.h),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "شەش مانگ",
                                style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).scaffoldBackgroundColor),
                              ),
                              Text(
                                "5,000 دینار",
                                style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).scaffoldBackgroundColor),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "",
                                style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Theme.of(context).scaffoldBackgroundColor),
                              ),
                              Text(
                                "هەزار دینار کەمتر!",
                                style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Theme.of(context).scaffoldBackgroundColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 5.w),
                  ],
                ),
              ),
            )),
        SizedBox(height: 1.h),
        ElevatedButton(
            style: ButtonStyle(
              padding: const MaterialStatePropertyAll(EdgeInsets.zero),
              shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0))),
            ),
            onPressed: () async {
              ref.read(premiumTypeProvider.notifier).state = PremiumType.oneYear;
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SelectPaymentMethodWidget()));
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
                child: Row(
                  children: [
                    SizedBox(width: 7.w),
                    Icon(FontAwesomeIcons.crown, size: 5.h),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "یەک ساڵ",
                                style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).scaffoldBackgroundColor),
                              ),
                              Text(
                                "9,000 دینار",
                                style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).scaffoldBackgroundColor),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "",
                                style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Theme.of(context).scaffoldBackgroundColor),
                              ),
                              Text(
                                "سێ هەزار دینار کەمتر!",
                                style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Theme.of(context).scaffoldBackgroundColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 5.w),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class BenefitCard extends ConsumerWidget {
  const BenefitCard({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: Theme.of(context).colorScheme.onPrimary,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

final isrestorePurchaseFirstRunProvider = AutoDisposeStateProvider<bool>((ref) {
  return true;
});
final restorePurchaseProvider = FutureProvider.autoDispose<bool>((ref) async {
  if (ref.read(isrestorePurchaseFirstRunProvider) == true) {
    await Future.delayed(const Duration(milliseconds: 500), () {
      ref.read(isrestorePurchaseFirstRunProvider.notifier).state = false;
    });

    return true;
  }
  await Future.delayed(const Duration(seconds: 5));
  await Purchases.restorePurchases();
  return true;
});

class RestorePurchasesButton extends ConsumerWidget {
  const RestorePurchasesButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restorePurchases = ref.watch(restorePurchaseProvider);
    return ElevatedButton(
      onPressed: () {
        ref.invalidate(restorePurchaseProvider);
      },
      child: restorePurchases.when(
        skipLoadingOnRefresh: false,
        data: (data) => restorePurchases.isLoading ? const CircularProgressIndicator() : const Text("Restore Purchases"),
        error: (error, stackTrace) => Text(error.toString(), maxLines: 5),
        loading: () => const CircularProgressIndicator(),
      ),
    );
  }
}
