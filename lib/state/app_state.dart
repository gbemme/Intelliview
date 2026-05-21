import 'dart:async';
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
  StreamSubscription<List<InterviewSession>>? _historySubscription;

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
      errorMessage = friendlyMessageForError(error);
      rethrow;
    }
  }

  Future<void> loadHistory() async {
    await _historySubscription?.cancel();

    errorMessage = null;
    _setLoading(true);

    _historySubscription = historyRepository.getSessionsStream().listen(
      (updatedSessions) {
        history = updatedSessions;
        errorMessage = null;
        isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        errorMessage = 'Could not load history. Please try again.';
        _setLoading(false);
      },
    );
  }

  /// Adiciona sessão no histórico (Remoto e Local)
  Future<void> addSessionToHistory(InterviewSession session) async {
    _setLoading(true);
    try {
      await historyRepository.saveSession(session);
      // O stream em loadHistory() já vai atualizar a lista automaticamente, 
      // mas mantemos a inserção local para resposta imediata na UI
      if (!history.any((s) => s.id == session.id)) {
        history.insert(0, session);
      }
      errorMessage = null;
    } catch (error) {
      errorMessage = 'Could not save session. Your results may not have been recorded.';
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  /// MÉTODO ÚNICO: Resolvendo o erro de duplicidade (duplicate_definition)
  void _setLoading(bool value) {
    if (isLoading != value) {
      isLoading = value;
      notifyListeners();
    }
  }
}