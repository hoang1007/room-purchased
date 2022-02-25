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

  Future<File> write(String value) async {
    final file = await _localFile;

    return file.writeAsString(value);
  }

  Future<String?> read() async {
    try {
      final file = await _localFile;

      // Read the file
      return await file.readAsString();
    } catch (e) {
      return Future.value(null);
    }
  }
}
