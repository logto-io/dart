class HttpRequestException implements Exception {
  final int statusCode;

  final dynamic body;

  HttpRequestException({required this.statusCode, this.body});

  @override
  String toString() {
    return 'HttpRequestException($statusCode): $body';
  }
}
