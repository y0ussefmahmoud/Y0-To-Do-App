import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_service.dart';
import '../services/speech_service.dart';

// AI Service Provider
final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

// Speech Service Provider
final speechServiceProvider = Provider<SpeechService>((ref) {
  return SpeechService();
});

// Voice Recognition State
class VoiceState {
  final bool isListening;
  final bool isInitialized;
  final String? error;
  final String? lastRecognizedText;

  VoiceState({
    this.isListening = false,
    this.isInitialized = false,
    this.error,
    this.lastRecognizedText,
  });

  VoiceState copyWith({
    bool? isListening,
    bool? isInitialized,
    String? error,
    String? lastRecognizedText,
  }) {
    return VoiceState(
      isListening: isListening ?? this.isListening,
      isInitialized: isInitialized ?? this.isInitialized,
      error: error ?? this.error,
      lastRecognizedText: lastRecognizedText ?? this.lastRecognizedText,
    );
  }
}

// Voice Provider
class VoiceNotifier extends StateNotifier<VoiceState> {
  final SpeechService _speechService;

  VoiceNotifier(this._speechService) : super(VoiceState());

  Future<void> initialize() async {
    final success = await _speechService.initialize();
    state = state.copyWith(
      isInitialized: success,
      error: success ? null : 'فشل في تهيئة خدمة الصوت',
    );
  }

  Future<void> startListening({
    required Function(String) onResult,
  }) async {
    if (!state.isInitialized) {
      await initialize();
    }

    if (!state.isInitialized) {
      return;
    }

    state = state.copyWith(isListening: true, error: null);

    await _speechService.startListening(
      onResult: (text) {
        state = state.copyWith(
          isListening: false,
          lastRecognizedText: text,
        );
        onResult(text);
      },
      onError: (error) {
        state = state.copyWith(
          isListening: false,
          error: error,
        );
      },
    );
  }

  Future<void> stopListening() async {
    await _speechService.stopListening();
    state = state.copyWith(isListening: false);
  }

  Future<void> speak(String text) async {
    await _speechService.speak(text);
  }

  VoiceCommand processCommand(String text) {
    return _speechService.processVoiceCommand(text);
  }
}

final voiceProvider = StateNotifierProvider<VoiceNotifier, VoiceState>((ref) {
  final speechService = ref.read(speechServiceProvider);
  return VoiceNotifier(speechService);
});

// Smart Suggestions State
class SmartSuggestionsState {
  final List<String> suggestions;
  final bool isLoading;

  SmartSuggestionsState({
    this.suggestions = const [],
    this.isLoading = false,
  });

  SmartSuggestionsState copyWith({
    List<String>? suggestions,
    bool? isLoading,
  }) {
    return SmartSuggestionsState(
      suggestions: suggestions ?? this.suggestions,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Smart Suggestions Provider
class SmartSuggestionsNotifier extends StateNotifier<SmartSuggestionsState> {
  final AIService _aiService;

  SmartSuggestionsNotifier(this._aiService) : super(SmartSuggestionsState());

  void loadSuggestions(List<String> recentTasks) {
    state = state.copyWith(isLoading: true);
    
    final suggestions = _aiService.getSmartSuggestions(recentTasks);
    
    state = state.copyWith(
      suggestions: suggestions,
      isLoading: false,
    );
  }

  TaskAnalysis analyzeTask(String text) {
    return _aiService.analyzeTaskText(text);
  }

  ProductivityAnalysis analyzeProductivity(List<Map<String, dynamic>> completedTasks) {
    return _aiService.analyzeProductivity(completedTasks);
  }
}

final smartSuggestionsProvider = StateNotifierProvider<SmartSuggestionsNotifier, SmartSuggestionsState>((ref) {
  final aiService = ref.read(aiServiceProvider);
  return SmartSuggestionsNotifier(aiService);
});

// Task Analysis Provider
final taskAnalysisProvider = Provider.family<TaskAnalysis, String>((ref, taskText) {
  final aiService = ref.read(aiServiceProvider);
  return aiService.analyzeTaskText(taskText);
});
