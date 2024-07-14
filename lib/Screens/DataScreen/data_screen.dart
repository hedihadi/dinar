import 'package:cached_network_image/cached_network_image.dart';
import 'package:dinar/Widgets/inline_ad.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sizer/sizer.dart';
import 'package:dinar/Functions/theme.dart';
import 'package:dinar/Functions/utils.dart';
import 'package:dinar/Screens/AuthorizedScreen/Widgets/item_widget.dart';
import 'package:dinar/Screens/AuthorizedScreen/authorized_screen_providers.dart';
import 'package:dinar/Screens/MainScreen/main_screen.dart';
import 'package:dinar/Screens/MainScreen/main_screen_providers.dart';
import 'package:dinar/Widgets/future_provider_widget.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../Functions/models.dart';

final selectedCategoryProvider = StateProvider<int>((ref) => 0);

class DataScreen extends ConsumerWidget {
  DataScreen({super.key});
  final RefreshController refreshController = RefreshController(initialRefresh: false);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backend = ref.watch(backendProvider);
    final categories = backend.value!;
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return DefaultTabController(
      length: categories.length,
      child: SmartRefresher(
        enablePullDown: true,
        header: const WaterDropMaterialHeader(),
        controller: refreshController,
        onRefresh: () async {
          final val = await ref.refresh(backendProvider.future);
          refreshController.refreshCompleted();
        },
        child: ListView(
          shrinkWrap: true,
          children: [
            Container(
              color: Theme.of(context).appBarTheme.backgroundColor,
              child: TabBar(
                onTap: (value) => ref.read(selectedCategoryProvider.notifier).state = value,
                tabs: categories
                    .map<Tab>(
                      (e) => e.id == 1
                          ? const Tab(icon: Icon(FontAwesomeIcons.lemon))
                          : e.id == 2
                              ? const Tab(icon: Icon(FontAwesomeIcons.gem))
                              : e.id == 3
                                  ? const Tab(child: Icon(FontAwesomeIcons.dollarSign))
                                  : e.id == 4
                                      ? const Tab(child: Icon(FontAwesomeIcons.gasPump))
                                      : Tab(
                                          icon: CachedNetworkImage(
                                            imageUrl: e.pictureUrl,
                                            placeholder: (context, url) => Container(),
                                            errorWidget: (context, url, error) => Container(),
                                          ),
                                        ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 15),
            if (DateTime.now().weekday == DateTime.friday)
              Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                    child: Text(
                      'بازاڕ داخراوە (ڕۆژی هەینیە)',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.tertiary),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              child: Center(
                child: Text(
                  categories[selectedCategory].text,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
            // GridView.builder(
            //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            //   physics: const NeverScrollableScrollPhysics(),
            //   shrinkWrap: true,
            //   itemCount: categories[selectedCategory].items?.length,
            //   itemBuilder: (context, index) {
            //     final item = categories[selectedCategory].items![index];
            //     return Card(
            //       color: CustomColors().bg2,
            //       shadowColor: Colors.transparent,
            //       child: Column(
            //         children: [
            //           Text(
            //             item.text,
            //             style: Theme.of(context).textTheme.labelSmall!.copyWith(
            //                   fontWeight: FontWeight.bold,
            //                   fontSize: 7.sp,
            //                   color: CustomColors().bg3,
            //                 ),
            //             textAlign: TextAlign.center,
            //           ),
            //           Expanded(
            //             child: CachedNetworkImage(
            //               imageUrl: item.pictureUrl,
            //               placeholder: (context, url) => const CircularProgressIndicator(),
            //               errorWidget: (context, url, error) => const Icon(Icons.error),
            //             ),
            //           ),
            //           Text(
            //             "${NumberFormat("#,###", "en_US").format(item.entries?.firstOrNull?.value ?? 0)} دینار",
            //             style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
            //           ),
            //           Row(
            //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //             children: [
            //               if (item.entries?.isNotEmpty ?? false)
            //                 Text(
            //                   timeago.format(item.entries!.first.createdAt, locale: 'ku'),
            //                   style: Theme.of(context).textTheme.labelSmall!.copyWith(
            //                         color: CustomColors().bg3,
            //                         fontSize: 7.sp,
            //                       ),
            //                 ),
            //               if ((item.entries?.length ?? 0) >= 2)
            //                 Text(
            //                   "پێشتر: ${NumberFormat("#,###", "en_US").format(item.entries?[1].value ?? 0)} دینار",
            //                   style: Theme.of(context).textTheme.titleMedium!.copyWith(
            //                         fontSize: 8.sp,
            //                         fontWeight: FontWeight.bold,
            //                         color: HexColor("#6a994e"),
            //                       ),
            //                 ),
            //             ],
            //           ),
            //         ],
            //       ),
            //     );
            //   },
            // ),

            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: categories[selectedCategory].items?.length ?? 0,
              itemBuilder: (context, index) {
                return ItemWidget(item: categories[selectedCategory].items![index]);
              },
              separatorBuilder: (context, index) {
                if (index == 1) {
                  return const InlineAd(adUnit: 'ca-app-pub-5545344389727160/7108731923');
                }
                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }
}
