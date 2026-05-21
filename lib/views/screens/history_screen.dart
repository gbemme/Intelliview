import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/interview_session.dart';
import '../../state/app_state.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const Color _bg = Color(0xFF0F0E17);
  static const Color _surface = Color(0xFF1A1829);
  static const Color _accent = Color(0xFF6C63FF);
  static const Color _accentAlt = Color(0xFFFF6584);
  static const Color _textPrimary = Color(0xFFF4F3FF);
  static const Color _textMuted = Color(0xFF9896B0);
  static const Color _border = Color(0xFF2E2C45);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AppState>().loadHistory();
    });
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    final months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    final hour = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '${months[local.month - 1]} ${local.day}, ${local.year} · $hour:$min';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Decorative blob top-right
          Positioned(
            top: -60,
            right: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accent.withValues(alpha: 0.12),
              ),
            ),
          ),
          // Decorative blob bottom-left
          Positioned(
            bottom: 60,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accentAlt.withValues(alpha: 0.08),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(context),
                Expanded(
                  child: _buildBody(state),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _textMuted, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Practice History',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Your past interview sessions',
                  style: TextStyle(color: _textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.history_rounded,
                color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AppState state) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF6C63FF),
              strokeWidth: 2.5,
            ),
            SizedBox(height: 16),
            Text(
              'Loading history...',
              style: TextStyle(color: _textMuted, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _accentAlt.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline_rounded,
                    color: _accentAlt, size: 30),
              ),
              const SizedBox(height: 16),
              const Text(
                'Could not load history',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: _textMuted, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  state.clearError();
                  state.loadHistory();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 12),
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded,
                          color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Try Again',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.history.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.assignment_outlined,
                    color: _accent, size: 32),
              ),
              const SizedBox(height: 20),
              const Text(
                'No sessions yet',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Complete a practice session to\nsee your results here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _textMuted, fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      itemCount: state.history.length,
      itemBuilder: (context, index) =>
          _SessionCard(session: state.history[index], formatDate: _formatDate),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SessionCard extends StatelessWidget {
  final InterviewSession session;
  final String Function(DateTime) formatDate;

  const _SessionCard({required this.session, required this.formatDate});

  static const Color _card = Color(0xFF211F35);
  static const Color _accent = Color(0xFF6C63FF);
  static const Color _teal = Color(0xFF00C9A7);
  static const Color _textPrimary = Color(0xFFF4F3FF);
  static const Color _textMuted = Color(0xFF9896B0);
  static const Color _border = Color(0xFF2E2C45);

  Color get _trackColor =>
      session.track.toLowerCase() == 'behavioral' ? _teal : _accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _trackColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  session.track.toLowerCase() == 'behavioral'
                      ? Icons.people_alt_rounded
                      : Icons.psychology_rounded,
                  color: _trackColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.role,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _trackColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            session.track,
                            style: TextStyle(
                              color: _trackColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                formatDate(session.createdAt),
                style: const TextStyle(color: _textMuted, fontSize: 11),
              ),
            ],
          ),

          // ── Divider ─────────────────────────────────────────
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 14),
            color: _border,
          ),

          // ── Score row ────────────────────────────────────────
          Row(
            children: [
              _ScoreBadge(label: 'Clarity', score: session.clarity),
              const SizedBox(width: 10),
              _ScoreBadge(label: 'Pace', score: session.pace),
              const SizedBox(width: 10),
              _ScoreBadge(label: 'Accuracy', score: session.accuracy),
              const Spacer(),
              _AverageChip(
                average: ((session.clarity + session.pace + session.accuracy) / 3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final String label;
  final int score;
  const _ScoreBadge({required this.label, required this.score});

  static const Color _surface = Color(0xFF1A1829);
  static const Color _textMuted = Color(0xFF9896B0);
  static const Color _border = Color(0xFF2E2C45);

  Color _scoreColor(int s) {
    if (s >= 8) return const Color(0xFF00C9A7);
    if (s >= 5) return const Color(0xFF6C63FF);
    return const Color(0xFFFF6584);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Column(
          children: [
            Text(
              '$score',
              style: TextStyle(
                color: _scoreColor(score),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                  color: _textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _AverageChip extends StatelessWidget {
  final double average;
  const _AverageChip({required this.average});

  @override
  Widget build(BuildContext context) {
    final rounded = average.round();
    Color color;
    if (rounded >= 8) {
      color = const Color(0xFF00C9A7);
    } else if (rounded >= 5) {
      color = const Color(0xFF6C63FF);
    } else {
      color = const Color(0xFFFF6584);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$rounded/10',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            'avg',
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
