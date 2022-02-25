import 'package:hah/objects/currency.dart';
import 'package:hah/objects/item.dart';
import 'package:hah/objects/monthtime.dart';

class User {
  final String name;
  // Item list indexing by month
  final Map<MonthTime, List<Item>> _items = {};

  User({required this.name});

  void addItem(Item newItem) {
    var month = MonthTime.fromDateTime(newItem.purchasedTime);

    if (_items.containsKey(month)) {
      _items[month]!.add(newItem);
    } else {
      _items[month] = [newItem];
    }
  }

  void addAll(Iterable<Item> newItems) {
    for (var element in newItems) {
      addItem(element);
    }
  }

  /// `month`: any day in month
  void addItemsWithSameMonth(MapEntry<MonthTime, List<Item>> newItems) {
    if (_items.containsKey(newItems)) {
      _items[newItems.key]!.addAll(newItems.value);
    } else {
      _items[newItems.key] = newItems.value;
    }
  }

  void addItems(Map<MonthTime, List<Item>> newItems) {
    _items.addAll(newItems);
  }

  void update(MapEntry<MonthTime, List<Item>?> newItems) {
    if (newItems.value == null) {
      _items[newItems.key] = [];
    } else {
      _items[newItems.key] = newItems.value!;
    }
  }

  /// `month`: any day in month
  List<Item> getItemsInMonth(MonthTime month) {
    if (!_items.containsKey(month)) {
      _items[month] = [];
    }

    return _items[month]!;
  }

  /// `month`: any day in month
  Currency getTotalPurchasedInMonth(MonthTime month) {
    if (_items.containsKey(month)) {
      Currency total = Currency.zero;

      for (var item in _items[month]!) {
        total = total.add(item.price);
      }

      return total;
    }

    return Currency.zero;
  }

  Map<MonthTime, List<Item>> get items => _items;
}
