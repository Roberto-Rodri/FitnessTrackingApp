import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/user_profile.dart';

part 'profile_providers.g.dart';

@riverpod
class UserProfileController extends _$UserProfileController {
  @override
  Future<UserProfile> build() async {
    final repository = ref.watch(userPrefsRepositoryProvider);
    final name = await repository.getName();
    final phase = await repository.getTrainingPhase();
    return UserProfile(name: name, phase: phase);
  }

  Future<void> saveName(String name) async {
    final repository = ref.read(userPrefsRepositoryProvider);
    await repository.setName(name);
    ref.invalidateSelf();
  }

  Future<void> saveTrainingPhase(TrainingPhase phase) async {
    final repository = ref.read(userPrefsRepositoryProvider);
    await repository.setTrainingPhase(phase);
    ref.invalidateSelf();
  }
}
