import 'package:dinar/Functions/utils.dart';
import 'package:flutter/material.dart';

extension CustomThemeDataExt on ThemeData {
  Color get success {
    if (brightness == Brightness.dark) {
      return HexColor("#58c47a");
    }
    return HexColor('#07935e');
  }
  Color get calculatorCardColor {
    if (brightness == Brightness.dark) {
      return Colors.transparent;
    }
    return HexColor('#323c57');
  }
  Color get error {
    if (brightness == Brightness.dark) {
      return HexColor("#f26249");
    }
    return HexColor('#07935e');
  }
}
