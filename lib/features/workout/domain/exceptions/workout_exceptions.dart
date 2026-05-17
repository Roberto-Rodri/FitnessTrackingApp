class NoActiveSessionException implements Exception {
  final String message;
  NoActiveSessionException([this.message = 'No active session']);
  
  @override
  String toString() => 'NoActiveSessionException: $message';
}

class DatabaseOperationException implements Exception {
  final String message;
  DatabaseOperationException(this.message);
  @override
  String toString() => message;
}
