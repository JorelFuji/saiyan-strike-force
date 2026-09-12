import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vulcan/data/csv/csv_service.dart';
import 'package:vulcan/data/local/preferences/preferences_data_source.dart';
import 'package:vulcan/data/repositories/settings_repository_impl.dart';

class _MockPreferencesDataSource extends Mock
    implements PreferencesDataSource {}

void main() {
  group('SettingsRepositoryImpl', () {
    late _MockPreferencesDataSource preferences;
    late SettingsRepositoryImpl repository;

    setUp(() {
      preferences = _MockPreferencesDataSource();
      repository = SettingsRepositoryImpl(preferences);
    });

    test('getIsDarkMode defaults to false when unset', () async {
      when(() => preferences.getBool('isDarkMode')).thenReturn(null);

      final result = await repository.getIsDarkMode().run();

      expect(result, equals(const Right<dynamic, bool>(false)));
    });

    test('getIsDarkMode returns stored value', () async {
      when(() => preferences.getBool('isDarkMode')).thenReturn(true);

      final result = await repository.getIsDarkMode().run();

      expect(result, equals(const Right<dynamic, bool>(true)));
    });

    test('setIsDarkMode persists value', () async {
      when(() => preferences.setBool('isDarkMode', true))
          .thenAnswer((_) async => true);

      final result = await repository.setIsDarkMode(true).run();

      expect(result.isRight(), isTrue);
      verify(() => preferences.setBool('isDarkMode', true)).called(1);
    });

    test('setIsDarkMode maps persistence failure', () async {
      when(() => preferences.setBool('isDarkMode', true))
          .thenAnswer((_) async => false);

      final result = await repository.setIsDarkMode(true).run();

      expect(result.isLeft(), isTrue);
    });
  });

  group('CsvService', () {
    late CsvService csvService;

    setUp(() {
      csvService = CsvService();
    });

    test('round-trips rows', () {
      const rows = [
        ['name', 'reps'],
        ['squat', '5'],
      ];

      final encoded = csvService.encode(rows);
      final decoded = csvService.decode(encoded);

      expect(decoded, equals(rows));
    });

    test('decode empty string returns empty list', () {
      expect(csvService.decode(''), isEmpty);
      expect(csvService.decode('   '), isEmpty);
    });
  });

  group('PreferencesDataSource', () {
    test('reads and writes bool defaults', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final dataSource = PreferencesDataSource(prefs);

      expect(dataSource.getBool('isDarkMode'), isNull);

      final wrote = await dataSource.setBool('isDarkMode', true);
      expect(wrote, isTrue);
      expect(dataSource.getBool('isDarkMode'), isTrue);
    });
  });
}
