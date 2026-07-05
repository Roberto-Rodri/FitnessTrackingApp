import '../../domain/repositories/user_prefs_repository.dart';
import '../../domain/entities/user_profile.dart';
import '../datasources/user_prefs_local_data_source.dart';

class UserPrefsRepositoryImpl implements UserPrefsRepository {
  final UserPrefsLocalDataSource dataSource;

  UserPrefsRepositoryImpl({required this.dataSource});

  @override
  Future<String?> getName() {
    return dataSource.getName();
  }

  @override
  Future<void> setName(String name) {
    return dataSource.setName(name);
  }

  @override
  Future<TrainingPhase> getTrainingPhase() async {
    final phaseStr = await dataSource.getTrainingPhase();
    if (phaseStr == null) return TrainingPhase.none;
    
    return TrainingPhase.values.firstWhere(
      (e) => e.name == phaseStr,
      orElse: () => TrainingPhase.none,
    );
  }

  @override
  Future<void> setTrainingPhase(TrainingPhase phase) {
    return dataSource.setTrainingPhase(phase.name);
  }
}
