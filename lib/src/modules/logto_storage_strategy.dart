import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class LogtoStorageStrategy {
  Future<void> write({
    required String key,
    required String? value,
  });

  Future<String?> read({required String key});

  Future<void> delete({required String key});
}

class SecureStorageStrategy implements LogtoStorageStrategy {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  @override
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  @override
  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  @override
  Future<void> write({required String key, required String? value}) async {
    await _storage.write(
      key: key,
      value: value,
    );
  }
}
