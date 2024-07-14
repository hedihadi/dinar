import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:dinar/Functions/models.dart';
import 'package:dinar/Functions/theme.dart';

final DateTime now = DateTime.now();
final DateTime startOfYear = DateTime(now.year, 1, 1);
final int daysSinceStartOfYear = now.difference(startOfYear).inDays;

final dateFrameEntries = [
  {
    'text': '30 ڕۆژ',
    'display': '30 ڕۆژی ڕابردوودا',
    'days': 30,
  },
  {
    'text': '7 ڕۆژ',
    'display': '7 ڕۆژی ڕابردوودا',
    'days': 7,
  },
  {
    'text': 'ئەمساڵ',
    'display': 'ئەمساڵدا',
    'days': daysSinceStartOfYear,
  }
];

Future<bool> hasNetwork() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}

extension FancyNum on num {
  String toPrice({includeDemical = false}) => NumberFormat("#,###${includeDemical ? '.##' : ''}", "en_US").format(this);
  String removeTrailingZero() {
    RegExp regex = RegExp(r'([.]*0)(?!.*\d)');

    String s = toString().replaceAll(regex, '');
    return s;
  }
}

extension a on PremiumType {
  int getPrice() => this == PremiumType.threeMonths
      ? 3000
      : this == PremiumType.sixMonths
          ? 5000
          : 9000;
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }
}

Future<bool> showConfirmDialog(String title, String message, BuildContext context, {bool showButtons = true}) async {
  AlertDialog alert = AlertDialog(
    title: Text(title, style: GoogleFonts.bebasNeueTextTheme(AppTheme.darkTheme.textTheme).displayLarge),
    content: Text(message),
    actions: showButtons
        ? [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ]
        : null,
  );

  // show the dialog
  return (await showDialog(
            context: context,
            builder: (BuildContext context) {
              return alert;
            },
          )) ==
          true
      ? true
      : false;
}

Future<void> showInformationDialog(String? title, String message, BuildContext context) async {
  AlertDialog alert = AlertDialog(
    title: title == null ? null : Text(title),
    content: Text(message),
  );

  // show the dialog
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

Future<bool> isUserUsingAdblock() async {
  try {
    final response = await http.get(Uri.parse("https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"));
    return false;
  } on Exception {
    return true;
  }
}

void showSnackbar(String text, BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          text,
        ),
        showCloseIcon: true,
        // backgroundColor: Theme.of(context).cardColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
}
