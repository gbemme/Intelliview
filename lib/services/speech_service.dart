import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool available = false;

  Future<bool> initialize() async {
    available = await _speech.initialize(
      onStatus: (_) {},
      onError: (_) {},
    );
    return available;
  }

  Future<void> startListening({required void Function(String recognizedText) onResult}) async {
    if (!available) {
      throw StateError('Speech service is not available');
    }
    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      listenMode: ListenMode.confirmation,
      cancelOnError: true,
      partialResults: true,
    );
  }

  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  bool get isListening => _speech.isListening;
}
