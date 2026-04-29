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
  String? errorMessage;
  bool isLoading = false;
  List<String> remoteTrackSuggestions = [];
  List<InterviewSession> history = [];
  String? submittedSessionId;

  void selectProfile(String role, String track) {
    selectedRole = role;
    selectedTrack = track;
    notifyListeners();
  }

  Future<void> loadTrackSuggestions() async {
    _setLoading(true);
    try {
      remoteTrackSuggestions = await apiService.fetchTrackSuggestions();
      errorMessage = null;
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<List<String>> loadPracticePrompts() async {
    try {
      return await apiService.fetchPracticePrompts();
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

  Future<void> submitSession(InterviewSession session) async {
    _setLoading(true);
    try {
      submittedSessionId = await apiService.submitSession(session);
      errorMessage = null;
    } catch (error) {
      errorMessage = error.toString();
      rethrow;
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
