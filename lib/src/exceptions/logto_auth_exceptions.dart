enum LogtoAuthExceptions {
  callbackUriValidationError,
  idTokenValidationError,
  authenticationError
}

class LogtoAuthException implements Exception {
  final LogtoAuthExceptions code;
  final String error;
  final String? errorDescription;

  LogtoAuthException(this.code, this.error, [this.errorDescription]);

  @override
  String toString() {
    return 'LogtoAuthException($code): $error ${errorDescription == null ? '' : ': $errorDescription'}';
  }
}
