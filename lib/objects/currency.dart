import 'package:hah/utils.dart';


class Currency {
  static Currency get zero => Currency(0);

  int _value = 0;

  Currency(int value) {
    _value = value;
  }

  Currency.fromString(String strVal) {
    _value = IntegerParser.parse(strVal);
  }

  Currency add(Currency o) {
    return Currency(o._value + _value);
  }

  Currency subtract(Currency o) {
    return Currency(_value - o._value);
  }

  Currency multiply(Currency o) {
    return Currency(_value * o._value);
  }

  Currency devide(Currency o) {
    return devideInt(o._value);
  }

  Currency devideInt(int k) {
    if (k == 0) throw ArgumentError("Denominator is zero!");

    return Currency((_value / k).round());
  }

  int get value => _value;

  /// if v is null throw `Argument Error`
  /// if v is String and is not a number throw `FormatException`
  set value(dynamic v) {
    if (v == null) {
      throw ArgumentError("Value must not be null!");
    } else if (v is String) {
      try {
        _value = IntegerParser.parse(v);
      } on FormatException {
        throw const FormatException("Not a number");
      }
    } else if (v is int) {
      _value = v;
    }
  }

  @override
  String toString() {
    return CurrencyFormatter.instance.format(value);
  }
}
