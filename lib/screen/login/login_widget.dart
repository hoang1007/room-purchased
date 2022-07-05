import 'package:flutter/material.dart';
import 'package:hah/objects/user.dart';
import 'package:hah/objects/user_logging.dart';
import 'package:hah/objects/user_manager.dart';
import 'package:hah/screen/widgets/text_field_container.dart';

class LoginWidget extends StatefulWidget {
  final Widget nextScreen;

  const LoginWidget({Key? key, required this.nextScreen}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final _formKey = GlobalKey<FormState>();
  String _username = "";

  void routingNext() {
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
              widget.nextScreen));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
            key: _formKey,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFieldContainer(
                      color: Colors.green[50],
                      child: TextFormField(
                        decoration: const InputDecoration(
                            border: InputBorder.none, hintText: "Username"),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Username is required.";
                          }

                          return null;
                        },
                        onChanged: (value) => _username = value,
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton(
                          child: const Text("Login"),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: FutureBuilder(
                                  future: UserManager.instance
                                      .getUserWithName(_username),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<User> snapshot) {
                                    String message = "Something went wrong";

                                    if (snapshot.hasData) {
                                      User? user = snapshot.data;
                                      if (user != null) {
                                        try {
                                          UserLogging.instance
                                              .saveUsername(user.name);
                                          message = "Logged in as " + user.name;
                                        } on Exception {
                                          message = "Logged in as " +
                                              user.name +
                                              ". But can't save the account";
                                        }

                                        // Save the user to manager
                                        UserManager.instance.user = user;

                                        routingNext();
                                      } else {
                                        message = "User not found";
                                      }
                                    } else if (snapshot.hasError) {
                                      message = "Something went wrong. " +
                                          snapshot.error.toString();
                                    } else {
                                      message = "Loading...";
                                    }

                                    return Text(message);
                                  },
                                ),
                              ));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Username is invalid")),
                              );
                            }
                          },
                        ))
                  ],
                ))));
  }
}
