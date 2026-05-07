import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../routes.dart';
import '../../state/app_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String? _selectedRole;
  String? _selectedTrack;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _roles = [
    {'label': 'Software Engineer',    'icon': Icons.code_rounded},
    {'label': 'Data Analyst',         'icon': Icons.bar_chart_rounded},
    {'label': 'Product Manager',      'icon': Icons.lightbulb_outline_rounded},
    {'label': 'UX Designer',          'icon': Icons.brush_rounded},
    {'label': 'Marketing Manager',    'icon': Icons.campaign_rounded},
    {'label': 'Finance Analyst',      'icon': Icons.account_balance_rounded},
    {'label': 'DevOps Engineer',      'icon': Icons.cloud_rounded},
    {'label': 'Data Scientist',       'icon': Icons.science_rounded},
    {'label': 'Sales Manager',        'icon': Icons.handshake_rounded},
    {'label': 'HR Manager',           'icon': Icons.people_rounded},
    {'label': 'Business Analyst',     'icon': Icons.analytics_rounded},
    {'label': 'Cybersecurity Analyst','icon': Icons.security_rounded},
    {'label': 'Content Strategist',   'icon': Icons.edit_note_rounded},
    {'label': 'Operations Manager',   'icon': Icons.settings_rounded},
    {'label': 'Legal Counsel',        'icon': Icons.gavel_rounded},
  ];

  final List<Map<String, dynamic>> _tracks = [
    {
      'label': 'Technical',
      'icon': Icons.psychology_rounded,
      'desc': 'Domain knowledge & skills',
      'color': const Color(0xFF6C63FF),
    },
    {
      'label': 'Behavioral',
      'icon': Icons.people_alt_rounded,
      'desc': 'Teamwork & soft skills',
      'color': const Color(0xFF00C9A7),
    },
  ];

  // Palette
  static const Color _bg = Color(0xFF0F0E17);
  static const Color _surface = Color(0xFF1A1829);
  static const Color _card = Color(0xFF211F35);
  static const Color _accent = Color(0xFF6C63FF);
  static const Color _accentAlt = Color(0xFFFF6584);
  static const Color _textPrimary = Color(0xFFF4F3FF);
  static const Color _textSecondary = Color(0xFF9896B0);
  static const Color _divider = Color(0xFF2E2C45);

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();

    final state = context.read<AppState>();
  
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      context.read<AppState>().selectProfile(_selectedRole!, _selectedTrack!);
      Navigator.pushNamed(context, AppRoutes.practice);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // ── Decorative blobs ──────────────────────────────────────
          Positioned(
            top: -80,
            right: -60,
            child: _Blob(
              size: 280,
              color: _accent.withOpacity(0.18),
            ),
          ),
          Positioned(
            bottom: 80,
            left: -80,
            child: _Blob(
              size: 220,
              color: _accentAlt.withOpacity(0.12),
            ),
          ),
          // ── Main content ──────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Consumer<AppState>(
                  builder: (context, state, child) {
                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              const SizedBox(height: 32),
                              // ── Brand ──────────────────────────
                              _BrandHeader(),
                              const SizedBox(height: 40),
                              // ── Illustration strip ─────────────
                              _IllustrationStrip(),
                              const SizedBox(height: 36),
                              // ── Section: Role ─────────────────
                              _SectionLabel(label: 'Your target role'),
                              const SizedBox(height: 14),
                              Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FormField<String>(
                                      validator: (v) => v == null
                                          ? 'Please select a role'
                                          : null,
                                      builder: (field) => Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _RoleDropdown(
                                            roles: _roles,
                                            selected: _selectedRole,
                                            onSelect: (val) {
                                              setState(
                                                  () => _selectedRole = val);
                                              field.didChange(val);
                                            },
                                            hasError: field.hasError,
                                          ),
                                          if (field.hasError)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8, left: 4),
                                              child: Text(field.errorText!,
                                                  style: const TextStyle(
                                                      color: _accentAlt,
                                                      fontSize: 12)),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    // ── Section: Track ────────────
                                    _SectionLabel(label: 'Interview track'),
                                    const SizedBox(height: 14),
                                    FormField<String>(
                                      validator: (v) => v == null
                                          ? 'Please select a track'
                                          : null,
                                      builder: (field) => Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: _tracks
                                                .map((t) => Expanded(
                                                      child: Padding(
                                                        padding: EdgeInsets.only(
                                                            right: t == _tracks.last
                                                                ? 0
                                                                : 12),
                                                        child: _TrackCard(
                                                          label: t['label'],
                                                          icon: t['icon'],
                                                          desc: t['desc'],
                                                          color: t['color'],
                                                          selected:
                                                              _selectedTrack ==
                                                                  t['label'],
                                                          onTap: () {
                                                            setState(() =>
                                                                _selectedTrack =
                                                                    t['label']);
                                                            field.didChange(
                                                                t['label']);
                                                          },
                                                        ),
                                                      ),
                                                    ))
                                                .toList(),
                                          ),
                                          if (field.hasError)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8, left: 4),
                                              child: Text(field.errorText!,
                                                  style: const TextStyle(
                                                      color: _accentAlt,
                                                      fontSize: 12)),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              // ── Suggestions ────────────────────
                              if (state.isLoading)
                                const Center(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 12),
                                    child: CircularProgressIndicator(
                                      color: _accent,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                             ,
                     
                              const SizedBox(height: 32),
                              // ── CTA ────────────────────────────
                              _StartButton(onPressed: _submit),
                              const SizedBox(height: 24),
                              // ── History link ──────────────────
                              Center(
                                child: TextButton.icon(
                                  onPressed: () => Navigator.pushNamed(
                                      context, AppRoutes.history),
                                  icon: const Icon(Icons.history_rounded,
                                      size: 16, color: _textSecondary),
                                  label: const Text(
                                    'View practice history',
                                    style: TextStyle(
                                        color: _textSecondary, fontSize: 14),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ]),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
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

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
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
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'IntelliView',
              style: TextStyle(
                color: Color(0xFFF4F3FF),
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Land your\ndream role.',
          style: TextStyle(
            color: Color(0xFFF4F3FF),
            fontSize: 38,
            fontWeight: FontWeight.w800,
            height: 1.1,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'AI-powered mock interviews tailored to you.',
          style: TextStyle(
            color: Color(0xFF9896B0),
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _IllustrationStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.record_voice_over_rounded, 'label': 'Mock Sessions'},
      {'icon': Icons.insights_rounded, 'label': 'Instant Feedback'},
      {'icon': Icons.emoji_events_rounded, 'label': 'Track Progress'},
    ];
    return Row(
      children: items
          .map((item) => Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: item == items.last ? 0 : 10,
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 16, horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1829),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFF2E2C45), width: 1),
                  ),
                  child: Column(
                    children: [
                      Icon(item['icon'] as IconData,
                          color: const Color(0xFF6C63FF), size: 26),
                      const SizedBox(height: 8),
                      Text(
                        item['label'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF9896B0),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF9896B0),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _RoleDropdown extends StatelessWidget {
  final List<Map<String, dynamic>> roles;
  final String? selected;
  final ValueChanged<String> onSelect;
  final bool hasError;

  const _RoleDropdown({
    required this.roles,
    required this.selected,
    required this.onSelect,
    this.hasError = false,
  });

  void _openPicker(BuildContext context) {
    final TextEditingController searchCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final query = searchCtrl.text.toLowerCase();
          final filtered = roles
              .where((r) =>
                  (r['label'] as String).toLowerCase().contains(query))
              .toList();

          return Container(
            height: MediaQuery.of(context).size.height * 0.72,
            decoration: const BoxDecoration(
              color: Color(0xFF1A1829),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                // Handle bar
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E2C45),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                // Header
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        'Select your role',
                        style: TextStyle(
                          color: Color(0xFFF4F3FF),
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Search field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: searchCtrl,
                    onChanged: (_) => setSheetState(() {}),
                    style: const TextStyle(
                        color: Color(0xFFF4F3FF), fontSize: 14),
                    cursorColor: const Color(0xFF6C63FF),
                    decoration: InputDecoration(
                      hintText: 'Search roles...',
                      hintStyle: const TextStyle(
                          color: Color(0xFF9896B0), fontSize: 14),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: Color(0xFF9896B0), size: 20),
                      suffixIcon: searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded,
                                  color: Color(0xFF9896B0), size: 18),
                              onPressed: () {
                                searchCtrl.clear();
                                setSheetState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFF211F35),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFF2E2C45)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFF2E2C45)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFF6C63FF), width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // List
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Text(
                            'No roles found',
                            style: TextStyle(
                                color: Color(0xFF9896B0), fontSize: 14),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final role = filtered[i];
                            final isSelected = selected == role['label'];
                            return GestureDetector(
                              onTap: () {
                                onSelect(role['label'] as String);
                                Navigator.pop(ctx);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 13),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF6C63FF)
                                          .withOpacity(0.14)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF6C63FF)
                                        : const Color(0xFF2E2C45),
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFF6C63FF)
                                                .withOpacity(0.2)
                                            : const Color(0xFF211F35),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        role['icon'] as IconData,
                                        size: 18,
                                        color: isSelected
                                            ? const Color(0xFF6C63FF)
                                            : const Color(0xFF9896B0),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        role['label'] as String,
                                        style: TextStyle(
                                          color: isSelected
                                              ? const Color(0xFFF4F3FF)
                                              : const Color(0xFF9896B0),
                                          fontSize: 14,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        size: 18,
                                        color: Color(0xFF6C63FF),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = selected != null;
    final selectedRole = hasSelection
        ? roles.firstWhere((r) => r['label'] == selected,
            orElse: () => roles.first)
        : null;

    return GestureDetector(
      onTap: () => _openPicker(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1829),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasError
                ? const Color(0xFFFF6584)
                : hasSelection
                    ? const Color(0xFF6C63FF)
                    : const Color(0xFF2E2C45),
            width: hasSelection ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: hasSelection
                  ? Container(
                      key: ValueKey(selected),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        selectedRole!['icon'] as IconData,
                        size: 18,
                        color: const Color(0xFF6C63FF),
                      ),
                    )
                  : Container(
                      key: const ValueKey('placeholder'),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF211F35),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.work_outline_rounded,
                        size: 18,
                        color: Color(0xFF9896B0),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Align(
                  key: ValueKey(selected ?? 'hint'),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    selected ?? 'Select your target role',
                    style: TextStyle(
                      color: hasSelection
                          ? const Color(0xFFF4F3FF)
                          : const Color(0xFF9896B0),
                      fontSize: 14,
                      fontWeight: hasSelection
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedRotation(
              turns: 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: hasSelection
                    ? const Color(0xFF6C63FF)
                    : const Color(0xFF9896B0),
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final String desc;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _TrackCard({
    required this.label,
    required this.icon,
    required this.desc,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : const Color(0xFF1A1829),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? color : const Color(0xFF2E2C45),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? const Color(0xFFF4F3FF)
                    : const Color(0xFF9896B0),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: const TextStyle(
                color: Color(0xFF9896B0),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionsSection extends StatelessWidget {
  final List<String> suggestions;
  const _SuggestionsSection({required this.suggestions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: 'Suggested themes'),
        const SizedBox(height: 14),
        ...suggestions.map(
          (s) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1829),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2E2C45)),
            ),
            child: Row(
              children: [
                const Icon(Icons.tips_and_updates_rounded,
                    size: 16, color: Color(0xFF6C63FF)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    s,
                    style: const TextStyle(
                      color: Color(0xFF9896B0),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6584).withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: const Color(0xFFFF6584).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFFF6584), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    color: Color(0xFFFF6584), fontSize: 13)),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF6584),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Retry',
                style:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _StartButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _StartButton({required this.onPressed});

  @override
  State<_StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<_StartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF9B6DFF)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Start Practice',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
