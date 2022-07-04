import 'package:flutter/cupertino.dart';

/// The list is built with only `add`, `addAll`, `get` operator.
/// It also track these operations.
class ProtectedList<K, V> {
  final Map<K, List<V>> _items = {};
  final Map<K, List<V>> _trackedItems = {};
  bool _isTracked = true;

  void add(K key, V value) {
    if (_items.containsKey(key)) {
      _items[key]!.add(value);
    } else {
      _items[key] = [value];
    }

    if (_isTracked) {
      if (_trackedItems.containsKey(key)) {
        _trackedItems[key]!.add(value);
      } else {
        _trackedItems[key] = [value];
      }
    }
  }

  void addAll(K key, Iterable<V> values) {
    if (!_items.containsKey(key)) {
      _items[key] = values.toList(); // clone to initalize the items
    } else {
      _items[key]!.addAll(values);
    }

    if (_isTracked) {
      if (_trackedItems.containsKey(key)) {
        _trackedItems[key]!.addAll(values);
      } else {
        _trackedItems[key] = values.toList();
      }
    }
  }

  Map<K2, V2> map<K2, V2>(
      MapEntry<K2, V2> Function(K key, List<V> items) convert) {
    return _items.map(convert);
  }

  void setTrack(bool mode) {
    _isTracked = mode;
  }

  void clearTrack() {
    _trackedItems.clear();
  }

  @override
  String toString() {
    return _items.toString();
  }

  // List<V> get(K key) => _items[key]!.toList();
  List<V> get(K key) {
    if (_items.containsKey(key)) {
      return _items[key]!.toList();
    } else {
      return <V>[];
    }
  }

  Map<K, List<V>> get trackedItems => Map.from(_trackedItems);
}
