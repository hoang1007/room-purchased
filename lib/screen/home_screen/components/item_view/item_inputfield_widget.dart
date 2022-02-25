import 'package:flutter/material.dart';
import 'package:hah/screen/home_screen/components/item_view/item_view_controller.dart';

class ItemInputField extends StatefulWidget {
  ItemInputField({Key? key}) : super(key: key);

  final ItemViewController controller = ItemViewController();

  @override
  State<StatefulWidget> createState() => _ItemInputFieldState();
}

class _ItemInputFieldState extends State<ItemInputField> {
  @override
  void initState() {
    super.initState();
  }

  TextFormField _createItemNameInputField() {
    return TextFormField(
      decoration: const InputDecoration(
          border: UnderlineInputBorder(), hintText: "Item name"),
      controller: widget.controller.nameInputFieldController,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: widget.controller.nameValidator,
    );
  }

  TextFormField _createItemPriceInputField() {
    return TextFormField(
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        hintText: "Item price",
        errorStyle: TextStyle(),
      ),
      controller: widget.controller.priceInputFieldController,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: widget.controller.priceValidator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _createItemNameInputField()),
            Expanded(child: _createItemPriceInputField()),
          ],
        ));
  }
}
