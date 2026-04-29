import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes.dart';
import 'services/api_service.dart';
import 'repositories/history_repository.dart';
import 'state/app_state.dart';
import 'views/screens/history_screen.dart';
import 'views/screens/onboarding_screen.dart';
import 'views/screens/practice_session_screen.dart';
import 'views/screens/session_summary_screen.dart';

class IntelliViewApp extends StatelessWidget {
  const IntelliViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(
        apiService: ApiService(),
        historyRepository: HistoryRepository(),
      ),
      child: MaterialApp(
        title: 'IntelliView',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        initialRoute: AppRoutes.onboarding,
        routes: {
          AppRoutes.onboarding: (_) => const OnboardingScreen(),
          AppRoutes.practice: (_) => const PracticeSessionScreen(),
          AppRoutes.summary: (_) => const SessionSummaryScreen(),
          AppRoutes.history: (_) => const HistoryScreen(),
        },
      ),
    );
  }
}
