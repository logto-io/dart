// Phase B of the token-migration upgrade test. See tool/test_token_migration.sh.
//
// Runs from a reinstall (`adb install -r`) over the app data phase A wrote under
// flutter_secure_storage 9.x, so the data directory is preserved. Reads through
// `SecureStorageStrategy` — the class logto_dart_sdk 4.0 actually ships — so this
// exercises the upgrade path an existing user takes rather than a stand-in.
import 'package:flutter/material.dart';
import 'package:logto_dart_sdk/logto_client.dart';

import 'migration_fixture.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final storage = SecureStorageStrategy();

    for (final entry in migrationFixture.entries) {
      final stored = await storage.read(key: entry.key);
      if (stored != entry.value) {
        report(
          false,
          '${entry.key} was not migrated from the v9 backend (got $stored); '
          'upgrading from SDK 3.x would sign existing Android users out',
        );
        return;
      }
    }

    report(true, 'all ${migrationFixture.length} tokens survived the upgrade');
  } catch (error) {
    report(false, 'read after upgrade threw: $error');
  }
}
