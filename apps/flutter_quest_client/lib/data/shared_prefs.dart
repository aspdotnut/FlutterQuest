import 'package:shared_preferences/shared_preferences.dart';

Future<void> setPrefs(String key, String value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

Future<String?> getPrefs(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

Future<void> removePrefs(String key) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(key);
}