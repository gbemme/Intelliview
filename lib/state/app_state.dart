import 'package:flutter/material.dart';
import '../models/interview_session.dart';
import '../repositories/history_repository.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  final ApiService apiService;
  final HistoryRepository historyRepository;

  AppState({required this.apiService, required this.historyRepository});

  String? selectedRole;
  String? selectedTrack;
  String? selectedLevel;
  String? errorMessage;
  bool isLoading = false;
  List<String> remoteTrackSuggestions = [];
  List<InterviewSession> history = [];
  String? submittedSessionId;
  List<String> _answers = [];
  int _currentIndex = 0;

  void selectProfile(String role, String track, String level) {
    selectedRole = role;
    selectedTrack = track;
    selectedLevel = level;
    notifyListeners();
  }

  Future<List<String>> loadPracticePrompts() async {
    try {
      final prompts = await apiService.fetchPracticePrompts(
        role: selectedRole ?? 'candidate',
        level: selectedLevel ?? 'Intermediate',
        track: selectedTrack ?? 'technical',
        count: 3,
      );

      return prompts;
    } catch (error) {
      errorMessage = error.toString();
      rethrow;
    }
  }

  Future<void> loadHistory() async {
    _setLoading(true);
    try {
      history = await historyRepository.loadHistory();
      errorMessage = null;
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addSessionToHistory(InterviewSession session) async {
    _setLoading(true);
    try {
      await historyRepository.saveSession(session);
      history.insert(0, session);
      errorMessage = null;
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
