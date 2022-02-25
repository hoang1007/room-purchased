import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hah/screen/home_screen/components/item_view/item_view_widget.dart';
import 'package:hah/screen/home_screen/components/item_input_field/itemlist_inputfield_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pages = [
      const ItemListInputFieldPane(itemCount: 10,),
      const ItemViewWidget()];

    return PageView(
      controller: PageController(initialPage: pages.length),
      children: pages,
    );
  }
}
//
// class _HomeScreenState extends State<HomeScreen> {
//   final double _threshold = 5;
//   int _choosenScreenId = 0;
//
//   final _screens = [
//     const ItemListInputFieldPane(itemCount: 10),
//     const ItemViewWidget()
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onPanUpdate: (DragUpdateDetails details) {
//         if (details.delta.dx > _threshold || details.delta.dx < -_threshold) {
//           setState(() {
//             _choosenScreenId = (_choosenScreenId + 1) % _screens.length;
//           });
//         }
//       },
//       child: _screens[_choosenScreenId],
//     );
//   }
// }
