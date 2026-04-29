import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/interview_session.dart';

class ApiService {
  static const _baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<String>> fetchTrackSuggestions() async {
    final response = await http.get(Uri.parse('$_baseUrl/posts?_limit=3'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map((item) => item['title'] as String).toList();
    }
    throw ApiException('Failed to load track suggestions');
  }

  Future<List<String>> fetchPracticePrompts() async {
    final response = await http.get(Uri.parse('$_baseUrl/comments?_limit=4'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map((item) => item['name'] as String).toList();
    }
    throw ApiException('Failed to load practice prompts');
  }

  Future<String> submitSession(InterviewSession session) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(session.toJson()),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['id'].toString();
    }
    throw ApiException('Failed to submit session');
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}
