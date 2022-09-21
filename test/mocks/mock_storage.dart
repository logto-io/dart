import 'package:logto_dart_sdk/src/utilities/logto_storage_strategy.dart';

class MockStorageStrategy implements LogtoStorageStrategy {
  final Map<String, String?> _storage = {};

  @override
  Future<void> delete({required String key}) async {
    _storage[key] = null;
  }

  @override
  Future<String?> read({required String key}) async {
    return _storage[key];
  }

  @override
  Future<void> write({required String key, required String? value}) async {
    _storage[key] = value;
  }
}
