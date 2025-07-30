import 'package:po_pal/utilities/enums/sort_option.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _weightKey = 'weight_preference';
  static const String _exerciseSortKey = 'exercise_sort_preference';
  static const String _workoutSortKey = 'workout_sort_preference';
  static const String _chartModeKey = 'chart_mode_preference';

  static Future<bool> getWeightPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_weightKey) ?? true;
  }

  static Future<void> setWeightPreference(bool isKg) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_weightKey, isKg);
  }

  static Future<SortOption> getExerciseSortPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_exerciseSortKey) ?? 0;
    return SortOption.values[index];
  }

  static Future<void> setExerciseSortPreference(SortOption option) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_exerciseSortKey, option.index);
  }

  static Future<SortOption> getWorkoutSortPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_workoutSortKey) ?? 0;
    return SortOption.values[index];
  }

  static Future<void> setWorkoutSortPreference(SortOption option) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_workoutSortKey, option.index);
  }

  static Future<bool> getChartModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_chartModeKey) ?? false;
  }

  static Future<void> setChartModePreference(bool isLoadMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chartModeKey, isLoadMode);
  }
}
