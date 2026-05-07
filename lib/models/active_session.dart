class ActiveSession {
  final String role;
  final String track;
  final List<String> prompts;
  final List<String> answers;
  final int currentIndex;

  ActiveSession({
    required this.role,
    required this.track,
    required this.prompts,
    required this.answers,
    required this.currentIndex,
  });

  factory ActiveSession.fromJson(Map<String, dynamic> json) {
    return ActiveSession(
      role: json['role'],
      track: json['track'],
      prompts: List<String>.from(json['prompts']),
      answers: List<String>.from(json['answers']),
      currentIndex: json['currentIndex'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'track': track,
      'prompts': prompts,
      'answers': answers,
      'currentIndex': currentIndex,
    };
  }
}