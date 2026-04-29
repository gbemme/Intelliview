import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../routes.dart';
import '../../state/app_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedRole;
  String? _selectedTrack;
  final List<String> _roles = [
    'Software Engineer',
    'Data Analyst',
    'Product Manager',
  ];
  final List<String> _tracks = ['Technical', 'Behavioral'];

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    if (state.remoteTrackSuggestions.isEmpty) {
      state.loadTrackSuggestions();
    }
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
      appBar: AppBar(title: const Text('IntelliView')), 
      body: Consumer<AppState>(
        builder: (context, state, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'An AI-powered interview coach',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Choose your target role and interview track to begin a guided mock session.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Target Role',
                          border: OutlineInputBorder(),
                        ),
                        items: _roles.map(
                          (role) => DropdownMenuItem(
                            value: role,
                            child: Text(role),
                          ),
                        ).toList(),
                        validator: (value) => value == null ? 'Select a role' : null,
                        onChanged: (value) => setState(() => _selectedRole = value),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedTrack,
                        decoration: const InputDecoration(
                          labelText: 'Interview Track',
                          border: OutlineInputBorder(),
                        ),
                        items: _tracks.map(
                          (track) => DropdownMenuItem(
                            value: track,
                            child: Text(track),
                          ),
                        ).toList(),
                        validator: (value) => value == null ? 'Select a track' : null,
                        onChanged: (value) => setState(() => _selectedTrack = value),
                      ),
                      const SizedBox(height: 24),
                      if (state.isLoading)
                        const CircularProgressIndicator()
                      else if (state.errorMessage != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(state.errorMessage!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: state.loadTrackSuggestions,
                              child: const Text('Retry suggestions'),
                            ),
                          ],
                        )
                      else if (state.remoteTrackSuggestions.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Suggested session themes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...state.remoteTrackSuggestions
                                .map((suggestion) => Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(suggestion, style: const TextStyle(fontSize: 14)),
                                    )),
                          ],
                        ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                        child: const Text('Start Practice'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.history);
        },
        icon: const Icon(Icons.history),
        label: const Text('Practice History'),
      ),
    );
  }
}
