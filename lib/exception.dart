class NotFoundException implements Exception {
  final String message;

  NotFoundException([this.message = ""]);

  @override
  String toString() => message;
}

class InvalidValue implements Exception {
  final String message;

  InvalidValue([this.message = ""]);

  @override
  String toString() => message;
}
