import 'package:cached_network_image/cached_network_image.dart';
import 'package:dinar/Functions/local_database_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:function_tree/function_tree.dart';
import 'package:intl/intl.dart' as intl;
import 'package:sizer/sizer.dart';
import 'package:dinar/Functions/models.dart';
import 'package:dinar/Functions/theme.dart';
import 'package:dinar/Functions/utils.dart';
import 'package:dinar/Screens/AuthorizedScreen/Widgets/item_widget.dart';
import 'package:dinar/Screens/AuthorizedScreen/authorized_screen_providers.dart';
import 'package:dinar/Screens/DataScreen/data_screen.dart';
import 'package:dinar/Screens/MainScreen/main_screen.dart';
import 'package:dinar/Screens/MainScreen/main_screen_providers.dart';
import 'package:dinar/Widgets/future_provider_widget.dart';

TextStyle buttonsTextStyle = const TextStyle(fontSize: 40);
final calculationTypeProvider = StateProvider<CalculationType>((ref) => CalculationType.dinarToCurrency);
final selectedItemProvider = StateProvider<Item?>((ref) => null);
final equationResultProvider = StateProvider<EquationResult?>((ref) => null);
final inputProvider = StateProvider<String>((ref) => '0');

class CalculatorScreen extends ConsumerWidget {
  CalculatorScreen({super.key});
  final FocusNode focusNode = FocusNode();

