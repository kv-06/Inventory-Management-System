import 'dart:ui';

import 'package:flutter/material.dart';

class Item {


  static int lastItemid=0;
  final int itemId;
  final int groupId;
  final String itemName;
  final String color;
  final int qty;
  final String unit;
  final int itemlimit;
  final String description; // New field

  static Map<String, Color> colorMap = {
    'red': Colors.red,
    'blue': Colors.blue,
    'green': Colors.green,
    'yellow': Colors.yellow,
    'orange': Colors.orange,
    'black': Colors.black,
    'white': Colors.white,
    'grey': Colors.grey,
    'purple': Colors.purple,
    'pink': Colors.pink,
  };

  Item({
    required this.itemId,
    required this.groupId,
    required this.itemName,
    required this.color,
    required this.qty,
    required this.unit,
    required this.itemlimit,
    required this.description, // Initialize the new field
  });

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'groupId': groupId,
      'itemName': itemName,
      'color': color,
      'qty': qty,
      'unit': unit,
      'itemlimit': itemlimit,
      'description': description, // Add the new field to the map
    };
  }

  @override
  String toString() {
    return 'Item(itemId: $itemId, groupId: $groupId, itemName: $itemName, color: $color, qty: $qty, unit: $unit, itemlimit: $itemlimit, description: $description)'; // Include the new field in toString
  }

  Item copyWith({
    int? itemId,
    int? groupId,
    String? itemName,
    String? color,
    int? qty,
    String? unit,
    int? itemlimit,
    String? description,
  }) {
    return Item(
      itemId: itemId ?? this.itemId,
      groupId: groupId ?? this.groupId,
      itemName: itemName ?? this.itemName,
      color: color ?? this.color,
      qty: qty ?? this.qty,
      unit: unit ?? this.unit,
      itemlimit: itemlimit ?? this.itemlimit,
      description: description ?? this.description,
    );
  }
}

