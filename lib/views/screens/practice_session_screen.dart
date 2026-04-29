import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/interview_session.dart';
import '../../routes.dart';
import '../../services/speech_service.dart';
import '../../state/app_state.dart';

class PracticeSessionScreen extends StatefulWidget {
  const PracticeSessionScreen({super.key});

  @override
  State<PracticeSessionScreen> createState() => _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends State<PracticeSessionScreen> {
  final SpeechService _speechService = SpeechService();
  final _transcriptController = TextEditingController();
  bool _isReady = false;
  bool _isRecording = false;
  List<String> _prompts = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _loadPrompts();
  }

  Future<void> _initializeSpeech() async {
    final initialized = await _speechService.initialize();
    if (!initialized) {
      setState(() {
        _error = 'Voice recording is unavailable on this device.';
      });
    } else {
      setState(() => _isReady = true);
    }
  }

  Future<void> _loadPrompts() async {
    final state = context.read<AppState>();
    try {
      final prompts = await state.loadPracticePrompts();
      setState(() {
        _prompts = prompts;
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
      });
    }
  }

  Future<void> _toggleRecording() async {
    if (!_isRecording) {
      setState(() {
        _transcriptController.text = '';
        _isRecording = true;
      });
      await _speechService.startListening(onResult: (recognizedText) {
        setState(() {
          _transcriptController.text = recognizedText;
        });
      });
    } else {
      await _speechService.stopListening();
      setState(() => _isRecording = false);
    }
  }

  void _finishSession() {
    final role = context.read<AppState>().selectedRole;
    final track = context.read<AppState>().selectedTrack;
    if (role == null || track == null) {
      Navigator.pop(context);
      return;
    }

    final transcript = _transcriptController.text.trim();
    if (transcript.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please record at least one answer before finishing.')),
      );
      return;
    }

    final session = InterviewSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: role,
      track: track,
      transcript: transcript,
      clarity: _scoreClarity(transcript),
      pace: _scorePace(transcript),
      accuracy: _scoreAccuracy(transcript),
      createdAt: DateTime.now(),
    );

    Navigator.pushNamed(
      context,
      AppRoutes.summary,
      arguments: session,
    );
  }

  int _scoreClarity(String transcript) {
    final length = transcript.split(' ').length;
    if (length < 20) return 6;
    if (length < 40) return 8;
    return 9;
  }

  int _scorePace(String transcript) {
    final wordCount = transcript.split(' ').length;
    return (10 - (wordCount / 8)).clamp(4, 10).round();
  }

  int _scoreAccuracy(String transcript) {
    final commonWords = ['architecture', 'testing', 'design', 'metrics'];
    final matches = commonWords.where((word) => transcript.contains(word)).length;
    return (6 + matches * 2).clamp(5, 10).round();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final role = state.selectedRole ?? 'Unknown role';
    final track = state.selectedTrack ?? 'Unknown track';

    return Scaffold(
      appBar: AppBar(title: const Text('Practice Session')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Role: $role', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Track: $track', style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 16),
            const Text('Prompt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red))
            else if (_prompts.isEmpty)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _prompts
                    .map((prompt) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            color: Colors.blue.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(prompt),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _transcriptController,
              maxLines: 8,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Live transcript',
                hintText: 'Your voice input appears here',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(_isRecording ? Icons.mic_off : Icons.mic),
              label: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
              onPressed: _isReady ? _toggleRecording : null,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _finishSession,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              child: const Text('Finish Interview'),
            ),
          ],
        ),
      ),
    );
  }
}
