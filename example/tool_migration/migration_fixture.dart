// Shared by both phases of the token-migration upgrade test so the keys and values
// written under flutter_secure_storage 9.x are exactly the ones asserted after the
// upgrade. Keys mirror `_TokenStorageKeys` in lib/src/modules/token_storage.dart; if
// those ever change, this must change with them, since the migration is keyed on them.
import 'package:flutter/material.dart';

const migrationFixture = <String, String>{
  'logto_id_token': 'migration-probe-id-token',
  'logto_access_token': 'migration-probe-access-token',
  'logto_refresh_token': 'migration-probe-refresh-token',
};

/// Marker line the driver script greps for in logcat. These entrypoints run as a real
/// app rather than under a test runner, so the result has to leave the device somehow;
/// `debugPrint` reaches logcat under the `flutter` tag.
void report(bool passed, String detail) {
  debugPrint('LOGTO_MIGRATION_RESULT ${passed ? 'PASS' : 'FAIL'} $detail');
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(child: Text(passed ? 'PASS' : 'FAIL: $detail')),
      ),
    ),
  );
}
