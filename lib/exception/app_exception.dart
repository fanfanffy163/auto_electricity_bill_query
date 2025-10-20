class AppException implements Exception {
  final String message;
  final int code;
  AppException(this.message,{this.code = 100});

  @override
  String toString() {
    return message;
  }
}