import 'package:flutter/cupertino.dart';
import 'package:hah/objects/currency.dart';
import 'package:hah/objects/item.dart';
import 'package:hah/objects/item_list.dart';
import 'package:hah/objects/monthtime.dart';

class User {
  final String name;
  // Item list indexing by month
  final ItemList itemlist = ItemList();

  User({required this.name, Map<MonthTime, List<Item>>? initItems}) {
    if (initItems != null) {
      // Don't track the initial items
      itemlist.raw.setTrack(false);
      itemlist.concat(initItems);

      // Re-enable tracking mode
      itemlist.raw.setTrack(true);
    }
  }

  /// `month`: any day in month
  Currency getTotalPurchasedInMonth(MonthTime month) {
    var items = itemlist.getItemsInMonth(month);

    Currency total = Currency.zero;

    for (var item in items) {
      total = total.add(item.price);
    }

    return total;
  }
}