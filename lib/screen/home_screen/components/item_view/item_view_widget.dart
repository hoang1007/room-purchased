import 'package:flutter/material.dart';
import 'package:hah/database/idatabase.dart';
import 'package:hah/objects/currency.dart';
import 'package:hah/objects/item.dart';
import 'package:hah/objects/monthtime.dart';
import 'package:hah/objects/user.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class ItemViewWidget extends StatefulWidget {
  static const String title = "Purchased Items Viewer";

  const ItemViewWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ItemViewState();
}

class _ItemViewState extends State<ItemViewWidget> {
  int _selectedIndex = 0;

  var selectedMonth = MonthTime.now();

  void _onTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _selectDateTime() async {
    showMonthPicker(
      context: context,
      initialDate: DateTime.now(),
    ).then((date) {
      if (date != null) {
        var month = MonthTime.fromDateTime(date);

        if (month != selectedMonth) {
          setState(() {
            selectedMonth = month;
          });
        }
      }
    });
  }

  List<BottomNavigationBarItem> _createUserBarItems(
      Iterable<String> usernames) {
    return usernames
        .map((e) => BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline_rounded), label: e))
        .toList();
  }

  Map<String, Currency> _getPurchasedInfo(List<User> users, MonthTime month) {
    var total = Currency.zero;

    for (var user in users) {
      total = total.add(user.getTotalPurchasedInMonth(month));
    }

    var average = total.devideInt(users.length);

    return {"total": total, "average": average};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: IDatabase.instance.getUsers(),
      builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
        if (snapshot.hasData) {
          var users = snapshot.data!;
          var purchasedInfo = _getPurchasedInfo(users, selectedMonth);

          return Scaffold(
            appBar: AppBar(
              title: Text("Item Purchased in $selectedMonth"),
              centerTitle: true,
            ),
            body: _ItemListView(
              user: users[_selectedIndex],
              month: selectedMonth,
              totalPurchased: purchasedInfo["total"]!,
              avgPurchased: purchasedInfo["average"]!,
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: _createUserBarItems(users.map((e) => e.name)),
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.accents[0],
              onTap: _onTapped,
            ),
            floatingActionButton: ElevatedButton(
              onPressed: _selectDateTime,
              child: const Icon(Icons.calendar_month),
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
              ),
            ),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}

class _ItemListView extends StatelessWidget {
  final User user;
  final MonthTime month;
  final Currency totalPurchased;
  final Currency avgPurchased;

  const _ItemListView(
      {Key? key,
      required this.user,
      required this.month,
      required this.totalPurchased,
      required this.avgPurchased})
      : super(key: key);

  ListView _createItemListView() {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: user.itemlist.getItemsInMonth(month).length,
      itemBuilder: (context, index) {
        return _createItemWidget(user.itemlist.getItemsInMonth(month)[index]);
      },
      separatorBuilder: (context, index) => const Divider(),
    );
  }

  Widget _createItemWidget(Item item) {
    return Row(
      children: <Widget>[
        Expanded(child: Text(item.name, textAlign: TextAlign.center)),
        Expanded(
            child: Text(item.price.toString(), textAlign: TextAlign.center)),
        Expanded(
            child: Text(
                DateFormat('dd/MM/yyyy hh:mm').format(item.purchasedTime),
                textAlign: TextAlign.center)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _createItemListView()),
        Row(children: <Widget>[
          Expanded(
            child: Text("Purchased: ${user.getTotalPurchasedInMonth(month)}",
                textAlign: TextAlign.center),
          ),
          Expanded(
              child:
                  Text("Total: $totalPurchased", textAlign: TextAlign.center)),
          Expanded(
              child: Text(
                  "Difference: ${user.getTotalPurchasedInMonth(month).subtract(avgPurchased)}",
                  textAlign: TextAlign.center)),
          const SizedBox(
            height: 8,
          )
        ]),
      ],
    );
  }
}
