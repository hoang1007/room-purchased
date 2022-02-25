import 'package:hah/objects/currency.dart';
import 'package:hah/objects/item.dart';
import 'package:hah/objects/monthtime.dart';
import 'package:hah/objects/user.dart';
import 'package:hah/exception.dart';

class UserManager {
  UserManager._userManager();

  static final UserManager _instance = UserManager._userManager();

  static UserManager get instance => _instance;

  final List<User> users = [];
  User? _iUser;

  void addUser(User user) => users.add(user);

  User get iUser => _iUser!;
  set iUser(User user) {
    _iUser ??= user;
  }

  void addUserWithItems(User user, Iterable<Item> items) {
    user.addAll(items);
    users.add(user);
  }

  void clearUserItems() {
    for (var user in users) {
      user.items.clear();
    }
  }

  /// Get user match witch given name.
  /// throw `NotFoundException` if user is not found
  User getUserWithName(String name) {
    for (var user in users) {
      if (user.name == name) return user;
    }

    throw NotFoundException("Provided name does not match any users.");
  }

  Currency getTotalPurchased(MonthTime month) {
    Currency total = Currency.zero;

    for (var user in users) {
      total = total.add(user.getTotalPurchasedInMonth(month));
    }

    return total;
  }

  Currency getAveragePurchased(MonthTime month) {
    try {
      return getTotalPurchased(month).devideInt(users.length);
    } on ArgumentError {
      return Currency.zero;
    }
  }
}
