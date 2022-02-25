import 'package:flutter/material.dart';
import 'package:hah/objects/user_logging.dart';
import 'package:hah/objects/user_manager.dart';
import 'package:hah/exception.dart';
import 'package:hah/screen/components/text_field_container.dart';

class LoginWidget extends StatefulWidget {
  final Widget nextScreen;

  const LoginWidget({Key? key, required this.nextScreen}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final _formKey = GlobalKey<FormState>();
  String _username = "";

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
                          try {
                            UserManager.instance.iUser =
                                UserManager.instance.getUserWithName(_username);

                            try {
                              UserLogging.instance.saveUser(_username);
                            } on Exception {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Cannot save your account!')),
                              );
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Logging in as $_username')),
                            );

                            WidgetsBinding.instance
                                ?.addPostFrameCallback((timeStamp) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => widget.nextScreen));
                            });
                          } on NotFoundException {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("User does not exist")),
                            );
                          }
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
