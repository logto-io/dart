import 'dart:convert';
import 'package:http/http.dart' as http;

import '/src/exceptions/http_request_exceptions.dart';

dynamic httpResponseHandler(http.Response response) {
  var contentType = response.headers.entries
      .firstWhere((v) => v.key.toLowerCase() == 'content-type',
          orElse: () => const MapEntry('', ''))
      .value;

  var isJson = contentType.split(';').first == 'application/json';

  var body = isJson ? jsonDecode(response.body) : response.body;

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw HttpRequestException(statusCode: response.statusCode, body: body);
  }

  return body;
}
