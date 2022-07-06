import 'package:hah/database/idatabase.dart';
import 'package:hah/objects/time.dart';

class StatusManager {
  static const int UNKNOW = 0, PAID = 1, UNPAID = 2;
  static Future<bool> getPaidStatusInMonth(MonthTime month) {
    return IDatabase.instance.getPaidStatusInMonth(month);
  }

  static Future<void> setPaidStatus(MonthTime month, bool paid) {
    return IDatabase.instance.setPaidStatus(month, paid);
  }
}
