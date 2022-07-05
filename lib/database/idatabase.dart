import 'package:hah/objects/item.dart';
import 'package:hah/objects/time.dart';

import '../objects/user.dart';

abstract class IDatabase {
  static IDatabase? _instance;

  Future<void> init() async {}

  /// Add an user to the database.
  Future<void> addUser(User user);

  /// Get all username from the database.
  Future<List<String>> getUsernames();

  /// Get user by given name.
  Future<User> getUserByName(String name);

  /// Add items with the same month to the database.
  /// `DateTime`: month
  Future<void> addItems(User user, MapEntry<MonthTime, List<Item>> items);

  /// Get items that purchased in the given month.
  Future<List<Item>> getItemsInMonth(User user, MonthTime month);

  /// Get items that purchased by all users in the given month.
  Future<Map<String, List<Item>>> getItemsInMonthOfAllUsers(MonthTime month);

  /// Get all users in the database.
  Future<List<User>> getUsers();

  static void setDatabase(IDatabase database) {
    _instance = database;
  }

  static IDatabase get instance {
    return _instance!;
  }
}
