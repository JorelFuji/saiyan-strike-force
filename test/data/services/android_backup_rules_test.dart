import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final root = Directory.current.path;

  test(
    'legacy Android backup excludes database, files, and secure storage',
    () {
      final manifest = File('$root/android/app/src/main/AndroidManifest.xml')
          .readAsStringSync();
      final rules = File('$root/android/app/src/main/res/xml/backup_rules.xml')
          .readAsStringSync();

      expect(manifest, contains('android:allowBackup="false"'));
      expect(
        manifest,
        contains('android:fullBackupContent="@xml/backup_rules"'),
      );
      expect(rules, contains('domain="database"'));
      expect(rules, contains('domain="file"'));
      _expectSecureStorageExclusions(rules);
    },
  );

  test(
    'Android 12 extraction excludes every protected location in both modes',
    () {
      final rules = File(
        '$root/android/app/src/main/res/xml/data_extraction_rules.xml',
      ).readAsStringSync();

      for (final section in <String>['cloud-backup', 'device-transfer']) {
        final match = RegExp('<$section[^>]*>([\\s\\S]*?)</$section>')
            .firstMatch(rules);
        expect(match, isNotNull);
        expect(match!.group(1), contains('domain="database"'));
        expect(match.group(1), contains('domain="file"'));
        _expectSecureStorageExclusions(match.group(1)!);
      }
    },
  );
}

void _expectSecureStorageExclusions(String rules) {
  for (final name in <String>[
    'vulcan_fitness_database_key',
    'FlutterSecureKeyStorage:vulcan_fitness_database_key',
    'FlutterSecureStorageConfiguration:vulcan_fitness_database_key',
  ]) {
    expect(rules, contains('domain="sharedpref" path="$name"'));
  }
}
