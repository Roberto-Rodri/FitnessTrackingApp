import 'package:shared_preferences/shared_preferences.dart';

class UserPrefsLocalDataSource {
  static const _nameKey = 'user_name';
  static const _phaseKey = 'prefs_training_phase';

  Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  Future<void> setName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
  }

  Future<String?> getTrainingPhase() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phaseKey);
  }

  Future<void> setTrainingPhase(String phase) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_phaseKey, phase);
  }

  Future<bool> getHasSeenWarmupHint() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('prefs_has_seen_warmup_hint') ?? false;
  }

  Future<void> setHasSeenWarmupHint(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('prefs_has_seen_warmup_hint', value);
  }
}
