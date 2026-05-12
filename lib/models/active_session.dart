class ActiveSession {
  final String role;
  final String track;
  final String level;
  final List<String> prompts;
  final List<String> answers;
  final int currentIndex;
  final DateTime? questionStartedAt;
  final Map<int, int> durationsByQuestionIndex;

  ActiveSession({
    required this.role,
    required this.track,
    required this.level,
    required this.prompts,
    required this.answers,
    required this.currentIndex,
    this.questionStartedAt,
    this.durationsByQuestionIndex = const {},
  });

  factory ActiveSession.fromJson(Map<String, dynamic> json) {
    return ActiveSession(
      role: json['role'],
      track: json['track'],
      level: json['level'] ?? 'Intermediate',
      prompts: List<String>.from(json['prompts']),
      answers: List<String>.from(json['answers']),
      currentIndex: json['currentIndex'],
      questionStartedAt: json['questionStartedAt'] != null
          ? DateTime.parse(json['questionStartedAt'] as String)
          : null,
      durationsByQuestionIndex: (json['durationsByQuestionIndex']
                  as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(int.parse(key), value as int)) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'level': level,
      'track': track,
      'prompts': prompts,
      'answers': answers,
      'currentIndex': currentIndex,
      'questionStartedAt': questionStartedAt?.toIso8601String(),
      'durationsByQuestionIndex': durationsByQuestionIndex
          .map((key, value) => MapEntry(key.toString(), value)),
    };
  }
}
