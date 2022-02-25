import 'package:flutter/material.dart';
import 'package:hah/database/idatabase.dart';
import 'package:hah/objects/user.dart';
import 'package:hah/objects/user_manager.dart';

class Splash extends StatelessWidget {
  final Widget nextScreen;

  const Splash({Key? key, required this.nextScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
            future: IDatabase.instance.getUsernames(),
            builder: (context, AsyncSnapshot<List<String>> snapshot) {
              List<Widget> children = [];

              if (snapshot.hasData) {
                for (String name in snapshot.data!) {
                  UserManager.instance.addUser(User(name: name));
                }

                WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => nextScreen));
                });
              } else {
                children = [
                  const Center(
                      child: CircularProgressIndicator(
                    color: Colors.amber,
                  ))
                ];
              }

              return Column(
                children: children,
              );
            }));
  }
}
