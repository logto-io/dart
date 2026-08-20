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
  /// Uses the default [AndroidOptions] on Android: AES-GCM encrypted storage.
  ///
  /// Tokens written by SDK 3.x used the now-deprecated Jetpack
  /// EncryptedSharedPreferences backend. flutter_secure_storage 10.x reads that
  /// data and migrates it to the custom cipher storage on first access, since
  /// `migrateOnAlgorithmChange` defaults to true. That bridge only exists in
  /// 10.x — the 11.x release removed the EncryptedSharedPreferences backend
  /// entirely, so upgrading straight from 9.x to 11.x renders the old tokens
  /// unreadable. Keep this dependency on 10.x until users have had a release
  /// to migrate through.
  final _storage = const FlutterSecureStorage();

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
