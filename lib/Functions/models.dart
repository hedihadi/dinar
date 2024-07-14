import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:color_print/color_print.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart';

import 'package:dinar/Functions/utils.dart';

enum LocalizationType { english, kurdish, arabic }

enum CalculationType { dinarToCurrency, currencyToDinar }

enum PremiumType { threeMonths, sixMonths, oneYear }

enum PaymentMethod { asiacell, korek, fastpay }

class Category {
  final int id;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;
  List<Item>? items;
  String pictureUrl;
  Category({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
    required this.pictureUrl,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'text': text});
    result.addAll({'created_at': createdAt.millisecondsSinceEpoch});
    result.addAll({'updated_at': updatedAt.millisecondsSinceEpoch});
    result.addAll({'image': pictureUrl});

    if (items != null) {
      result.addAll({'items': items!.map((x) => x.toMap()).toList()});
    }

    return result;
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id']?.toInt() ?? 0,
      pictureUrl: map['image'] ?? '',
      text: map['text'] ?? '',
      createdAt: map['created_at'].runtimeType == String ? DateTime.parse(map['created_at']) : DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: map['updated_at'].runtimeType == String ? DateTime.parse(map['updated_at']) : DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
      items: map['items'] != null ? List<Item>.from(map['items']?.map((x) => Item.fromMap(x))) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Category.fromJson(String source) => Category.fromMap(json.decode(source));
}

class Item {
  final int id;
  final String pictureUrl;
  final double valueFactor;
  final int categoryId;
  final String text;
  List<ItemEntry>? entries;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String unitName;
  final bool shouldShowFraction;
  Item({
    required this.id,
    required this.pictureUrl,
    required this.valueFactor,
    required this.categoryId,
    required this.text,
    this.entries,
    required this.createdAt,
    required this.updatedAt,
    required this.unitName,
    required this.shouldShowFraction,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'image': pictureUrl});
    result.addAll({'value_factor': valueFactor});
    result.addAll({'category_id': categoryId});
    result.addAll({'unit_name': unitName});
    result.addAll({'should_show_fraction': shouldShowFraction});
    result.addAll({'text': text});
    if (entries != null) {
      result.addAll({'entries': entries!.map((x) => x.toMap()).toList()});
    }
    result.addAll({'created_at': createdAt.millisecondsSinceEpoch});
    result.addAll({'updated_at': updatedAt.millisecondsSinceEpoch});

    return result;
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id']?.toInt() ?? 0,
      shouldShowFraction: map['should_show_fraction'] == 1,
      pictureUrl: map['image'] ?? '',
      valueFactor: map['value_factor']?.toDouble() ?? 0.0,
      categoryId: map['category_id']?.toInt() ?? 0,
      text: map['text'] ?? '',
      unitName: map['unit_name'] ?? '',
      entries: map['entries'] != null ? List<ItemEntry>.from(map['entries']?.map((x) => ItemEntry.fromMap(x))) : null,
      createdAt: map['created_at'].runtimeType == String ? DateTime.parse(map['created_at']) : DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: map['updated_at'].runtimeType == String ? DateTime.parse(map['updated_at']) : DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Item.fromJson(String source) => Item.fromMap(json.decode(source));
}

class ItemEntry {
  final int id;
  final int itemId;
  final int value;
  final DateTime createdAt;
  ItemEntry({
    required this.id,
    required this.itemId,
    required this.value,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'item_id': itemId});
    result.addAll({'value': value});
    result.addAll({'created_at': createdAt.millisecondsSinceEpoch});

    return result;
  }

  factory ItemEntry.fromMap(Map<String, dynamic> map) {
    return ItemEntry(
      id: map['id']?.toInt() ?? 0,
      itemId: map['item_id']?.toInt() ?? 0,
      value: map['value']?.toInt() ?? 0,
      createdAt: map['created_at'].runtimeType == String ? DateTime.parse(map['created_at']) : DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ItemEntry.fromJson(String source) => ItemEntry.fromMap(json.decode(source));
}

class EquationResult {
  final String equationResult;
  final String inputText;
  EquationResult({
    required this.equationResult,
    required this.inputText,
  });
}

class ChartData {
  ChartData(this.date, this.value);
  final DateTime date;
  final double value;
}
