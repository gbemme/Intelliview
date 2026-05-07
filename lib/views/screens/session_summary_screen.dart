import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/interview_session.dart';
import '../../models/question_response.dart';
import '../../routes.dart';
import '../../services/api_service.dart';
import '../../state/app_state.dart';
import '../widgets/radar_chart.dart';

class SessionSummaryScreen extends StatefulWidget {
  const SessionSummaryScreen({super.key});

  @override
  State<SessionSummaryScreen> createState() => _SessionSummaryScreenState();
}

class _SessionSummaryScreenState extends State<SessionSummaryScreen> {
  late InterviewSession _session;
  InterviewSession? _evaluatedSession;
  String? _error;
  bool _isEvaluating = false;

  static const Color _bg = Color(0xFF0F0E17);
  static const Color _surface = Color(0xFF1A1829);
  static const Color _card = Color(0xFF211F35);
  static const Color _accent = Color(0xFF6C63FF);
  static const Color _accentAlt = Color(0xFFFF6584);
  static const Color _textPrimary = Color(0xFFF4F3FF);
  static const Color _textMuted = Color(0xFF9896B0);
  static const Color _border = Color(0xFF2E2C45);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _session = ModalRoute.of(context)!.settings.arguments as InterviewSession;
    if (_evaluatedSession == null && !_isEvaluating) {
      _evaluateSession();
    }
  }

  Future<void> _evaluateSession() async {
    setState(() {
      _isEvaluating = true;
      _error = null;
    });

    try {
      final apiService = ApiService();

      final prompts =
          _session.questionResponses?.map((qr) => qr.prompt).toList() ?? [];
      final answers =
          _session.questionResponses?.map((qr) => qr.answer).toList() ?? [];

      if (prompts.isEmpty || answers.isEmpty) {
        throw Exception('No question responses available');
      }

      final evaluation = await apiService.evaluateSession(
        prompts: prompts,
        answers: answers,
      );

      final pace = _calculatePace(_session.questionResponses ?? []);

      final updatedQuestionResponses =
          (_session.questionResponses ?? []).asMap().entries.map((entry) {
        final index = entry.key;
        final qr = entry.value;
        final score =
            index < evaluation.scores.length ? evaluation.scores[index] : null;
        return QuestionResponse(
          prompt: qr.prompt,
          answer: qr.answer,
          durationSeconds: qr.durationSeconds,
          clarityScore: score?.clarity,
          accuracyScore: score?.accuracy,
          clarityReasoning: score?.clarityReasoning,
          accuracyReasoning: score?.accuracyReasoning,
        );
      }).toList();

      final evaluatedSession = InterviewSession(
        id: _session.id,
        role: _session.role,
        track: _session.track,
        transcript: _session.transcript,
        clarity: evaluation.averageClarity,
        pace: pace,
        accuracy: evaluation.averageAccuracy,
        createdAt: _session.createdAt,
        questionResponses: updatedQuestionResponses,
      );

      setState(() {
        _evaluatedSession = evaluatedSession;
        _isEvaluating = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isEvaluating = false;
      });
    }
  }

  int _calculatePace(List<dynamic> questionResponses) {
    if (questionResponses.isEmpty) return 5;

    int slowCount = 0;
    for (var qr in questionResponses) {
      if (qr.durationSeconds > 60) {
        slowCount++;
      }
    }

    return (10 - slowCount).clamp(0, 10);
  }

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year;
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day-$month-$year $hour:$minute';
  }

  Future<void> _tryAgain() async {
    Navigator.pushReplacementNamed(context, AppRoutes.practice);
  }

  @override
  Widget build(BuildContext context) {
    final displaySession = _evaluatedSession ?? _session;
    final isReady = _evaluatedSession != null;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        title: const Text(
          'Session Summary',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        leading: GestureDetector(
          onTap: () => Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.onboarding,
            (route) => false,
          ),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: const Icon(Icons.home_rounded, color: _textMuted, size: 18),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Decorative blobs
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accent.withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accentAlt.withOpacity(0.08),
              ),
            ),
          ),
          SafeArea(
            child: _isEvaluating
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: _accent),
                        const SizedBox(height: 16),
                        Text(
                          'Analyzing your responses...',
                          style: const TextStyle(
                            color: _textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline_rounded,
                                  size: 56, color: _accentAlt),
                              const SizedBox(height: 16),
                              Text(
                                'Evaluation Error',
                                style: const TextStyle(
                                  color: _textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: _textMuted,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _evaluatedSession = null;
                                    _error = null;
                                  });
                                  _evaluateSession();
                                },
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _accent,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 24),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Finished ${displaySession.track} interview practice for ${displaySession.role} role',
                              style: const TextStyle(
                                color: _textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Completed at ${_formatDateTime(displaySession.createdAt)}',
                              style: const TextStyle(
                                color: _textMuted,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Center(
                              child: RadarChart(
                                clarity: displaySession.clarity,
                                pace: displaySession.pace,
                                accuracy: displaySession.accuracy,
                              ),
                            ),
                            const SizedBox(height: 32),
                            _buildExpandableMetricCard(
                              'Clarity',
                              displaySession.clarity,
                              displaySession.questionResponses ?? [],
                              'clarity',
                            ),
                            _buildExpandableMetricCard(
                              'Pace',
                              displaySession.pace,
                              displaySession.questionResponses ?? [],
                              'pace',
                            ),
                            _buildExpandableMetricCard(
                              'Accuracy',
                              displaySession.accuracy,
                              displaySession.questionResponses ?? [],
                              'accuracy',
                            ),
                            const SizedBox(height: 32),
                            if (isReady)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ElevatedButton(
                                    onPressed: _tryAgain,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _accent,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size.fromHeight(52),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text(
                                      'Try Again',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  OutlinedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, AppRoutes.history);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: _border, width: 1),
                                      minimumSize: const Size.fromHeight(52),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text(
                                      'View Practice History',
                                      style: TextStyle(
                                        color: _textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableMetricCard(
    String label,
    int score,
    List<dynamic> questionResponses,
    String metricType,
  ) {
    return StatefulBuilder(
      builder: (context, setCardState) {
        bool isExpanded = false;

        return StatefulBuilder(
          builder: (context, setLocalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () =>
                          setLocalState(() => isExpanded = !isExpanded),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              label,
                              style: const TextStyle(
                                color: _textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _accent.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$score / 10',
                                    style: const TextStyle(
                                      color: _accent,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  isExpanded
                                      ? Icons.expand_less_rounded
                                      : Icons.expand_more_rounded,
                                  color: _textMuted,
                                  size: 20,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 1,
                              color: _border,
                              margin: const EdgeInsets.only(bottom: 16),
                            ),
                            ...List.generate(
                              questionResponses.length,
                              (index) {
                                final qr = questionResponses[index];
                                if (metricType == 'clarity') {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: _accent.withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '${qr.clarityScore ?? 5} / 10',
                                                style: const TextStyle(
                                                  color: _accent,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              qr.prompt,
                                              style: const TextStyle(
                                                color: _textPrimary,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Your Answer',
                                              style: TextStyle(
                                                color: _textMuted,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.4,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              qr.answer,
                                              style: const TextStyle(
                                                color: _textPrimary,
                                                fontSize: 12,
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          qr.clarityReasoning ??
                                              'No reasoning provided.',
                                          style: const TextStyle(
                                            color: _textMuted,
                                            fontSize: 12,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else if (metricType == 'accuracy') {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: _accent.withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '${qr.accuracyScore ?? 5} / 10',
                                                style: const TextStyle(
                                                  color: _accent,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              qr.prompt,
                                              style: const TextStyle(
                                                color: _textPrimary,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Your Answer',
                                              style: TextStyle(
                                                color: _textMuted,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.4,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              qr.answer,
                                              style: const TextStyle(
                                                color: _textPrimary,
                                                fontSize: 12,
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          qr.accuracyReasoning ??
                                              'No reasoning provided.',
                                          style: const TextStyle(
                                            color: _textMuted,
                                            fontSize: 12,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  final minutes = qr.durationSeconds ~/ 60;
                                  final seconds = qr.durationSeconds % 60;
                                  final timeStr = '${minutes}m ${seconds}s';
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                qr.prompt,
                                                style: const TextStyle(
                                                  color: _textPrimary,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              timeStr,
                                              style: const TextStyle(
                                                color: _textMuted,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMetricTile(String label, int score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$score / 10',
                style: const TextStyle(
                  color: _accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
