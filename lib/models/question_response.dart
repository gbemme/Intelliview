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

  factory QuestionResponse.fromJson(Map<String, dynamic> json) {
    return QuestionResponse(
      prompt: json['prompt'] as String,
      answer: json['answer'] as String,
      durationSeconds: json['durationSeconds'] as int,
      clarityScore: json['clarityScore'] as int?,
      accuracyScore: json['accuracyScore'] as int?,
      clarityReasoning: json['clarityReasoning'] as String?,
      accuracyReasoning: json['accuracyReasoning'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
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
}
