// Phase A of the token-migration upgrade test. See tool/test_token_migration.sh.
//
// A standalone app entrypoint, not a widget test: the two phases must run from
// separate installs of the same package so that phase B reads app data written by a
// different flutter_secure_storage version. `flutter test integration_test/...`
// uninstalls the app when it finishes, which erases exactly the state under test, so
// the driver builds these entrypoints instead and reinstalls with `adb install -r`.
//
// Reproduces how logto_dart_sdk 3.x persisted tokens: flutter_secure_storage 9.x with
// the Jetpack `EncryptedSharedPreferences` backend. The driver pins 9.2.4 before
// building this, so it uses the 9.x API rather than `SecureStorageStrategy`, which on
// 4.0 writes the new cipher format. Excluded from analysis because
// `encryptedSharedPreferences` is ignored in 10.x and absent in 11.x.
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'migration_fixture.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    );

    for (final entry in migrationFixture.entries) {
      await storage.delete(key: entry.key);
      await storage.write(key: entry.key, value: entry.value);
    }

    // Fail here rather than in phase B if the v9 backend never stored anything.
    for (final entry in migrationFixture.entries) {
      final stored = await storage.read(key: entry.key);
      if (stored != entry.value) {
        report(false, 'v9 write of ${entry.key} did not round-trip: $stored');
        return;
      }
    }

    report(true, 'wrote ${migrationFixture.length} tokens via the v9 backend');
  } catch (error) {
    report(false, 'v9 write threw: $error');
  }
}
