import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:dinar/Functions/theme.dart';
import 'package:dinar/Functions/utils.dart';
import 'package:dinar/Screens/ItemScreen/item_screen_providers.dart';
import 'package:dinar/Screens/MainScreen/main_screen.dart';
import 'package:dinar/Screens/MainScreen/main_screen_providers.dart';
import 'package:dinar/main.dart';
import '../../../Functions/models.dart';
import 'package:collection/collection.dart';

final dateFrameProvider = StateProvider<int>((ref) => 30);

class ItemScreen extends ConsumerWidget {
  const ItemScreen({super.key, required this.item});
  final Item item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(itemProvider(item));

    return items.when(
        data: (data) {
          //the item entry with the highest and lowest value
          final highestEntry = data.reduce((current, next) => current.value > next.value ? current : next);
          final lowestEntry = data.reduce((current, next) => current.value < next.value ? current : next);
          double lowestEntryValue = lowestEntry.value.toDouble();
          double highestEntryValue = highestEntry.value.toDouble();

          final List<ChartData> chartData = data.map<ChartData>((e) => ChartData(e.createdAt, e.value.toDouble())).toList();
          return Directionality(
            textDirection: ref.watch(directionalityProvider),
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  item.text,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ListView(
                  children: [
                    SizedBox(height: 2.h),
                    SizedBox(height: 2.h),
                    Card(
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'نرخی ${item.valueFactor.round().toPrice()} ${item.unitName} لە ${dateFrameEntries.firstWhere((e) => e['days'] == ref.watch(dateFrameProvider))['display']}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const DateDropdown(),
                          Text(
                            'لە ${dateFrameEntries.firstWhere((e) => e['days'] == ref.watch(dateFrameProvider))['display']} بەرزترین نرخ ${highestEntry.value.toPrice()} بووە لە بەرواری ${DateFormat("yyyy-MM-dd").format(highestEntry.createdAt)}،',
                            style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Theme.of(context).colorScheme.tertiary),
                            textAlign: TextAlign.start,
                          ),
                          Text(
                            'وە نزم ترین نرخیش ${lowestEntry.value.toPrice()} بووە لە بەرواری ${DateFormat("yyyy-MM-dd").format(lowestEntry.createdAt)}.',
                            style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Theme.of(context).colorScheme.tertiary),
                            textAlign: TextAlign.start,
                          ),
                          SfCartesianChart(
                            plotAreaBorderWidth: 0,
                            tooltipBehavior: TooltipBehavior(
                              color: Theme.of(context).appBarTheme.backgroundColor,
                              enable: true,
                              builder: (data, point, series, pointIndex, seriesIndex) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("بەروار: ${DateFormat('yyyy-MM-dd').format((point.x as DateTime))}"),
                                    Text("نرخ: ${(point.y as double).toPrice()} دینار"),
                                  ],
                                );
                              },
                            ),
                            primaryYAxis: NumericAxis(
                                //interval: 250,
                                minimum: lowestEntryValue - (lowestEntryValue * 0.01),
                                maximum: highestEntryValue + (highestEntryValue * 0.01),
                                maximumLabels: 2,
                                labelStyle: Theme.of(context).textTheme.labelSmall!.copyWith(color: Theme.of(context).colorScheme.primary),
                                labelFormat: '{value}',
                                numberFormat: NumberFormat("#,###", "en_US"),
                                axisLine: const AxisLine(width: 0),
                                majorTickLines: const MajorTickLines(color: Colors.transparent)),
                            primaryXAxis: DateTimeAxis(
                                labelStyle: Theme.of(context).textTheme.labelSmall!.copyWith(color: Theme.of(context).colorScheme.primary),
                                maximumLabels: 5,
                                dateFormat: DateFormat.Md(),
                                majorGridLines: const MajorGridLines(width: 0),
                                majorTickLines: MajorTickLines(
                                  color: Theme.of(context).colorScheme.secondary,
                                )),
                            series: <CartesianSeries>[
                              // Renders line chart
                              LineSeries<ChartData, DateTime>(
                                  color: Theme.of(context).colorScheme.secondary,
                                  markerSettings: const MarkerSettings(isVisible: true),
                                  dataSource: chartData,
                                  xValueMapper: (ChartData sales, _) => sales.date,
                                  yValueMapper: (ChartData sales, _) => sales.value),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        error: (error, stackTrace) {
          print(error);
          print(stackTrace);
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text("$error"),
            ),
          );
        },
        loading: () => const LoadingScreen());
  }
}

class DateDropdown extends ConsumerWidget {
  const DateDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFrame = ref.watch(dateFrameProvider);

    return Card(
      elevation: 15,
      shadowColor: Colors.transparent,
      child: DropdownButton<int>(
        elevation: 50,
        value: dateFrame,
        underline: Container(),
        onChanged: (int? value) {
          if (value == null) return;
          ref.read(dateFrameProvider.notifier).state = value;
        },
        items: dateFrameEntries.map<DropdownMenuItem<int>>((e) {
          return DropdownMenuItem<int>(
            value: e['days'] as int,
            child: Text(e['text'] as String),
          );
        }).toList(),
      ),
    );
  }
}
