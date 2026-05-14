import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class QuestionScore {
  final int clarity;
  final int accuracy;
  final String clarityReasoning;
  final String accuracyReasoning;

  QuestionScore({
    required this.clarity,
    required this.accuracy,
    required this.clarityReasoning,
    required this.accuracyReasoning,
  });

  factory QuestionScore.fromJson(Map<String, dynamic> json) {
    return QuestionScore(
      clarity: json['clarity'] as int? ?? 5,
      accuracy: json['accuracy'] as int? ?? 5,
      clarityReasoning:
          json['clarityReasoning'] as String? ?? 'No reasoning provided.',
      accuracyReasoning:
          json['accuracyReasoning'] as String? ?? 'No reasoning provided.',
    );
  }
}

class EvaluationResult {
  final List<QuestionScore> scores;

  EvaluationResult({required this.scores});

  int get averageClarity =>
      (scores.fold<int>(0, (sum, s) => sum + s.clarity) / scores.length)
          .round();

  int get averageAccuracy =>
      (scores.fold<int>(0, (sum, s) => sum + s.accuracy) / scores.length)
          .round();
}

class ApiService {
  Future<List<String>> fetchPracticePrompts({
    required String role,
    required String track,
    required String level,
    required int count,
  }) async {
    final model = GenerativeModel(
      model: dotenv.env['GEMINI_MODEL'] ?? 'gemini-2.5-flash',
      apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
    );

    final prompt = '''
Generate $count ${track.toLowerCase()} interview questions for a $role at $level.

Rules:
- If track is "technical", focus on domain knowledge, tools, methodologies, and problem-solving relevant to the role
- If track is "behavioral", focus on experience, teamwork, communication, and conflict resolution
- Tailor all questions specifically to the $role — avoid generic or coding-specific questions unless the role demands it
- Adjust difficulty to match the candidate level: Entry Level should be foundational, Intermediate should involve real scenarios, Experienced should challenge with complex edge cases
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

  Future<EvaluationResult> evaluateSession({
    required List<String> prompts,
    required List<String> answers,
  }) async {
    if (prompts.length != answers.length) {
      throw ApiException('Prompts and answers length mismatch');
    }

    final model = GenerativeModel(
      model: dotenv.env['GEMINI_MODEL'] ?? 'gemini-2.5-flash',
      apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
    );

    final qaText = prompts.asMap().entries.map((entry) {
      return 'Q${entry.key + 1}: ${entry.value}\nA${entry.key + 1}: ${answers[entry.key]}';
    }).join('\n\n');

    final evaluationPrompt = '''
Evaluate the following interview responses. For each Q&A pair, provide a clarity score (0-10), accuracy score (0-10), and brief reasoning (1-2 sentences) for each score.

$qaText

Return a JSON array with objects containing "clarity", "accuracy", "clarityReasoning", and "accuracyReasoning" keys. Do NOT include any other text, only the JSON array.
Example format:
[{"clarity": 8, "accuracy": 7, "clarityReasoning": "Answer was clear and well-structured.", "accuracyReasoning": "Demonstrated solid domain knowledge."}, {"clarity": 6, "accuracy": 5, "clarityReasoning": "Some unclear points.", "accuracyReasoning": "Missing some key concepts."}]
''';

    final response =
        await model.generateContent([Content.text(evaluationPrompt)]);

    if (response.text == null) {
      throw ApiException('Empty evaluation response');
    }

 try {
  String jsonText = response.text!.trim();
  
  // Strip markdown code fences if present
  if (jsonText.startsWith('```')) {
    jsonText = jsonText
        .replaceAll(RegExp(r'^```(?:json)?\s*', multiLine: false), '')
        .replaceAll(RegExp(r'\s*```$', multiLine: false), '')
        .trim();
  }
  
  final jsonArray = jsonDecode(jsonText) as List<dynamic>;
  final scores = jsonArray
      .map((item) => QuestionScore.fromJson(item as Map<String, dynamic>))
      .toList();
  return EvaluationResult(scores: scores);
} catch (e) {
  throw ApiException('Failed to parse evaluation response: $e');
}
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}
