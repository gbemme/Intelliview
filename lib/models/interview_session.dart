import 'package:cloud_firestore/cloud_firestore.dart';
import 'question_response.dart';

class InterviewSession {
  final String id;
  final String role;
  final String track;
  final String transcript;
  final int clarity;
  final int pace;
  final int accuracy;
  final DateTime createdAt;
  final List<QuestionResponse>? questionResponses;

  InterviewSession({
    required this.id,
    required this.role,
    required this.track,
    required this.transcript,
    required this.clarity,
    required this.pace,
    required this.accuracy,
    required this.createdAt,
    this.questionResponses,
  });

  // --- FIREBASE (FIRESTORE) ---
  factory InterviewSession.fromFirestore(Map<String, dynamic> data, String id) {
    return InterviewSession(
      id: id,
      role: data['role'] ?? '',
      track: data['track'] ?? '',
      transcript: data['transcript'] ?? '',
      accuracy: (data['accuracy'] as num? ?? 0).toInt(),
      clarity: (data['clarity'] as num? ?? 0).toInt(),
      pace: (data['pace'] as num? ?? 0).toInt(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      questionResponses: (data['questionResponses'] as List<dynamic>?)
          ?.map((item) => QuestionResponse.fromMap(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'role': role,
      'track': track,
      'transcript': transcript,
      'clarity': clarity,
      'pace': pace,
      'accuracy': accuracy,
      'createdAt': Timestamp.fromDate(createdAt),
      'questionResponses': questionResponses?.map((item) => item.toMap()).toList(),
    };
  }

  // --- LOCAL STORAGE (JSON) ---
  double get averageScore => (clarity + pace + accuracy) / 3.0;

  factory InterviewSession.fromJson(Map<String, dynamic> json) {
    return InterviewSession(
      id: json['id'] as String? ?? '',
      role: json['role'] as String? ?? '',
      track: json['track'] as String? ?? '',
      transcript: json['transcript'] as String? ?? '',
      clarity: json['clarity'] as int? ?? 0,
      pace: json['pace'] as int? ?? 0,
      accuracy: json['accuracy'] as int? ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : DateTime.now(),
      questionResponses: (json['questionResponses'] as List<dynamic>?)
          ?.map((item) => QuestionResponse.fromMap(item as Map<String, dynamic>))
          .toList(),
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
      'questionResponses': questionResponses?.map((item) => item.toMap()).toList(),
    };
  }
}