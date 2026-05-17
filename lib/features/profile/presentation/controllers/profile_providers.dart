import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/injection.dart';

part 'profile_providers.g.dart';

@riverpod
class UserName extends _$UserName {
  @override
  Future<String?> build() async {
    final repository = ref.watch(userPrefsRepositoryProvider);
    return repository.getName();
  }

  Future<void> saveName(String name) async {
    final repository = ref.read(userPrefsRepositoryProvider);
    await repository.setName(name);
    state = AsyncData(name);
  }
}
