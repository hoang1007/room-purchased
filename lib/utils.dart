import 'package:intl/intl.dart';

class CurrencyFormatter {
  final NumberFormat _formatter;

  CurrencyFormatter._createInstance({NumberFormat? formatter})
      : _formatter = formatter ?? NumberFormat("#,##0", "en_US");

  static final CurrencyFormatter _instance =
      CurrencyFormatter._createInstance();

  static CurrencyFormatter get instance => _instance;

  String format(dynamic value) {
    return _formatter.format(value);
  }
}

class IntegerParser {
  static int parse(String value) {
    value = value.replaceAll(",", "").replaceAll(".", "");

    return int.parse(value);
  }

  static int? tryParse(String value) {
    value = value.replaceAll(",", "").replaceAll(".", "");
    return int.tryParse(value);
  }
}
