import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/interview_session.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
 
Future<List<String>> fetchPracticePrompts({
  required String role,
  required String track,
  required int count,
}) async {

  final model = GenerativeModel(
    model: 'gemini-2.5-flash', 
    apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
  );

   final prompt = '''
Generate $count ${track.toLowerCase()} interview questions for a $role.

Rules:
- If track is "technical", focus on domain knowledge, tools, methodologies, and problem-solving relevant to the role
- If track is "behavioral", focus on experience, teamwork, communication, and conflict resolution
- Tailor all questions specifically to the $role — avoid generic or coding-specific questions unless the role demands it
- Do NOT number the questions
- Return each question on a new line
''';

  final response = await model.generateContent([Content.text(prompt)]);

  if (response.text == null) {
    throw Exception('Empty response');
  }

  return response.text!
      .trim()
      .split('\n')
      .where((q) => q.trim().isNotEmpty)
      .take(count)
      .toList();
}

}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}
