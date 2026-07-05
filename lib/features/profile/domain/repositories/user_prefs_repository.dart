import '../entities/user_profile.dart';

abstract class UserPrefsRepository {
  Future<String?> getName();
  Future<void> setName(String name);
  Future<TrainingPhase> getTrainingPhase();
  Future<void> setTrainingPhase(TrainingPhase phase);
  Future<bool> getHasSeenWarmupHint();
  Future<void> setHasSeenWarmupHint(bool value);
}
