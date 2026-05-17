import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iron_log/features/profile/data/datasources/user_prefs_local_data_source.dart';

void main() {
  late UserPrefsLocalDataSource dataSource;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    dataSource = UserPrefsLocalDataSource();
  });

  group('UserPrefsLocalDataSource Phase Tests', () {
    test('getTrainingPhase should return null initially', () async {
      final phase = await dataSource.getTrainingPhase();
      expect(phase, isNull);
    });

    test('setTrainingPhase should save the phase string to SharedPreferences', () async {
      await dataSource.setTrainingPhase('gaining');
      final phase = await dataSource.getTrainingPhase();
      expect(phase, equals('gaining'));
    });
  });
}
