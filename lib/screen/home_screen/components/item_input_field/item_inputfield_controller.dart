import 'package:flutter/widgets.dart';
import 'package:hah/objects/currency.dart';
import 'package:hah/objects/item.dart';
import 'package:hah/utils.dart';

class ItemInputFieldController extends ChangeNotifier {
  String _itemName = "";
  final Currency _itemPrice = Currency.zero;

  bool _legalItemName = true;
  bool _legalItemPrice = true;

  bool _firstFocus = true;

  final priceInputFieldController = TextEditingController();
  final nameInputFieldController = TextEditingController();

  ItemInputFieldController() {
    nameInputFieldController.addListener(() {
      _itemName = nameInputFieldController.text;
    });

    priceInputFieldController.addListener(() {
      try {
        _itemPrice.value = priceInputFieldController.text;

        final currencyFormat = _itemPrice.toString();

        // Move cursor position to the last
        // and format text to currency format
        priceInputFieldController.value = TextEditingValue(
            text: currencyFormat,
            selection: TextSelection.collapsed(offset: currencyFormat.length));
      } on Exception {
        // ignore
      }
    });
  }


  String? nameValidator(String? value) {
    if (value == null || value.isEmpty) {
      if (_firstFocus) {
        return null;
      } else {
        _legalItemName = false;
        return "Must not be empty.";
      }
    } else {
      _legalItemName = true;
      _firstFocus = false;
      return null;
    }
  }

  String? priceValidator(String? value) {
    if (value == null || value.isEmpty) {
      if (_firstFocus) {
        return null;
      } else {
        _legalItemPrice = false;
        return "Not a number";
      }
    }

    _firstFocus = false;
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
      // Dont have any error so return null error text
      return null;
    }
  }

  bool validate() {
    return _legalItemName && _legalItemPrice;
  }

  Item? getItem() {
    if (validate()) {
      if (_itemName.isEmpty || _itemPrice == Currency.zero) {
        return null;
      } else {
        return Item(_itemName, _itemPrice, DateTime.now());
      }
    } else {
      throw ArgumentError("Cannot execute query due to some error");
    }
  }

  void clearTextField() {
    nameInputFieldController.clear();
    priceInputFieldController.clear();
    _firstFocus = true;
    notifyListeners();
  }
}
