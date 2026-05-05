import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/interview_session.dart';
import '../../routes.dart';
import '../../state/app_state.dart';
import '../widgets/radar_chart.dart';

class SessionSummaryScreen extends StatelessWidget {
  const SessionSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = ModalRoute.of(context)!.settings.arguments as InterviewSession;
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Session Summary')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Finished ${session.track} practice for ${session.role}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Recorded at ${session.createdAt.toLocal()}', style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 24),
            Center(
              child: RadarChart(
                clarity: session.clarity,
                pace: session.pace,
                accuracy: session.accuracy,
              ),
            ),
            const SizedBox(height: 24),
            _buildMetricTile('Clarity', session.clarity),
            _buildMetricTile('Pace', session.pace),
            _buildMetricTile('Technical Accuracy', session.accuracy),
            const Spacer(),
            if (state.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                    
                    },
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                    child: const Text('Save & Share Results'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.history);
                    },
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                    child: const Text('View Practice History'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, int score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.grey.shade100,
        title: Text(label),
        trailing: Text('$score / 10', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
