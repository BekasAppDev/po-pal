import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _weightKey = 'weight_preference';

  static Future<bool> getWeightPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_weightKey) ?? true;
  }

  static Future<void> setWeightPreference(bool isKg) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_weightKey, isKg);
  }
}
