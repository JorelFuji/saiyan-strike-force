import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final root = Directory.current.path;

  test('Android build configuration uses the supported Kotlin migration', () {
    final wrapperProperties = File(
      '$root/android/gradle/wrapper/gradle-wrapper.properties',
    ).readAsStringSync();
    final gradleProperties = File('$root/android/gradle.properties')
        .readAsStringSync();
    final appBuildFile = File('$root/android/app/build.gradle.kts')
        .readAsStringSync();

    expect(
      wrapperProperties,
      contains(
        'distributionUrl=https\\://services.gradle.org/distributions/'
        'gradle-9.3.1-all.zip',
      ),
    );
    expect(gradleProperties, contains('android.builtInKotlin=true'));
    expect(gradleProperties, contains('android.newDsl=false'));
    expect(appBuildFile, isNot(contains('kotlin-android')));
    expect(appBuildFile, isNot(contains('org.jetbrains.kotlin.android')));
  });
}
