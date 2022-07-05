import 'package:flutter/cupertino.dart';
import 'package:hah/objects/item.dart';
import 'package:hah/objects/time.dart';
import 'package:hah/objects/protected_list.dart';

class ItemList {
  final ProtectedList<MonthTime, Item> _items = ProtectedList();

  /// Save to update to database
  final List<Item> addedInLocal = [];

  Map<K, V> map<K, V>(
      MapEntry<K, V> Function(MonthTime key, List<Item> items) convert) {
    return _items.map(convert);
  }

  /// Add new item
  void addItem(Item newItem) {
    var month = MonthTime.fromDateTime(newItem.purchasedTime);

    _items.add(month, newItem);
  }

  /// Add multiple items with no condition about month
  void addItems(Iterable<Item> newItems) {
    for (var element in newItems) {
      addItem(element);
    }
  }

  void concat(Map<MonthTime, List<Item>> items) {
    for (var month in items.keys) {

      _items.addAll(month, items[month]!);
    }
  }

  /// Add items that on the same month
  void addItemsInMonth(MapEntry<MonthTime, List<Item>> newItems) {
    _items.addAll(newItems.key, newItems.value);
  }

  /// Get items in the same month
  /// `month`: any day in month
  List<Item> getItemsInMonth(MonthTime month) {
    return _items.get(month);
  }

  ProtectedList<MonthTime, Item> get raw => _items;
}
