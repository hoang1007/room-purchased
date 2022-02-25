import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class UserLogging {
  static final UserLogging instance = UserLogging();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/log.txt');
  }

  Future<File> saveUser(String username) async {
    final file = await _localFile;

    return file.writeAsString(username);
  }

  Future<String?> getUsername() async {
    try {
      final file = await _localFile;

      // Read the file
      return file.readAsString().then((value) {
        if (value.isEmpty) {
          return null;
        } else {
          return value;
        }
      });
    } catch (e) {
      return Future.value(null);
    }
  }
}
