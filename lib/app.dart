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
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C63FF),
            brightness: Brightness.dark,
          ).copyWith(
            surface: const Color(0xFF1A1829),
            onSurface: const Color(0xFFF4F3FF),
          ),
          scaffoldBackgroundColor: const Color(0xFF0F0E17),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1A1829),
            foregroundColor: Color(0xFFF4F3FF),
            elevation: 0,
            titleTextStyle: TextStyle(
              color: Color(0xFFF4F3FF),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          cardColor: const Color(0xFF211F35),
          dialogTheme: const DialogThemeData(
            backgroundColor: Color(0xFF1A1829),
          ),
          dividerColor: const Color(0xFF2E2C45),
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
