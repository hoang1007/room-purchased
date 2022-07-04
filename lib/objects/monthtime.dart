class MonthTime implements Comparable<MonthTime> {
  static DateTime firstDate = DateTime(2022);
  static DateTime lastDate = DateTime(2025);

  int _year = 0;
  int _month = 0;

  MonthTime.fromDateTime(DateTime dt) {
    _year = dt.year;
    _month = dt.month;
  }

  MonthTime.now() {
    final dt = DateTime.now();
    _year = dt.year;
    _month = dt.month;
  }

  MonthTime.parse(String s) {
    var tokens = s.split("-");

    if (tokens.length == 2) {
      _month = int.parse(tokens[0]);
      _year = int.parse(tokens[1]);
    } else {
      throw ArgumentError("Invalid date format. Expected `mm-yyyy`");
    }
  }

  @override
  String toString() {
    return "$_month-$_year";
  }

  @override
  int get hashCode {
    return toString().hashCode;
  }

  @override
  int compareTo(MonthTime other) {
    return 12 * (_year - other._year) + (_month - other._month);
  }

  @override
  bool operator ==(Object other) {
    if (other is MonthTime) {
      return _year == other._year && _month == other._month;
    } else {
      return false;
    }
  }
}
