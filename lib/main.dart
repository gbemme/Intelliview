import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'firebase_options.dart'; // Este arquivo é gerado pelo 'flutterfire configure'
import 'state/app_state.dart';
import 'services/api_service.dart';
import 'repositories/history_repository.dart';

void main() async {
  // 1. Garante que as comunicações nativas (Windows/Android) estejam prontas
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Carrega as variáveis de ambiente (.env)
  await dotenv.load(fileName: '.env');

  // 3. Inicializa o Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 4. Injeta as dependências e o Estado Global no topo da árvore
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppState(
            apiService: ApiService(),
            historyRepository: HistoryRepository(),
          ),
        ),
      ],
      child: const IntelliViewApp(),
    ),
  );
}