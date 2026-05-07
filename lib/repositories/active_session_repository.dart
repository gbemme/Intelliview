import '../models/active_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ActiveSessionRepository {
  static const _key = 'active_session';

  Future<void> save(ActiveSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(session.toJson()));
  }

  Future<ActiveSession?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw == null) return null;

    return ActiveSession.fromJson(jsonDecode(raw));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}