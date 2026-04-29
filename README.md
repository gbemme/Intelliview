# IntelliView

An AI-Powered Interview Coach

A Flutter-based mock interview platform that bridges the gap between technical knowledge and verbal delivery — simulating real interview pressure with voice-activated sessions and objective performance analytics.

## Features

### Personalized Onboarding
Users select their Target Role (e.g., Software Engineer) and Interview Track (Technical or Behavioral) for a tailored experience.

### Intelligent Analytics
Post-session radar charts visualize Clarity, Pace, and Technical Accuracy — highlighting specific areas to improve.

### Mock History Archive
Review past sessions, replay recordings, and track growth over time with a dedicated practice history.

## Architecture

This project demonstrates a clear architectural separation between:

- **Presentation Layer** (`lib/views/`): Widgets and UI components
- **Application Logic** (`lib/state/`): State management with Provider
- **Data Layer** (`lib/services/`, `lib/repositories/`): API calls and local persistence

### Key Components

- **State Management**: Provider pattern for predictable state updates
- **Network Layer**: HTTP client for REST API integration
- **Local Storage**: SharedPreferences for session history
- **Device Integration**: Speech-to-text for voice input
- **Data Visualization**: Custom radar chart for performance metrics

## Getting Started

### Prerequisites

- Flutter SDK (^3.11.5)
- Dart SDK (^3.11.5)

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd intelliview
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Project Structure

```
lib/
├── app.dart                 # Main app widget with routing
├── main.dart               # App entry point
├── routes.dart             # Route constants
├── models/
│   └── interview_session.dart  # Domain model
├── services/
│   ├── api_service.dart       # REST API client
│   └── speech_service.dart    # Voice input service
├── repositories/
│   └── history_repository.dart # Local data persistence
├── state/
│   └── app_state.dart        # Application state management
└── views/
    ├── screens/
    │   ├── onboarding_screen.dart
    │   ├── practice_session_screen.dart
    │   ├── session_summary_screen.dart
    │   └── history_screen.dart
    └── widgets/
        └── radar_chart.dart
```

## Dependencies

- `http`: REST API communication
- `provider`: State management
- `shared_preferences`: Local data storage
- `speech_to_text`: Voice input capability

## Usage

1. **Onboarding**: Select your target role and interview track
2. **Practice Session**: Record your responses using voice input
3. **Session Summary**: View performance analytics with radar charts
4. **History**: Review past sessions and track improvement

## Development

### Running Tests

```bash
flutter test
```

### Code Analysis

```bash
flutter analyze
```

### Building for Production

```bash
flutter build apk  # Android
flutter build ios  # iOS
flutter build web  # Web
```

## Contributing

1. Follow the established architecture patterns
2. Maintain separation between UI, logic, and data layers
3. Add tests for new features
4. Run `flutter analyze` before committing

## License

This project is for educational purposes.
