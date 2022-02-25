import 'package:flutter/material.dart';
import 'package:hah/objects/item.dart';
import 'package:hah/objects/monthtime.dart';
import 'package:hah/objects/user.dart';
import 'package:hah/objects/user_manager.dart';
import 'package:hah/database/idatabase.dart';
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

  List<BottomNavigationBarItem> _createUserBarItems() {
    return UserManager.instance.users
        .map((e) => BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline_rounded), label: e.name))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Item Purchased in $selectedMonth"),
        centerTitle: true,
      ),
      body: _ItemListView(
        user: UserManager.instance.users[_selectedIndex],
        month: selectedMonth,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _createUserBarItems(),
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
  }
}

class _ItemListView extends StatelessWidget {
  final User user;
  final MonthTime month;

  const _ItemListView({Key? key, required this.user, required this.month})
      : super(key: key);

  ListView _createItemListView() {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: user.getItemsInMonth(month).length,
      itemBuilder: (context, index) {
        return _createItemWidget(user.getItemsInMonth(month)[index]);
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
            child: Text(item.purchasedTime.toString(),
                textAlign: TextAlign.center)),
      ],
    );
  }

  List<Widget> _getItemViewobjects() {
    return <Widget>[
      Expanded(child: _createItemListView()),
      Row(children: <Widget>[
        Expanded(
          child: Text("Purchased: ${user.getTotalPurchasedInMonth(month)}",
              textAlign: TextAlign.center),
        ),
        Expanded(
            child: Text(
                "Total: ${UserManager.instance.getTotalPurchased(month)}",
                textAlign: TextAlign.center)),
        Expanded(
            child: Text(
                "Difference: ${user.getTotalPurchasedInMonth(month).subtract(UserManager.instance.getAveragePurchased(month))}",
                textAlign: TextAlign.center)),
      ]),
      const SizedBox(
        height: 8,
      ) // for bottom padding
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: IDatabase.instance.getItemsInMonthOfAllUsers(month),
      builder: (BuildContext context,
          AsyncSnapshot<Map<String, List<Item>>> snapshot) {
        List<Widget> children;

        if (snapshot.hasData) {
          var data = snapshot.data!;

          for (User user in UserManager.instance.users) {
            if (data.containsKey(user.name)) {
              user.update(MapEntry(month, data[user.name]));
            } else {
              user.update(MapEntry(month, []));
            }
          }

          children = _getItemViewobjects();
        } else if (snapshot.hasError) {
          debugPrintStack(stackTrace: snapshot.stackTrace);
          UserManager.instance.clearUserItems();
          children = _getItemViewobjects();

          WidgetsBinding.instance?.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(snapshot.error.toString()),
              duration: const Duration(seconds: 1),
            ));
          });
        } else {
          children = <Widget>[
            const Center(
                child: SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            ))
          ];
        }

        return Column(
          children: children,
        );
      },
    );
  }
}
