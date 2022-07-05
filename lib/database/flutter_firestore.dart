import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:hah/objects/currency.dart';
import 'package:hah/objects/time.dart';
import 'package:hah/objects/user.dart';
import 'package:hah/objects/item.dart';
import 'package:hah/database/idatabase.dart';

/**
 * This file is used to connect to your Firebase.
 * Run `flutter configure` to generate it.
 */
import 'package:hah/firebase_options.dart';

class FireStoreDatabase implements IDatabase {
  @override
  Future<void> init() async {
    return Future.value(Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    )).then((value) => {
          FirebaseFirestore.instance.settings =
              const Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED)
        });
  }

  @override
  Future<void> addItems(User user, MapEntry<MonthTime, List<Item>> items) {
    return _FireStoreUtils.getUserRef().doc(user.name).update({
      "items.${items.key.toString()}": FieldValue.arrayUnion(
          items.value.map((e) => _FireStoreConverter.itemToJson(e)).toList())
    });
  }

  @override
  Future<void> addUser(User user) {
    return _FireStoreUtils.getUserRefWithConverter().doc(user.name).set(user);
  }

  @override
  Future<User> getUserByName(String name) {
    return _FireStoreUtils.getUserRefWithConverter()
        .doc(name)
        .get()
        .then((value) => value.data()!);
  }

  @override
  Future<List<User>> getUsers() {
    return _FireStoreUtils.getUserRefWithConverter()
        .get()
        .then((value) => value.docs.map((e) => e.data()).toList());
  }

  @override
  Future<List<Item>> getItemsInMonth(User user, MonthTime month) {
    return _FireStoreUtils.getUserRef()
        .doc("${user.name}.items.${month.toString()}")
        .get()
        .then((value) => (value.data()! as List<Map<String, dynamic>>)
            .map((e) => _FireStoreConverter.itemFromJson(e))
            .toList());
  }

  @override
  Future<Map<String, List<Item>>> getItemsInMonthOfAllUsers(MonthTime month) {
    return _FireStoreUtils.getUserRefWithConverter()
        .get()
        .then((QuerySnapshot<User> snapshot) {
      Map<String, List<Item>> result = {};

      snapshot.docs.forEach((element) {
        try {
          var items = element.get("items.$month") as List<dynamic>;

          result[element.data().name] =
              items.map((e) => _FireStoreConverter.itemFromJson(e)).toList();
        } on StateError {
          // ignore if user does not purchase any item in this month.
        }
      });

      return Future<Map<String, List<Item>>>.value(result);
    });
  }

  @override
  Future<List<String>> getUsernames() {
    return _FireStoreUtils.getUserRef().get().then((snapshot) {
      return snapshot.docs.map((e) => e.id).toList();
    });
  }
}

class _FireStoreConverter {
  static Map<String, dynamic> itemToJson(Item item) {
    return <String, dynamic>{
      'name': item.name,
      'price': item.price.value,
      'purchasedTime': Timestamp.fromDate(item.purchasedTime)
    };
  }

  static Item itemFromJson(Map<String, dynamic> json) {
    return Item(json['name'] as String, Currency(json['price'] as int),
        (json['purchasedTime'] as Timestamp).toDate());
  }

  static Map<String, dynamic> userToJson(User user) {
    return <String, dynamic>{
      'name': user.name,
      'items': user.itemlist.map((k, e) =>
          MapEntry(k.toString(), e.map((e) => itemToJson(e)).toList())),
    };
  }

  static User userFromJson(Map<String, dynamic> json) {
    var itemsMap = (json['items'] as Map<String, dynamic>).map(
      (k, e) => MapEntry(
          MonthTime.parse(k),
          (e as List<dynamic>)
              .map((e) => itemFromJson(e as Map<String, dynamic>))
              .toList()),
    );

    User user = User(name: json['name'] as String, initItems: itemsMap);
    return user;
  }
}

class _FireStoreUtils {
  static const String _userCollection = "Users";


  static CollectionReference<User> getUserRefWithConverter() {
    return FirebaseFirestore.instance.collection(_userCollection).withConverter(
        fromFirestore: (snapshot, _) => _FireStoreConverter.userFromJson(snapshot.data()!),
        toFirestore: (user, _) => _FireStoreConverter.userToJson(user));
  }

  static CollectionReference getUserRef() {
    return FirebaseFirestore.instance.collection(_userCollection);
  }
}
