/// Package import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinar/Functions/colors.dart';
import 'package:dinar/Functions/models.dart';
import 'package:dinar/Functions/utils.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import 'package:syncfusion_flutter_charts/charts.dart';

enum value { lowest, highest }

class Chart extends StatefulWidget {
  List<Price> Prices = [];
  String title = "";
  Chart(this.Prices, this.title);

  /// Creates the defaul spline chart Series.

  @override
  _SplineDefaultState createState() => _SplineDefaultState();
}

/// State class of the default spline chart.
class _SplineDefaultState extends State<Chart> {
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) {
      setState(() {
        widget.title = widget.title.localize(context);
      });
    });
  }

  List<Price> sortValues(value val) {
    List<Price> tempList = [];
    tempList.addAll(widget.Prices);
    ;
    if (val == value.highest) {
      tempList.sort((b, a) => a.price.compareTo(b.price));
      return tempList;
    }
    tempList.sort((a, b) => a.price.compareTo(b.price));
    return tempList;
  }

  @override
  Widget build(BuildContext context) {
    return _buildDefaultSplineChart();
  }

  /// Returns the defaul spline chart.
  SfCartesianChart _buildDefaultSplineChart() {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      //backgroundColor: Colors.white,
      title: ChartTitle(
          text: widget.title,
          textStyle: TextStyle(
            //color: mainTextColor2,
            fontFamily: "uniqaidar",
          )),
      enableAxisAnimation: true,
      primaryXAxis: CategoryAxis(majorGridLines: const MajorGridLines(width: 0), labelPlacement: LabelPlacement.betweenTicks),
      primaryYAxis: NumericAxis(
          minimum: sortValues(value.lowest)[0].price.toDouble() - 1000,
          maximum: sortValues(value.highest)[0].price.toDouble() + 1000,
          axisLine: AxisLine(width: 0),
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          labelFormat: ' {value} دینار',
          majorGridLines: const MajorGridLines(width: 0),
          labelStyle: TextStyle(
            fontFamily: "uniqaidar",
          ),
          majorTickLines: const MajorTickLines(size: 0)),
      series: _getDefaultSplineSeries(),
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }

  /// Returns the list of chart series which need to render on the spline chart.
  List<SplineSeries<Price, String>> _getDefaultSplineSeries() {
    return <SplineSeries<Price, String>>[
      SplineSeries<Price, String>(
        dataSource: widget.Prices.reversed.toList(),
        name: '',
        color: Colors.green,
        markerSettings: MarkerSettings(isVisible: false, color: Colors.white, height: 5.sp, width: 5.sp, shape: DataMarkerType.invertedTriangle),
        xValueMapper: (Price sales, _) => "${sales.timestamp.toDate().day.toString()}/${sales.timestamp.toDate().month.toString()}",
        xAxisName: "ww",
        yValueMapper: (Price sales, _) => sales.price,
      )
    ];
  }
}
