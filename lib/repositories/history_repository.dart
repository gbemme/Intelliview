import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/interview_session.dart';

class HistoryRepository {
  static const _storageKey = 'interview_history';

  Future<List<InterviewSession>> loadHistory() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return <InterviewSession>[];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => InterviewSession.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveSession(InterviewSession session) async {
    final sessions = await loadHistory();
    sessions.insert(0, session);
    final encoded = jsonEncode(sessions.map((item) => item.toJson()).toList());
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, encoded);
  }
}
