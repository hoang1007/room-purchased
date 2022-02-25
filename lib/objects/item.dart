import 'package:hah/objects/currency.dart';

class Item {
  final String name;
  final Currency price;
  final DateTime purchasedTime;

  Item(this.name, this.price, this.purchasedTime);
}