  void addElementToCalculation(String text, WidgetRef ref) {
    String equationResult = '';
    String result = '';
    if (text == "((") {
      ref.read(inputProvider.notifier).state = '0';
      ref.read(equationResultProvider.notifier).state = null;
      return;
    }

    if (text == "(") {
      ref.read(inputProvider.notifier).state = ref.read(inputProvider).substring(0, ref.read(inputProvider).length - 1);
      text = "";
    }
    String str = ref.read(inputProvider) + text;
    if (str == "") {
      str = "0";
    }
    if (text == ".") {
      ref.read(inputProvider.notifier).state = str;
      return;
    }
    str = str.replaceAll(",", "");
    String temporary = "";
    final strings = str.split("");
    str = "";
    for (String ss in strings) {
      if (ss == "×" || ss == "-" || ss == "+" || ss == "÷") {
        if (temporary != "") {
          str = "$str${double.parse(temporary).toPrice(includeDemical: true)}";
        }
        str = str + ss;
        temporary = "";
      } else {
        temporary = temporary + ss;
      }
    }
    if (temporary != "") {
      str = "$str${(double.parse(temporary)).toPrice(includeDemical: true)}";
    }
    ref.read(inputProvider.notifier).state = str;
    str = str.replaceAll(",", "");
    str = str.replaceAll("×", "*");
    str = str.replaceAll("÷", "/");
    str = str.interpret().toString();
    double doubleResult = double.parse(str);
    equationResult = (doubleResult).toPrice(includeDemical: true);
    final selectedItem = ref.read(selectedItemProvider);
    if (ref.read(calculationTypeProvider) == CalculationType.dinarToCurrency) {
      doubleResult = doubleResult * (selectedItem!.valueFactor / selectedItem.entries![0].value);
    } else {
      doubleResult = doubleResult * (selectedItem!.entries![0].value / selectedItem.valueFactor);
    }
    String strResult = doubleResult.toStringAsFixed(2);
    result = (double.parse(strResult)).toPrice(includeDemical: true);
    ref.read(equationResultProvider.notifier).state = EquationResult(equationResult: equationResult, inputText: result);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calculationType = ref.watch(calculationTypeProvider);
    final selectedItem = ref.watch(selectedItemProvider);
    final input = ref.watch(inputProvider);
    final equationResult = ref.watch(equationResultProvider);

    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Card(
            // color: CustomColors().bg2,
            child: Column(children: [
              ...getCurrenciesWidgets(ref),
              if (selectedItem != null)
                Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    "${selectedItem.valueFactor.round()} ${selectedItem.unitName} = ${selectedItem.entries?.first.value.toPrice()} دینار",
                  ),
                ),
            ]),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: IntrinsicWidth(
            child: TextField(
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.all(8),
                ),
                controller: TextEditingController(text: input),
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.titleLarge,
                autofocus: true,
                showCursor: true,
                readOnly: true),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Column(
              children: [
                Text(
                  'ئەنجام',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(),
                ),
                Text(
                  getResultText(equationResult, calculationType, selectedItem),
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          ),
        ),
        Directionality(
          textDirection: TextDirection.ltr,
          child: GridView.count(
              childAspectRatio: 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              // Create a grid with 2 columns. If you change the scrollDirection to
              // horizontal, this produces 2 rows.
              crossAxisCount: 4,
              // Generate 100 widgets that display their index in the List.
              children: [
                TextButton(
                    onPressed: () {
                      addElementToCalculation("7", ref);
                    },
                    child: Text(
                      "7",
                      style: buttonsTextStyle,
                    )),
                TextButton(
                    onPressed: () {
                      addElementToCalculation("8", ref);
                    },
                    child: Text(
                      "8",
                      style: buttonsTextStyle,
                    )),
                TextButton(
                    onPressed: () {
                      addElementToCalculation("9", ref);
                    },
                    child: Text(
                      "9",
                      style: buttonsTextStyle,
                    )),
                TextButton(
                    onPressed: () {
                      addElementToCalculation("÷", ref);
                    },
                    child: Text("÷", style: buttonsTextStyle.copyWith(color: Colors.amber[800]))),
                TextButton(
                    onPressed: () {
                      addElementToCalculation("4", ref);
                    },
                    child: Text(
                      "4",
                      style: buttonsTextStyle,
                    )),
                TextButton(
                    onPressed: () {
                      addElementToCalculation("5", ref);
                    },
                    child: Text(
                      "5",
                      style: buttonsTextStyle,
                    )),
                TextButton(
                    onPressed: () {
                      addElementToCalculation("6", ref);
                    },
                    child: Text(
                      "6",
                      style: buttonsTextStyle,
                    )),
                TextButton(
                    onPressed: () {
                      addElementToCalculation("×", ref);
                    },
                    child: Text(
                      "×",
                      style: buttonsTextStyle.copyWith(color: Colors.amber[800]),
                    )),
                TextButton(
                    onPressed: () {
                      addElementToCalculation("1", ref);
                    },
                    child: Text(
                      "1",
                      style: buttonsTextStyle,
                    )),
                TextButton(
                    onPressed: () {
                      addElementToCalculation("2", ref);
                    },
                    child: Text(
                      "2",
                      style: buttonsTextStyle,
                    )),
                TextButton(
                    onPressed: () {
                      addElementToCalculation("3", ref);
                    },
                    child: Text(
                      "3",
                      style: buttonsTextStyle,
                    )),
                TextButton(
                    onPressed: () {
                      addElementToCalculation("-", ref);
                    },
                    child: Text(
                      "-",
                      style: buttonsTextStyle.copyWith(color: Colors.amber[800]),
                    )),
                TextButton(
                    onPressed: () {
                      addElementToCalculation(".", ref);
                    },
                    child: Text(
                      ".",
                      style: buttonsTextStyle,
                    )),
                TextButton(
                    onPressed: () {
                      addElementToCalculation("0", ref);
                    },
                    child: Text(
                      "0",
                      style: buttonsTextStyle,
                    )),
                TextButton(
                  onPressed: () {
                    addElementToCalculation("(", ref);
                  },
                  onLongPress: () {
                    addElementToCalculation("((", ref);
                  },
                  child: Icon(Icons.backspace, color: Colors.redAccent[400]),
                ),
                TextButton(
                    onPressed: () {
                      addElementToCalculation("+", ref);
                    },
                    child: Text(
                      "+",
                      style: buttonsTextStyle.copyWith(color: Colors.amber[800]),
                    )),
              ]),
        ),
      ],
    );
  }

  List<Widget> getCurrenciesWidgets(WidgetRef ref) {
    final dropdownItems = ref.watch(backendProvider.notifier).getItems().where((element) => [2, 3].contains(element.categoryId)).toList();
    final data = [
      Center(
        child: Card(
          elevation: 10,
          shadowColor: Colors.transparent,
          child: DropdownButton<Item>(
            underline: const SizedBox(),
            value: ref.watch(selectedItemProvider),
            items: dropdownItems.map<DropdownMenuItem<Item>>((Item value) {
              return DropdownMenuItem<Item>(
                value: value,
                child: Directionality(
                  textDirection: ref.watch(directionalityProvider),
                  child: Row(
                    children: [
                      CachedNetworkImage(
                        height: 3.h,
                        imageUrl: value.pictureUrl,
                        placeholder: (context, url) => Container(),
                        errorWidget: (context, url, error) => Container(),
                      ),
                      Text(value.text),
                    ],
                  ),
                ),
              );
            }).toList(),
            onChanged: (Item? value) {
              if (value != null) {
                LocalDatabaseManager.saveSettingKey('calculation_item_id', value.id);
              }
              ref.read(selectedItemProvider.notifier).state = value;
              addElementToCalculation('0', ref);
              addElementToCalculation(')', ref);
            },
          ),
        ),
      ),
      IconButton(
        onPressed: () async {
          ref.read(calculationTypeProvider.notifier).state = ref.read(calculationTypeProvider) == CalculationType.currencyToDinar
              ? CalculationType.dinarToCurrency
              : CalculationType.currencyToDinar;
          addElementToCalculation('', ref);
          //addElementToCalculation(')', ref);
        },
        icon: const Icon(Icons.arrow_downward),
      ),
      Center(
        child: Card(
          elevation: 10,
          shadowColor: Colors.transparent,
          child: DropdownButton<Item>(
            onChanged: null,
            underline: const SizedBox(),
            value: null,
            items: [
              DropdownMenuItem<Item>(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 5.h, child: Image.asset('assets/images/flag.png')),
                    SizedBox(width: 2.w),
                    const Text("دینار"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ];
    if (ref.watch(calculationTypeProvider) == CalculationType.currencyToDinar) {
      return data;
    }
    return data.reversed.toList();
  }

  String getResultText(EquationResult? equationResult, CalculationType calculationType, Item? selectedItem) {
    if (equationResult == null || selectedItem == null) {
      return '';
    }
    if (calculationType == CalculationType.currencyToDinar) {
      return "${equationResult.equationResult} ${selectedItem.unitName} = ${equationResult.inputText} دینار ";
    }
    return "${equationResult.equationResult} دینار = ${equationResult.inputText} ${selectedItem.unitName}";
  }
}
