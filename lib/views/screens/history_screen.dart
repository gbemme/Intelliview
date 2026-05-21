import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    
    // Agora fechando corretamente a função
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final appState = Provider.of<AppState>(context, listen: false);
        appState.loadHistory();
      }
    });
  } // <--- Esta chave estava faltando!

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Practice History')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.history.isEmpty
                ? const Center(child: Text('No history yet. Complete a practice session to save results.'))
                : ListView.separated(
                    itemCount: state.history.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final session = state.history[index];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text('${session.role} • ${session.track}'),
                          subtitle: Text('Clarity: ${session.clarity} | Pace: ${session.pace} | Accuracy: ${session.accuracy}'),
                          trailing: Text('${session.createdAt.day}/${session.createdAt.month}/${session.createdAt.year}'),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}