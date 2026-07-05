import 'package:flutter_test/flutter_test.dart';
import 'package:iron_log/features/profile/data/datasources/user_prefs_local_data_source.dart';
import 'package:iron_log/features/profile/data/repositories/user_prefs_repository_impl.dart';
import 'package:iron_log/features/profile/domain/entities/user_profile.dart';

class FakeUserPrefsLocalDataSource implements UserPrefsLocalDataSource {
  String? _phase;

  @override
  Future<String?> getTrainingPhase() async => _phase;

  @override
  Future<void> setTrainingPhase(String phase) async {
    _phase = phase;
  }

  @override
  Future<String?> getName() async => null;

  @override
  Future<void> setName(String name) async {}

  @override
  Future<bool> getHasSeenWarmupHint() async => false;

  @override
  Future<void> setHasSeenWarmupHint(bool value) async {}
}

void main() {
  late FakeUserPrefsLocalDataSource fakeDataSource;
  late UserPrefsRepositoryImpl repository;

  setUp(() {
    fakeDataSource = FakeUserPrefsLocalDataSource();
    repository = UserPrefsRepositoryImpl(dataSource: fakeDataSource);
  });

  group('UserPrefsRepositoryImpl Phase Tests', () {
    test('getTrainingPhase should return TrainingPhase.none if data source returns null', () async {
      final phase = await repository.getTrainingPhase();
      expect(phase, equals(TrainingPhase.none));
    });

    test('getTrainingPhase should correctly map string to enum', () async {
      await fakeDataSource.setTrainingPhase('cutting');
      final phase = await repository.getTrainingPhase();
      expect(phase, equals(TrainingPhase.cutting));
    });

    test('getTrainingPhase should return TrainingPhase.none for unknown string', () async {
      await fakeDataSource.setTrainingPhase('invalid_phase_name');
      final phase = await repository.getTrainingPhase();
      expect(phase, equals(TrainingPhase.none));
    });

    test('setTrainingPhase should map enum to string and pass to data source', () async {
      await repository.setTrainingPhase(TrainingPhase.gaining);
      final phaseStr = await fakeDataSource.getTrainingPhase();
      expect(phaseStr, equals('gaining'));
    });
  });
}
