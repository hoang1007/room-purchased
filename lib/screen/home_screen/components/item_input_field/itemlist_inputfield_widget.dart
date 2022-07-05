import 'package:flutter/material.dart';
import 'package:hah/objects/item.dart';
import 'package:hah/objects/time.dart';
import 'package:hah/objects/user_manager.dart';
import 'item_inputfield_widget.dart';

class ItemListInputFieldPane extends StatelessWidget {
  const ItemListInputFieldPane({Key? key, required this.itemCount})
      : super(key: key);
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    var itemInputFieldList = ItemListInputField(length: itemCount);

    return Scaffold(
        body: Form(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(child: itemInputFieldList),
          Padding(
              padding: const EdgeInsets.only(bottom: 20, right: 20),
              child: FloatingActionButton(
                  onPressed: () {
                    // Unfocus the text field
                    FocusManager.instance.primaryFocus?.unfocus();

                    final items = <Item>[];

                    try {
                      for (int i = 0; i < itemCount; i++) {
                        var item = itemInputFieldList[i].controller.getItem();

                        if (item != null) {
                          items.add(item);
                        }
                      }

                      for (int i = 0; i < itemCount; i++) {
                        itemInputFieldList[i].controller.clearTextField();
                      }
                    } on ArgumentError catch (e) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(e.message)));

                      return;
                    }

                    if (items.isNotEmpty) {
                      var itemsInMonth = MapEntry(
                          MonthTime.fromDateTime(items[0].purchasedTime),
                          items);

                      UserManager.instance.user.itemlist
                          .addItemsInMonth(itemsInMonth);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: FutureBuilder<void>(
                        future: UserManager.instance.saveUser(),
                        builder: (BuildContext context,
                            AsyncSnapshot<void> snapshot) {
                          List<Widget> children;

                          if (snapshot.hasData) {
                            children = <Widget>[
                              const Icon(
                                Icons.check_circle_outline,
                                color: Colors.green,
                                size: 60,
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: Text('Saved'),
                              )
                            ];
                          } else if (snapshot.hasError) {
                            children = <Widget>[
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 60,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text('Error: ${snapshot.error}'),
                              )
                            ];
                          } else {
                            children = <Widget>[
                              const SizedBox(
                                width: 60,
                                height: 60,
                                child: CircularProgressIndicator(),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: Text('Awaiting result...'),
                              )
                            ];
                          }

                          return Center(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: children));
                        },
                      )));
                    }
                  },
                  child: const Icon(Icons.check))),
        ])));
  }
}

class ItemListInputField extends StatelessWidget {
  ItemListInputField({Key? key, required this.length}) : super(key: key) {
    for (int i = 0; i < length; i++) {
      _itemInputFields.add(ItemInputField());
    }
  }

  final int length;
  final List<ItemInputField> _itemInputFields = [];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: length,
      itemBuilder: (context, index) {
        return _itemInputFields[index];
      },
    );
  }

  ItemInputField operator [](int index) {
    return _itemInputFields[index];
  }
}
