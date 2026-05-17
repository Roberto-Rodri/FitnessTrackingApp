import '../../domain/repositories/user_prefs_repository.dart';
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
}
