import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/interview_session.dart';

class HistoryRepository {
  // Referência para a instância do Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Referência para a coleção principal
  final CollectionReference _sessionCollection = 
      FirebaseFirestore.instance.collection('sessions');

  // ID fixo para desenvolvimento (já que removemos o Login)
  final String _localUserId = "local_developer_user";

  /// Carrega o histórico completo do Firebase
  Future<List<InterviewSession>> loadHistory() async {
    try {
      // Buscamos todos os documentos. 
      // Se quiser filtrar por usuário no futuro, use: .where('userId', isEqualTo: _localUserId)
      QuerySnapshot querySnapshot = await _sessionCollection
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        // Usamos o fromFirestore que criamos para mapear o ID e os dados
        return InterviewSession.fromFirestore(
          doc.data() as Map<String, dynamic>, 
          doc.id,
        );
      }).toList();
    } catch (e) {
      print("Erro ao carregar histórico do Firebase: $e");
      // Retorna lista vazia para não quebrar o App em caso de erro de rede
      return [];
    }
  }

  /// Salva uma nova sessão no Firebase
  Future<void> saveSession(InterviewSession session) async {
    try {
      // Converte o modelo para Map
      final Map<String, dynamic> sessionData = session.toFirestore();
      
      // Adiciona o userId fixo para manter a organização
      sessionData['userId'] = _localUserId;

      // Se o campo createdAt não existir no modelo, garantimos que ele vá com a hora atual
      sessionData['createdAt'] ??= FieldValue.serverTimestamp();

      await _sessionCollection.add(sessionData);
      print("Sessão salva com sucesso no Firestore!");
    } catch (e) {
      print("Erro ao salvar sessão no Firebase: $e");
      throw Exception("Falha ao salvar sessão: $e");
    }
  }
}