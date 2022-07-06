import 'package:flutter/material.dart';
import 'package:hah/database/idatabase.dart';
import 'package:hah/objects/currency.dart';
import 'package:hah/objects/item.dart';
import 'package:hah/objects/status_manager.dart';
import 'package:hah/objects/time.dart';
import 'package:hah/objects/user.dart';
import 'package:hah/objects/user_manager.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class ItemViewWidget extends StatefulWidget {
  const ItemViewWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ItemViewState();
}

class _ItemViewState extends State<ItemViewWidget> {
  int _selectedIndex = 0;
  var selectedMonth = MonthTime.now();
  int paidStatus = StatusManager.UNKNOW;

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

  void _refreshUserIndex(List<User> users) {
    var newIndex = users.indexOf(UserManager.instance.user);

    if (newIndex != -1 && newIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = newIndex;
      });
    }
  }

  List<NavigationDestination> _createUserBarItems(Iterable<String> usernames) {
    return usernames
        .map((e) => NavigationDestination(
            icon: const Icon(Icons.person_outlined), label: e))
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

          _refreshUserIndex(users);

          return Scaffold(
            appBar: AppBar(
              title: Theme(
                  data: ThemeData.light(),
                  child: Row(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: DropdownButtonHideUnderline(
                            child: TextButton(
                                onPressed: _selectDateTime,
                                child: Text(selectedMonth.toString()),
                                style: TextButton.styleFrom(
                                    shadowColor: Colors.blueGrey.shade50,
                                    primary: Colors.white,
                                    textStyle: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)))),
                      ),
                      Align(
                          alignment: Alignment.centerRight,
                          child: FutureBuilder(
                            future: StatusManager.getPaidStatusInMonth(
                                    selectedMonth)
                                .then((value) {
                              setState(() {
                                paidStatus = value
                                    ? StatusManager.PAID
                                    : StatusManager.UNPAID;
                              });
                            }),
                            builder: (BuildContext context,
                                AsyncSnapshot<void> snapshot) {
                              if (snapshot.hasError) {
                                debugPrint(snapshot.error.toString());
                              } else {
                                return IconButton(
                                  icon: () {
                                    switch (paidStatus) {
                                      case StatusManager.UNKNOW:
                                        return const CircularProgressIndicator();
                                      case StatusManager.UNPAID:
                                        return const Icon(
                                            Icons.radio_button_unchecked_outlined,
                                            color: Colors.greenAccent);
                                      case StatusManager.PAID:
                                        return const Icon(
                                          Icons.check_circle,
                                          color: Colors.greenAccent,
                                        );
                                    }
                                  }()!,
                                  onPressed: () {
                                    bool newStatus = true;
                                    if (paidStatus == StatusManager.PAID) {
                                      newStatus = false;
                                    }

                                    StatusManager.setPaidStatus(
                                            selectedMonth, newStatus)
                                        .then((value) {
                                      if (newStatus) {
                                        setState(() {
                                          paidStatus = StatusManager.PAID;
                                        });
                                      } else {
                                        setState(() {
                                          paidStatus = StatusManager.UNPAID;
                                        });
                                      }
                                    });
                                  },
                                );
                              }

                              return const Center(
                                  child: CircularProgressIndicator());
                            },
                          ))
                    ],
                  )),
              centerTitle: false,
              foregroundColor: Colors.white54,
            ),
            body: _ItemListView(
              user: users[_selectedIndex],
              month: selectedMonth,
              totalPurchased: purchasedInfo["total"]!,
              avgPurchased: purchasedInfo["average"]!,
            ),
            bottomNavigationBar: NavigationBarTheme(
              data: NavigationBarThemeData(
                  indicatorColor: Colors.blue.shade100,
                  labelTextStyle: MaterialStateProperty.all(const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500))),
              child: NavigationBar(
                destinations: _createUserBarItems(users.map((e) => e.name)),
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onTapped,
                height: 60,
              ),
            ),
          );
        } else {
          return const Center(
            child: SizedBox(
                height: 60, width: 60, child: CircularProgressIndicator()),
          );
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
    var widgets = _createItemInDayWidgets(user.itemlist.getItemsInMonth(month))
        .entries
        .toList();

    return ListView.builder(
      itemBuilder: (context, index) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widgets[index].key.toString()),
          widgets[index].value
        ]);
      },
      itemCount: widgets.length,
      padding: const EdgeInsets.all(8),
    );
  }

  Map<DayTime, Widget> _createItemInDayWidgets(List<Item> items) {
    Map<DayTime, List<Item>> itemsInDay = {};

    for (var item in items) {
      var day = DayTime.fromDateTime(item.purchasedTime);

      if (itemsInDay.containsKey(day)) {
        itemsInDay[day]!.add(item);
      } else {
        itemsInDay[day] = [item];
      }
    }

    return itemsInDay.map((day, items) => MapEntry(
        day,
        Material(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            color: Colors.lightBlueAccent.withOpacity(0.6),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Wrap(
                  runSpacing: 10,
                  children: itemsInDay[day]!
                      .map((item) => _createItemWidget(item))
                      .toList()),
            ))));
  }

  Widget _createItemWidget(Item item) {
    return Row(
      children: <Widget>[
        Expanded(child: Text(item.name, textAlign: TextAlign.center)),
        Expanded(
            child: Text(item.price.toString(), textAlign: TextAlign.center)),
        Expanded(
            child: Text(DateFormat('hh:mm').format(item.purchasedTime),
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
