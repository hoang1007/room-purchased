import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hah/screen/home_screen/components/item_view/item_view_widget.dart';
import 'package:hah/screen/home_screen/components/item_input_field/itemlist_inputfield_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: const [
        ItemListInputFieldPane(itemCount: 10,),
        ItemViewWidget()
      ],
    );
  }
}
