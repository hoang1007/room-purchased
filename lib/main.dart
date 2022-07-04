import 'package:flutter/material.dart';
import 'package:hah/objects/user.dart';
import 'package:hah/objects/user_manager.dart';
import 'package:hah/database/flutter_firestore.dart';
import 'package:hah/database/idatabase.dart';
import 'package:hah/screen/home_screen/home_screen.dart';
import 'package:hah/screen/login/login_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  IDatabase.setDatabase(FireStoreDatabase());
  await IDatabase.instance.init();

  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: UserManager.instance.getSavedUser(),
      builder: (context, AsyncSnapshot<User> snapshot) {
        if (snapshot.hasData) {
          UserManager.instance.user = snapshot.data!;
          return const HomeScreen();
        } else {
          return const LoginWidget(nextScreen: HomeScreen());
        }
      },
    );
  }
}
