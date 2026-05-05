import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/interview_session.dart';
import '../../routes.dart';
import '../../services/speech_service.dart';
import '../../state/app_state.dart';
import '../../repositories/active_session_repository.dart';
import '../../models/active_session.dart';

class PracticeSessionScreen extends StatefulWidget {
  const PracticeSessionScreen({super.key});

  @override
  State<PracticeSessionScreen> createState() => _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends State<PracticeSessionScreen>
    with TickerProviderStateMixin {
  // ── Services & repos ───────────────────────────────────────────────────────
  final SpeechService _speechService = SpeechService();
  final _transcriptController = TextEditingController();
  final _sessionRepo = ActiveSessionRepository();

  // ── State ──────────────────────────────────────────────────────────────────
  bool _isReady = false;
  bool _isRecording = false;
  String? _error;
  List<String> _prompts = [];
  List<String> _answers = [];
  int _currentIndex = 0;

  // ── Animations ─────────────────────────────────────────────────────────────
  late AnimationController _pulseController;
  late AnimationController _questionSlideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _questionSlideAnimation;
  late Animation<double> _questionFadeAnimation;

  // ── Palette ────────────────────────────────────────────────────────────────
  static const Color _bg          = Color(0xFF0F0E17);
  static const Color _surface     = Color(0xFF1A1829);
  static const Color _card        = Color(0xFF211F35);
  static const Color _accent      = Color(0xFF6C63FF);
  static const Color _accentAlt   = Color(0xFFFF6584);
  static const Color _teal        = Color(0xFF00C9A7);
  static const Color _textPrimary = Color(0xFFF4F3FF);
  static const Color _textMuted   = Color(0xFF9896B0);
  static const Color _border      = Color(0xFF2E2C45);

  @override
  void initState() {
    super.initState();

    // Pulse for mic button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Slide + fade for question transitions
    _questionSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _questionSlideAnimation = Tween<Offset>(
      begin: const Offset(0.06, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _questionSlideController, curve: Curves.easeOut));
    _questionFadeAnimation = CurvedAnimation(
        parent: _questionSlideController, curve: Curves.easeOut);
    _questionSlideController.forward();

    _initializeSpeech();
    _loadPrompts();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _questionSlideController.dispose();
    _transcriptController.dispose();
    super.dispose();
  }

  // ── Logic (unchanged from original) ────────────────────────────────────────
  Future<void> _initializeSpeech() async {
    final initialized = await _speechService.initialize();
    setState(() {
      _isReady = initialized;
      if (!initialized) _error = 'Voice recording unavailable.';
    });
  }

  Future<void> _loadPrompts() async {
    try {
      final saved = await _sessionRepo.load();
      if (saved != null) {
        setState(() {
          _prompts = saved.prompts;
          _answers = saved.answers;
          _currentIndex = saved.currentIndex;
          _transcriptController.text = _answers[_currentIndex];
        });
        return;
      }
      final state = context.read<AppState>();
      final prompts = await state.loadPracticePrompts();
      setState(() {
        _prompts = prompts;
        _answers = List.filled(prompts.length, '');
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _toggleRecording() async {
    if (!_isRecording) {
      setState(() => _isRecording = true);
      _pulseController.repeat(reverse: true);
      await _speechService.startListening(onResult: (text) {
        setState(() {
          _answers[_currentIndex] = text;
          _transcriptController.text = text;
        });
      });
      await _saveSession();
    } else {
      await _speechService.stopListening();
      _pulseController
        ..stop()
        ..animateTo(0);
      setState(() => _isRecording = false);
    }
  }

  void _animateQuestion(VoidCallback change) {
    _questionSlideController.reset();
    setState(change);
    _questionSlideController.forward();
  }

  void _goNext() {
    if (_currentIndex < _prompts.length - 1) {
      _animateQuestion(() {
        _currentIndex++;
        _transcriptController.text = _answers[_currentIndex];
      });
      _saveSession();
    }
  }

  void _goPrevious() {
    if (_currentIndex > 0) {
      _animateQuestion(() {
        _currentIndex--;
        _transcriptController.text = _answers[_currentIndex];
      });
      _saveSession();
    }
  }

  void _finishSession() {
    final state = context.read<AppState>();
    final role = state.selectedRole;
    final track = state.selectedTrack;
    if (role == null || track == null) return;

    final transcript = _answers.join('\n\n');
    if (transcript.trim().isEmpty) {
      _showSnack('Answer at least one question first');
      return;
    }

    final session = InterviewSession(
      id: DateTime.now().toString(),
      role: role,
      track: track,
      transcript: transcript,
      clarity: _scoreClarity(transcript),
      pace: _scorePace(transcript),
      accuracy: _scoreAccuracy(transcript),
      createdAt: DateTime.now(),
    );

    Navigator.pushNamed(context, AppRoutes.summary, arguments: session);
    _sessionRepo.clear();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: const TextStyle(color: _textPrimary, fontSize: 13)),
        backgroundColor: _card,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  int _scoreClarity(String text) => text.split(' ').length < 30 ? 7 : 9;
  int _scorePace(String text) =>
      (10 - (text.split(' ').length / 10)).clamp(4, 10).round();
  int _scoreAccuracy(String text) {
    final keywords = ['design', 'architecture', 'testing', 'performance'];
    final matches = keywords.where((k) => text.contains(k)).length;
    return (6 + matches * 2).clamp(5, 10).round();
  }

  Future<void> _saveSession() async {
    final state = context.read<AppState>();
    final session = ActiveSession(
      role: state.selectedRole!,
      track: state.selectedTrack!,
      prompts: _prompts,
      answers: _answers,
      currentIndex: _currentIndex,
    );
    await _sessionRepo.save(session);
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final role  = state.selectedRole ?? '';
    final track = state.selectedTrack ?? '';

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
                color: _accent.withOpacity(0.14),
              ),
            ),
          ),
          // Decorative blob bottom-left
          Positioned(
            bottom: 40,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accentAlt.withOpacity(0.10),
              ),
            ),
          ),

          SafeArea(
            child: _error != null
                ? _ErrorView(message: _error!)
                : _prompts.isEmpty
                    ? const _LoadingView()
                    : Column(
                        children: [
                          // ── Top bar ──────────────────────────────────
                          _TopBar(role: role, track: track),

                          // ── Progress ─────────────────────────────────
                          _ProgressSection(
                            current: _currentIndex + 1,
                            total: _prompts.length,
                            answers: _answers,
                          ),

                          // ── Question card (scrollable area) ──────────
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20),
                              child: Column(
                                children: [
                                  const SizedBox(height: 8),
                                  // Question
                                  FadeTransition(
                                    opacity: _questionFadeAnimation,
                                    child: SlideTransition(
                                      position: _questionSlideAnimation,
                                      child: _QuestionCard(
                                        text: _prompts[_currentIndex],
                                        index: _currentIndex,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Answer field
                                  _AnswerField(
                                    controller: _transcriptController,
                                    isRecording: _isRecording,
                                  ),
                                  const SizedBox(height: 120),
                                ],
                              ),
                            ),
                          ),

                          // ── Bottom controls ───────────────────────────
                          _BottomBar(
                            currentIndex: _currentIndex,
                            total: _prompts.length,
                            isReady: _isReady,
                            isRecording: _isRecording,
                            pulseAnimation: _pulseAnimation,
                            onPrevious: _goPrevious,
                            onNext: _goNext,
                            onFinish: _finishSession,
                            onToggleRecording: _toggleRecording,
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String role;
  final String track;
  const _TopBar({required this.role, required this.track});

  static const Color _accent    = Color(0xFF6C63FF);
  static const Color _teal      = Color(0xFF00C9A7);
  static const Color _textPrimary = Color(0xFFF4F3FF);
  static const Color _textMuted   = Color(0xFF9896B0);
  static const Color _surface     = Color(0xFF1A1829);
  static const Color _border      = Color(0xFF2E2C45);

  @override
  Widget build(BuildContext context) {
    final isTech = track.toLowerCase() == 'technical';
    final trackColor = isTech ? _accent : _teal;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Mock Interview',
                  style: const TextStyle(color: _textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          // Track badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: trackColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: trackColor.withOpacity(0.4), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: trackColor,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  track,
                  style: TextStyle(
                    color: trackColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  final int current;
  final int total;
  final List<String> answers;
  const _ProgressSection(
      {required this.current,
      required this.total,
      required this.answers});

  static const Color _accent    = Color(0xFF6C63FF);
  static const Color _surface   = Color(0xFF1A1829);
  static const Color _border    = Color(0xFF2E2C45);
  static const Color _textPrimary = Color(0xFFF4F3FF);
  static const Color _textMuted   = Color(0xFF9896B0);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dot stepper
          SizedBox(
            height: 8,
            child: Row(
              children: List.generate(total, (i) {
                final answered = answers[i].trim().isNotEmpty;
                final isCurrent = i == current - 1;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: isCurrent
                          ? _accent
                          : answered
                              ? _accent.withOpacity(0.45)
                              : _surface,
                      border: Border.all(
                        color: isCurrent ? _accent : _border,
                        width: 1,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question $current of $total',
                style: const TextStyle(
                    color: _textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
              Text(
                '${answers.where((a) => a.trim().isNotEmpty).length} answered',
                style: const TextStyle(
                    color: _textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final String text;
  final int index;
  const _QuestionCard({required this.text, required this.index});

  static const Color _surface     = Color(0xFF1A1829);
  static const Color _card        = Color(0xFF211F35);
  static const Color _accent      = Color(0xFF6C63FF);
  static const Color _border      = Color(0xFF2E2C45);
  static const Color _textPrimary = Color(0xFFF4F3FF);
  static const Color _textMuted   = Color(0xFF9896B0);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Q label
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Q${index + 1}',
                  style: const TextStyle(
                    color: _accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.help_outline_rounded,
                  color: _textMuted, size: 14),
              const Spacer(),
              const Icon(Icons.volume_up_outlined,
                  color: _textMuted, size: 16),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            text,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 16,
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerField extends StatelessWidget {
  final TextEditingController controller;
  final bool isRecording;
  const _AnswerField({
    required this.controller,
    required this.isRecording,
  });

  static const Color _surface   = Color(0xFF1A1829);
  static const Color _card      = Color(0xFF211F35);
  static const Color _accent    = Color(0xFF6C63FF);
  static const Color _accentAlt = Color(0xFFFF6584);
  static const Color _border    = Color(0xFF2E2C45);
  static const Color _textPrimary = Color(0xFFF4F3FF);
  static const Color _textMuted   = Color(0xFF9896B0);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRecording
              ? _accentAlt.withOpacity(0.6)
              : _border,
          width: isRecording ? 1.5 : 1,
        ),
        boxShadow: isRecording
            ? [
                BoxShadow(
                  color: _accentAlt.withOpacity(0.08),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding:
                const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Icon(
                  isRecording
                      ? Icons.fiber_manual_record_rounded
                      : Icons.edit_rounded,
                  size: 13,
                  color: isRecording ? _accentAlt : _textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  isRecording ? 'Listening...' : 'Your answer',
                  style: TextStyle(
                    color: isRecording ? _accentAlt : _textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          // Text input
          TextField(
            controller: controller,
            readOnly: true,
            enableInteractiveSelection: false,
            showCursor: false,
            maxLines: 6,
            minLines: 4,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 14,
              height: 1.6,
            ),
            decoration: InputDecoration(
              hintText: isRecording
                  ? 'Listening — speak your answer...'
                  : 'Tap the mic below to record your answer',
              hintStyle: const TextStyle(
                  color: _textMuted, fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int currentIndex;
  final int total;
  final bool isReady;
  final bool isRecording;
  final Animation<double> pulseAnimation;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onFinish;
  final VoidCallback onToggleRecording;

  const _BottomBar({
    required this.currentIndex,
    required this.total,
    required this.isReady,
    required this.isRecording,
    required this.pulseAnimation,
    required this.onPrevious,
    required this.onNext,
    required this.onFinish,
    required this.onToggleRecording,
  });

  static const Color _bg         = Color(0xFF0F0E17);
  static const Color _surface    = Color(0xFF1A1829);
  static const Color _accent     = Color(0xFF6C63FF);
  static const Color _accentAlt  = Color(0xFFFF6584);
  static const Color _teal       = Color(0xFF00C9A7);
  static const Color _border     = Color(0xFF2E2C45);
  static const Color _textPrimary= Color(0xFFF4F3FF);
  static const Color _textMuted  = Color(0xFF9896B0);

  bool get _isLast => currentIndex == total - 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: _bg,
        border: Border(top: BorderSide(color: _border, width: 1)),
      ),
      child: Row(
        children: [
          // Previous
          _NavButton(
            icon: Icons.arrow_back_ios_new_rounded,
            enabled: currentIndex > 0,
            onTap: onPrevious,
          ),
          const SizedBox(width: 12),

          // Mic button (centre)
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: pulseAnimation,
                builder: (_, child) => Transform.scale(
                  scale: isRecording ? pulseAnimation.value : 1.0,
                  child: child,
                ),
                child: GestureDetector(
                  onTap: isReady ? onToggleRecording : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isRecording
                          ? _accentAlt
                          : isReady
                              ? _accent
                              : _surface,
                      boxShadow: isRecording
                          ? [
                              BoxShadow(
                                color: _accentAlt.withOpacity(0.45),
                                blurRadius: 20,
                                spreadRadius: 2,
                              )
                            ]
                          : isReady
                              ? [
                                  BoxShadow(
                                    color: _accent.withOpacity(0.35),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [],
                    ),
                    child: Icon(
                      isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                      color: isReady ? Colors.white : _textMuted,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Next / Finish
          _isLast
              ? _FinishButton(onTap: onFinish)
              : _NavButton(
                  icon: Icons.arrow_forward_ios_rounded,
                  enabled: true,
                  onTap: onNext,
                  filled: true,
                ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final bool filled;
  const _NavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
    this.filled = false,
  });

  static const Color _surface  = Color(0xFF1A1829);
  static const Color _accent   = Color(0xFF6C63FF);
  static const Color _border   = Color(0xFF2E2C45);
  static const Color _textMuted= Color(0xFF9896B0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.35,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: filled ? _accent.withOpacity(0.15) : _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: filled ? _accent.withOpacity(0.5) : _border,
            ),
          ),
          child: Icon(icon,
              color: filled ? _accent : _textMuted, size: 18),
        ),
      ),
    );
  }
}

class _FinishButton extends StatelessWidget {
  final VoidCallback onTap;
  const _FinishButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00C9A7), Color(0xFF00A688)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00C9A7).withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Finish',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.check_rounded, color: Colors.white, size: 17),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
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
            'Preparing your questions...',
            style: TextStyle(color: Color(0xFF9896B0), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6584).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  color: Color(0xFFFF6584), size: 28),
            ),
            const SizedBox(height: 16),
            const Text('Something went wrong',
                style: TextStyle(
                    color: Color(0xFFF4F3FF),
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFF9896B0), fontSize: 13, height: 1.5)),
          ],
        ),
      ),
    );
  }
}