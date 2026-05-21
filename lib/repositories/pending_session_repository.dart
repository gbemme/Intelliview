import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/interview_session.dart';

class PendingSessionRepository {
  static const _key = 'pending_session';

  Future<void> save(InterviewSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(session.toJson()));
  }

  Future<InterviewSession?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    return InterviewSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
