import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_model.dart';

class DatabaseService {
  static const String _baseKey = 'pulse_fit_workouts';

  Future<String> _getUserKey() async {
    final prefs = await SharedPreferences.getInstance();

    final email = prefs.getString('current_user_email') ?? '';

    if (email.isEmpty) {
      return '${_baseKey}_no_user';
    }

    final safeEmail = email
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');

    return '${_baseKey}_$safeEmail';
  }

  Future<List<WorkoutModel>> getWorkouts() async {
    final prefs = await SharedPreferences.getInstance();

    final key = await _getUserKey();

    return WorkoutModel.decode(
      prefs.getString(key),
    );
  }

  Future<void> saveWorkout(WorkoutModel workout) async {
    final prefs = await SharedPreferences.getInstance();

    final key = await _getUserKey();

    final items = await getWorkouts();

    items.insert(0, workout);

    await prefs.setString(
      key,
      WorkoutModel.encode(items),
    );
  }
}