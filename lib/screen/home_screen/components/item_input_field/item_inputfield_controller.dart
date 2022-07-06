import 'package:flutter/widgets.dart';
import 'package:hah/objects/currency.dart';
import 'package:hah/objects/item.dart';
import 'package:hah/utils.dart';

class ItemInputFieldController extends ChangeNotifier {
  String _itemName = "";
  String _itemPriceStr = "";

  bool _legalItemName = true;
  bool _legalItemPrice = true;

  final priceInputFieldController = TextEditingController();
  final nameInputFieldController = TextEditingController();

  ItemInputFieldController() {
    nameInputFieldController.addListener(() {
      _itemName = nameInputFieldController.text;
    });

    priceInputFieldController.addListener(() {
      try {
        if (priceInputFieldController.text.isNotEmpty) {
          _itemPriceStr = Currency.fromString(priceInputFieldController.text).toString();
        } else {
          _itemPriceStr = priceInputFieldController.text;
        }
      } on Exception {
        // ignore
      }

      // Move cursor position to the last
      // and format text to currency format
      priceInputFieldController.value = TextEditingValue(
          text: _itemPriceStr,
          selection: TextSelection.collapsed(offset: _itemPriceStr.length));
    });
  }

  String? nameValidator(String? value) {
    if ((value == null || value.isEmpty) && _itemPriceStr.isNotEmpty) {
        _legalItemName = false;
        return "Must not be empty";
    }

    _legalItemName = true;
    return null;
  }

  String? priceValidator(String? value) {
    if (value == null || value.isEmpty) {
      if (_itemName.isEmpty) {
        _legalItemPrice = true;
        return null;
      } else {
        _legalItemPrice = false;
        return "Not a number";
      }
    }

    var p = IntegerParser.tryParse(value);

    if (p == null) {
      _legalItemPrice = false;
      return "Not a number";
    } else if (p < 1000) {
      _legalItemPrice = false;
      // min value is 1000
      return "Less than 1000";
    } else {
      _legalItemPrice = true;
      // Don't have any error so return null error text
      return null;
    }
  }

  bool validate() {
    return _legalItemName && _legalItemPrice;
  }

  Item? getItem() {
    if (validate()) {
      if (_itemName.isEmpty || _itemPriceStr.isEmpty) {
        return null;
      } else {
        var _itemPrice = Currency.fromString(_itemPriceStr);
        return Item(_itemName, _itemPrice, DateTime.now());
      }
    } else {
      throw ArgumentError("Cannot execute query due to some error");
    }
  }

  void clearTextField() {
    nameInputFieldController.clear();
    priceInputFieldController.clear();
    notifyListeners();
  }
}
