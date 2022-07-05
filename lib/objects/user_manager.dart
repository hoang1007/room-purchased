import 'package:flutter/material.dart';
import 'package:hah/database/idatabase.dart';
import 'package:hah/objects/currency.dart';
import 'package:hah/objects/time.dart';
import 'package:hah/objects/user.dart';
import 'package:hah/exception.dart';
import 'package:hah/objects/user_logging.dart';

class UserManager {
  static final UserManager _instance = UserManager._userManager();

  static UserManager get instance => _instance;

  User? _user;

  UserManager._userManager() {
    _user = null;
  }

  User get user {
    if (_user == null) {
      throw InvalidValue("No user in manager.");
    } else {
      return _user!;
    }
  }

  set user(User user) {
    _user ??= user;
  }

  Future<void> saveUser() async {
    for (var entry in user.itemlist.raw.trackedItems.entries) {
      await IDatabase.instance.addItems(user, entry);
    }

    user.itemlist.raw.clearTrack();
  }

  Future<User> getSavedUser() async {
    String? username = await UserLogging.instance.getUsername();

    if (username == null) {
      throw InvalidValue("No user has been saved.");
    } else {
      return IDatabase.instance.getUserByName(username);
    }
  }

  /// Get user match witch given name.
  /// throw `NotFoundException` if user is not found
  Future<User> getUserWithName(String name) async {
    try {
      var user = await IDatabase.instance.getUserByName(name);

      return user;
    } on Exception {
      throw NotFoundException("Provided name does not match any users.");
    }
  }

  /// Get purchased infomantion of users.
  /// Returns: total purchased and average purchased of all users
  Future<Map<String, Currency>> getPurchasedInfo(MonthTime month) async {
    var items = await IDatabase.instance.getItemsInMonthOfAllUsers(month);

    Map<String, Currency> res = {};

    Currency total = Currency.zero;
    int numUser = 0;

    for (var userItems in items.values) {
      numUser += 1;

      for (var item in userItems) {
        total = total.add(item.price);
      }
    }

    res["total"] = total;
    res["average"] = total.devideInt(numUser);

    return res;
  }
}
