class InterviewSession {
  final String id;
  final String role;
  final String track;
  final String transcript;
  final int clarity;
  final int pace;
  final int accuracy;
  final DateTime createdAt;

  InterviewSession({
    required this.id,
    required this.role,
    required this.track,
    required this.transcript,
    required this.clarity,
    required this.pace,
    required this.accuracy,
    required this.createdAt,
  });

  double get averageScore => (clarity + pace + accuracy) / 3.0;

  factory InterviewSession.fromJson(Map<String, dynamic> json) {
    return InterviewSession(
      id: json['id'] as String,
      role: json['role'] as String,
      track: json['track'] as String,
      transcript: json['transcript'] as String,
      clarity: json['clarity'] as int,
      pace: json['pace'] as int,
      accuracy: json['accuracy'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'track': track,
      'transcript': transcript,
      'clarity': clarity,
      'pace': pace,
      'accuracy': accuracy,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
