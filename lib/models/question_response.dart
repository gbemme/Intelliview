class QuestionResponse {
  final String prompt;
  final String answer;
  final int durationSeconds;
  final int? clarityScore;
  final int? accuracyScore;
  final String? clarityReasoning;
  final String? accuracyReasoning;

  QuestionResponse({
    required this.prompt,
    required this.answer,
    required this.durationSeconds,
    this.clarityScore,
    this.accuracyScore,
    this.clarityReasoning,
    this.accuracyReasoning,
  });

  // --- MÉTODOS PARA FIREBASE (FIRESTORE) ---
  
  factory QuestionResponse.fromMap(Map<String, dynamic> map) {
    return QuestionResponse(
      // Flexibilidade para ler tanto 'prompt' quanto 'question'
      prompt: map['prompt'] ?? map['question'] ?? '',
      answer: map['answer'] ?? '',
      // Conversão segura de num para int (essencial para Web/Chrome)
      durationSeconds: (map['durationSeconds'] as num? ?? 0).toInt(),
      clarityScore: map['clarityScore'] != null ? (map['clarityScore'] as num).toInt() : null,
      accuracyScore: map['accuracyScore'] != null ? (map['accuracyScore'] as num).toInt() : null,
      clarityReasoning: map['clarityReasoning'] as String?,
      accuracyReasoning: map['accuracyReasoning'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'prompt': prompt,
      'answer': answer,
      'durationSeconds': durationSeconds,
      'clarityScore': clarityScore,
      'accuracyScore': accuracyScore,
      'clarityReasoning': clarityReasoning,
      'accuracyReasoning': accuracyReasoning,
    };
  }

  // --- MÉTODOS PARA JSON LOCAL (SHARED PREFERENCES) ---

  factory QuestionResponse.fromJson(Map<String, dynamic> json) {
    return QuestionResponse.fromMap(json);
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }
}