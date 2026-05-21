import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

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
      clarity: (json['clarity'] as num? ?? 5).toInt(),
      accuracy: (json['accuracy'] as num? ?? 5).toInt(),
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

  int get averageClarity {
    if (scores.isEmpty) return 0;
    return (scores.fold<int>(0, (sum, s) => sum + s.clarity) / scores.length).round();
  }

  int get averageAccuracy {
    if (scores.isEmpty) return 0;
    return (scores.fold<int>(0, (sum, s) => sum + s.accuracy) / scores.length).round();
  }
}

class ApiService {
  String _env(String key) => (dotenv.env[key] ?? '').trim();

  String _envOr(String key, String fallback) {
    final value = _env(key);
    return value.isEmpty ? fallback : value;
  }

  String get _geminiKey => _env('GEMINI_API_KEY');

  String get _groqKey => _env('GROQ_API_KEY');

  String get _geminiModel => _envOr('GEMINI_MODEL', 'gemini-1.5-flash');

  String get _groqModel => _envOr('GROQ_MODEL', 'openai/gpt-oss-120b');

  /// Gera conteúdo limpando qualquer formatação do Markdown (Usado externamente se necessário)
  Future<String> generateContent(String prompt) async {
    return _generateText(prompt);
  }

  Future<String> _generateGemini(String prompt) async {
    final model = GenerativeModel(
      model: _geminiModel,
      apiKey: _geminiKey,
    );

    final response = await model.generateContent([Content.text(prompt)]);
    final text = response.text?.trim();

    if (text == null || text.isEmpty) {
      throw ApiException('Empty Gemini response');
    }

    return text;
  }

  Future<String> _generateGroq(String prompt) async {
    final response = await http.post(
      Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_groqKey',
      },
      body: jsonEncode({
        'model': _groqModel,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'Groq request failed (${response.statusCode}): ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw ApiException('Groq response missing choices');
    }

    final message = (choices.first as Map<String, dynamic>)['message'] as Map?;
    final content = message?['content'] as String?;
    final text = content?.trim() ?? '';
    if (text.isEmpty) {
      throw ApiException('Groq response empty content');
    }

    return text;
  }

  /// Gerenciador centralizado de chamadas com Fallback e Limpeza de Resposta automática
  Future<String> _generateText(String prompt) async {
    final hasGemini = _geminiKey.isNotEmpty;
    final hasGroq = _groqKey.isNotEmpty;

    if (!hasGemini && !hasGroq) {
      throw ApiException('Missing GEMINI_API_KEY and GROQ_API_KEY. Please set at least one in your .env file.');
    }

    String rawResult = '';

    if (hasGemini) {
      try {
        rawResult = await _generateGemini(prompt);
      } catch (e) {
        if (hasGroq) {
          rawResult = await _generateGroq(prompt);
        } else {
          throw ApiException('Gemini request failed: $e');
        }
      }
    } else {
      rawResult = await _generateGroq(prompt);
    }

    return _cleanJsonResponse(rawResult);
  }

  /// Remove cabeçalhos de bloco de código (```json ... ```) de forma limpa
  String _cleanJsonResponse(String rawResponse) {
    String cleaned = rawResponse.trim();
    
    if (cleaned.startsWith('```')) {
      cleaned = cleaned.replaceFirst(RegExp(r'^```(json)?\s*'), '');
      cleaned = cleaned.replaceFirst(RegExp(r'\s*```$'), '');
    }
    
    return cleaned.trim();
  }

  EvaluationResult _parseEvaluationResult(String jsonText) {
    try {
      final jsonArray = jsonDecode(jsonText) as List<dynamic>;
      final scores = jsonArray
          .map((item) => QuestionScore.fromJson(item as Map<String, dynamic>))
          .toList();
      return EvaluationResult(scores: scores);
    } catch (e) {
      throw ApiException('Failed to parse evaluation response: $e');
    }
  }

  Future<List<String>> fetchPracticePrompts({
    required String role,
    required String track,
    required String level,
    required int count,
  }) async {
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

    final responseText = await _generateText(prompt);

    return responseText
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

    // Chama o gerador centralizado que já garante tratamento de fallback e limpeza do JSON
    final jsonText = await _generateText(evaluationPrompt);
    return _parseEvaluationResult(jsonText);
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}