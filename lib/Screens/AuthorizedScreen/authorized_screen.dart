import 'package:cached_network_image/cached_network_image.dart';
import 'package:dinar/Functions/local_database_manager.dart';
import 'package:dinar/Widgets/buy_premium_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:dinar/Functions/theme.dart';
import 'package:dinar/Screens/AuthorizedScreen/Widgets/item_widget.dart';
import 'package:dinar/Screens/AuthorizedScreen/authorized_screen_providers.dart';
import 'package:dinar/Screens/CalculatorScreen/calculator_screen.dart';
import 'package:dinar/Screens/DataScreen/data_screen.dart';
import 'package:dinar/Screens/MainScreen/main_screen.dart';
import 'package:dinar/Screens/MainScreen/main_screen_providers.dart';
import 'package:dinar/Screens/SettingScreen/setting_screen.dart';
import 'package:dinar/Widgets/future_provider_widget.dart';

final selectedBottomNavigationBarIndexProvider =
    StateProvider<int>((ref) => (ref.read(isFirstScreenCalculatorProvider).valueOrNull ?? false) ? 1 : 0);

final isFirstScreenCalculatorProvider = FutureProvider<bool>((ref) async {
  final data = (await LocalDatabaseManager.getSettingKey('isFirstScreenCalculator')) ?? false;

  return data;
});

class AuthorizedScreen extends ConsumerWidget {
  AuthorizedScreen({super.key});
  final List<Widget> widgets = [
    DataScreen(),
    CalculatorScreen(),
    const SettingScreen(),
  ];
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backend = ref.watch(backendProvider);
    if (backend.hasValue == false) {
      return FutureProviderWidget(provider: backendProvider);
    }
    final selectedBottomNavigationBarIndex = ref.watch(selectedBottomNavigationBarIndexProvider);

    return Scaffold(
      //backgroundColor: CustomColors().bg1,
      appBar: AppBar(
        actions: const [PremiumButton()],
      ),
      body: widgets[selectedBottomNavigationBarIndex],
      // body: ListView(
      //   children: [
      //     GridView.builder(
      //       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      //       physics: const NeverScrollableScrollPhysics(),
      //       shrinkWrap: true,
      //       itemCount: data[selectedCategory].items?.length,
      //       itemBuilder: (context, index) {
      //         final item = data[selectedCategory].items![index];
      //         return Card(
      //           color: CustomColors().bg2,
      //           shadowColor: Colors.transparent,
      //           child: Column(
      //             children: [
      //               CachedNetworkImage(
      //                 height: 7.h,
      //                 imageUrl: item.pictureUrl,
      //                 placeholder: (context, url) => const CircularProgressIndicator(),
      //                 errorWidget: (context, url, error) => const Icon(Icons.error),
      //               ),
      //               Text(
      //                 item.text,
      //                 style: Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.bold),
      //                 textAlign: TextAlign.center,
      //               ),
      //               const Spacer(),
      //               Text(
      //                 "${NumberFormat("#,###", "en_US").format(item.entries?.firstOrNull?.value ?? 0)} دینار",
      //                 style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
      //               ),
      //             ],
      //           ),
      //         );
      //       },
      //     ),
      //     Padding(
      //       padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      //       child: Text(
      //         data[selectedCategory].text,
      //         style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.primary),
      //       ),
      //     ),
      //     // ListView.builder(
      //     //   physics: const NeverScrollableScrollPhysics(),
      //     //   shrinkWrap: true,
      //     //   itemCount: data[selectedCategory].items?.length ?? 0,
      //     //   itemBuilder: (context, index) {
      //     //     return ItemWidget(item: data[selectedCategory].items![index]);
      //     //   },
      //     // ),
      //   ],
      // ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) => ref.read(selectedBottomNavigationBarIndexProvider.notifier).state = value,
        currentIndex: selectedBottomNavigationBarIndex,
        items: const [
          BottomNavigationBarItem(label: 'نرخەکان', icon: Icon(FontAwesomeIcons.chartPie)),
          BottomNavigationBarItem(label: 'هەژمێر', icon: Icon(FontAwesomeIcons.calculator)),
          BottomNavigationBarItem(label: 'ڕێکخستن', icon: Icon(FontAwesomeIcons.gear)),
        ],
      ),
    );
  }
}

class PremiumButton extends ConsumerWidget {
  const PremiumButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const BuyPremiumWidget()));
        },
        icon: const Icon(FontAwesomeIcons.crown));
  }
}
