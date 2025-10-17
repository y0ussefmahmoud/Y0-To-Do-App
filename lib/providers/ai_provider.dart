import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_service.dart';
import '../services/speech_service.dart';

/// Provider لخدمة الذكاء الاصطناعي (AI Service)
/// 
/// يوفر instance من AIService للاستخدام في جميع أنحاء التطبيق
/// يستخدم لتحليل النصوص واستخراج المعلومات من المهام
final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

/// Provider لخدمة التعرف على الصوت (Speech Service)
/// 
/// يوفر instance من SpeechService للتعامل مع الإدخال الصوتي
/// يدعم التعرف على الصوت وتحويل النص إلى كلام
final speechServiceProvider = Provider<SpeechService>((ref) {
  return SpeechService();
});

/// حالة التعرف على الصوت (Voice State)
/// 
/// يحتوي على جميع المعلومات المتعلقة بحالة الإدخال الصوتي:
/// - حالة الاستماع
/// - حالة التهيئة
/// - الأخطاء
/// - آخر نص تم التعرف عليه
class VoiceState {
  /// هل الخدمة تستمع حالياً؟
  final bool isListening;
  
  /// هل تم تهيئة الخدمة بنجاح؟
  final bool isInitialized;
  
  /// رسالة الخطأ إن وجدت
  final String? error;
  
  /// آخر نص تم التعرف عليه
  final String? lastRecognizedText;

  /// Constructor لحالة الصوت
  VoiceState({
    this.isListening = false,
    this.isInitialized = false,
    this.error,
    this.lastRecognizedText,
  });

  /// إنشاء نسخة جديدة من الحالة مع تعديل بعض الخصائص
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

/// StateNotifier لإدارة حالة الإدخال الصوتي
/// 
/// يدير جميع العمليات المتعلقة بالصوت:
/// - تهيئة خدمة التعرف على الصوت
/// - بدء وإيقاف الاستماع
/// - معالجة الأوامر الصوتية
/// - تحويل النص إلى كلام
class VoiceNotifier extends StateNotifier<VoiceState> {
  /// خدمة التعرف على الصوت
  final SpeechService _speechService;

  /// Constructor يستقبل SpeechService
  VoiceNotifier(this._speechService) : super(VoiceState());

  /// تهيئة خدمة التعرف على الصوت
  /// 
  /// يطلب الأذونات اللازمة ويهيئ المحرك
  /// Returns: true إذا نجحت التهيئة، false إذا فشلت
  Future<void> initialize() async {
    final success = await _speechService.initialize();
    state = state.copyWith(
      isInitialized: success,
      error: success ? null : 'فشل في تهيئة خدمة الصوت',
    );
  }

  /// بدء الاستماع للإدخال الصوتي
  /// 
  /// [onResult] دالة يتم استدعاؤها عند التعرف على النص
  /// 
  /// يقوم بتهيئة الخدمة إذا لم تكن مهيأة، ثم يبدأ الاستماع
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

  /// إيقاف الاستماع
  /// 
  /// يوقف محرك التعرف على الصوت ويحدث الحالة
  Future<void> stopListening() async {
    await _speechService.stopListening();
    state = state.copyWith(isListening: false);
  }

  /// تحويل النص إلى كلام
  /// 
  /// [text] النص المراد قراءته
  Future<void> speak(String text) async {
    await _speechService.speak(text);
  }

  /// معالجة الأمر الصوتي
  /// 
  /// [text] النص المراد معالجته
  /// Returns: VoiceCommand يحتوي على نوع الأمر والبيانات
  VoiceCommand processCommand(String text) {
    return _speechService.processVoiceCommand(text);
  }
}

/// Provider الرئيسي لإدارة الصوت
/// 
/// يوفر الوصول إلى VoiceNotifier وحالة الصوت
/// 
/// مثال على الاستخدام:
/// ```dart
/// final voiceState = ref.watch(voiceProvider);
/// final voiceNotifier = ref.read(voiceProvider.notifier);
/// 
/// // بدء الاستماع
/// await voiceNotifier.startListening(
///   onResult: (text) => print('تم التعرف على: $text'),
/// );
/// ```
final voiceProvider = StateNotifierProvider<VoiceNotifier, VoiceState>((ref) {
  final speechService = ref.read(speechServiceProvider);
  return VoiceNotifier(speechService);
});

/// حالة الاقتراحات الذكية (Smart Suggestions State)
/// 
/// تحتوي على قائمة الاقتراحات وحالة التحميل
class SmartSuggestionsState {
  /// قائمة الاقتراحات الذكية
  final List<String> suggestions;
  
  /// هل يتم تحميل الاقتراحات حالياً؟
  final bool isLoading;

  /// Constructor لحالة الاقتراحات
  SmartSuggestionsState({
    this.suggestions = const [],
    this.isLoading = false,
  });

  /// إنشاء نسخة جديدة من الحالة مع تعديل بعض الخصائص
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

/// StateNotifier لإدارة الاقتراحات الذكية
/// 
/// يستخدم AI Service لتوليد اقتراحات ذكية للمهام
/// بناءً على المهام السابقة والوقت الحالي
class SmartSuggestionsNotifier extends StateNotifier<SmartSuggestionsState> {
  /// خدمة الذكاء الاصطناعي
  final AIService _aiService;

  /// Constructor يستقبل AIService
  SmartSuggestionsNotifier(this._aiService) : super(SmartSuggestionsState());

  /// تحميل الاقتراحات الذكية
  /// 
  /// [recentTasks] قائمة بالمهام الأخيرة للمستخدم
  /// 
  /// يستخدم AI لتوليد اقتراحات بناءً على السياق والوقت
  void loadSuggestions(List<String> recentTasks) {
    state = state.copyWith(isLoading: true);
    
    final suggestions = _aiService.getSmartSuggestions(recentTasks);
    
    state = state.copyWith(
      suggestions: suggestions,
      isLoading: false,
    );
  }

  /// تحليل نص المهمة
  /// 
  /// [text] نص المهمة المراد تحليله
  /// Returns: TaskAnalysis يحتوي على الأولوية والتاريخ والفئة
  TaskAnalysis analyzeTask(String text) {
    return _aiService.analyzeTaskText(text);
  }

  /// تحليل الإنتاجية
  /// 
  /// [completedTasks] قائمة بالمهام المكتملة
  /// Returns: ProductivityAnalysis يحتوي على النقاط والاقتراحات
  ProductivityAnalysis analyzeProductivity(List<Map<String, dynamic>> completedTasks) {
    return _aiService.analyzeProductivity(completedTasks);
  }
}

/// Provider للاقتراحات الذكية
/// 
/// يوفر الوصول إلى SmartSuggestionsNotifier وحالة الاقتراحات
final smartSuggestionsProvider = StateNotifierProvider<SmartSuggestionsNotifier, SmartSuggestionsState>((ref) {
  final aiService = ref.read(aiServiceProvider);
  return SmartSuggestionsNotifier(aiService);
});

/// Provider لتحليل المهمة
/// 
/// يوفر تحليل فوري لنص المهمة باستخدام AI
/// يستخدم family للسماح بتمرير نص المهمة كمعامل
/// 
/// مثال:
/// ```dart
/// final analysis = ref.watch(taskAnalysisProvider('اجتماع مهم غداً'));
/// print('الأولوية: ${analysis.priority}');
/// ```
final taskAnalysisProvider = Provider.family<TaskAnalysis, String>((ref, taskText) {
  final aiService = ref.read(aiServiceProvider);
  return aiService.analyzeTaskText(taskText);
});
