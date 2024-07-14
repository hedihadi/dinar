import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:dinar/Functions/theme.dart';
import 'package:dinar/Functions/utils.dart';
import 'package:dinar/Screens/ItemScreen/item_screen.dart';
import '../../../Functions/models.dart';
import 'package:collection/collection.dart';

class ItemWidget extends ConsumerWidget {
  const ItemWidget({super.key, required this.item});
  final Item item;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.h),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ItemScreen(item: item))),
        child: Card(
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0), // Set corner radius to 0
          ),
          // color: CustomColors().bg2,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CachedNetworkImage(
                      height: 5.h,
                      imageUrl: item.pictureUrl,
                      placeholder: (context, url) => Container(),
                      errorWidget: (context, url, error) => Container(),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.text,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Row(
                      children: [
                        if ((item.entries?.length ?? 0) >= 2)
                          Column(
                            children: [
                              Icon(
                                item.entries![0].value == item.entries![1].value
                                    ? FontAwesomeIcons.equals
                                    : item.entries![0].value < item.entries![1].value
                                        ? FontAwesomeIcons.chevronDown
                                        : FontAwesomeIcons.chevronUp,
                                color: item.entries![0].value == item.entries![1].value
                                    ? Theme.of(context).colorScheme.tertiary
                                    : item.entries![0].value < item.entries![1].value
                                        ? Colors.red[300]
                                        : Colors.green[300],
                                size: 2.h,
                              ),
                              const Text(""),
                            ],
                          ),
                        const SizedBox(width: 3),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${(item.entries?.firstOrNull?.value ?? 0).toPrice()} دینار",
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: Theme.of(context).colorScheme.secondary,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            if ((item.entries?.length ?? 0) >= 2)
                              Text(
                                "دوێنێ: ${(item.entries?[1].value ?? 0).toPrice()} دینار",
                                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                      color: Theme.of(context).colorScheme.tertiary,
                                      fontSize: 8.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                if (item.entries?.isNotEmpty ?? false)
                  Text(
                    timeago.format(item.entries!.first.createdAt, locale: 'ku'),
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(color: HexColor("#73B4C7")),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
