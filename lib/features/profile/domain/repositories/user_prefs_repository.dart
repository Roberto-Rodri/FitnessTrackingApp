abstract class UserPrefsRepository {
  Future<String?> getName();
  Future<void> setName(String name);
}
