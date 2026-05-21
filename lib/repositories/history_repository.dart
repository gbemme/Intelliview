import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/interview_session.dart';

class HistoryRepository {
  // Referência para a instância do Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Referência para a coleção principal
  final CollectionReference _sessionCollection = 
      FirebaseFirestore.instance.collection('sessions');

  // ID fixo para desenvolvimento (conforme o seu código original)
  final String _localUserId = "local_developer_user";

  /// Carrega o histórico completo (Busca única via Future)
  Future<List<InterviewSession>> loadHistory() async {
    try {
      QuerySnapshot querySnapshot = await _sessionCollection
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return InterviewSession.fromFirestore(
          doc.data() as Map<String, dynamic>, 
          doc.id,
        );
      }).toList();
    } catch (e) {
      print("Erro ao carregar histórico do Firebase: $e");
      return [];
    }
  }

  /// Retorna um Stream em tempo real da coleção 'sessions'
  /// Isso resolve o erro de "method getSessionsStream isn't defined"
  Stream<List<InterviewSession>> getSessionsStream() {
    print("🛰️ Ligando escuta em tempo real com Firestore...");
    return _sessionCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            try {
              return InterviewSession.fromFirestore(
                doc.data() as Map<String, dynamic>, 
                doc.id,
              );
            } catch (e) {
              print("❌ Erro ao converter documento ${doc.id}: $e");
              return InterviewSession(
                id: doc.id,
                role: 'Erro de conversão',
                track: '',
                transcript: '',
                clarity: 0,
                pace: 0,
                accuracy: 0,
                createdAt: DateTime.now(),
              );
            }
          }).toList();
        });
  }

  /// Salva uma nova sessão no Firebase
  Future<void> saveSession(InterviewSession session) async {
    try {
      final Map<String, dynamic> sessionData = session.toFirestore();
      
      sessionData['userId'] = _localUserId;
      sessionData['createdAt'] ??= FieldValue.serverTimestamp();

      await _sessionCollection.add(sessionData);
      print("✅ Sessão salva com sucesso no Firestore!");
    } catch (e) {
      print("❌ Erro ao salvar sessão: $e");
      throw Exception("Falha ao salvar sessão: $e");
    }
  }
}