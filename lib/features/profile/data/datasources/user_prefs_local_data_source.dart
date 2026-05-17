import 'package:shared_preferences/shared_preferences.dart';

class UserPrefsLocalDataSource {
  static const _nameKey = 'user_name';

  Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  Future<void> setName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
  }
}
