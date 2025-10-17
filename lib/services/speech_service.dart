import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

/// خدمة التعرف على الصوت وتحويل النص إلى كلام
/// 
/// توفر وظائف:
/// - التعرف على الصوت (Speech to Text)
/// - تحويل النص إلى كلام (Text to Speech)
/// - معالجة الأوامر الصوتية
/// 
/// يستخدم Singleton Pattern لضمان instance واحد فقط
/// يدعم اللغة العربية (ar-SA)
class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  
  /// Factory constructor يرجع نفس الـ instance
  factory SpeechService() => _instance;
  
  /// Private constructor لل Singleton
  SpeechService._internal();

  /// محرك التعرف على الصوت
  final SpeechToText _speechToText = SpeechToText();
  
  /// محرك تحويل النص إلى كلام
  final FlutterTts _flutterTts = FlutterTts();
  
  /// هل تم تهيئة الخدمة؟
  bool _isInitialized = false;
  
  /// هل الخدمة تستمع حالياً؟
  bool _isListening = false;

  /// تهيئة خدمة التعرف على الصوت
  /// 
  /// يطلب إذن الميكروفون ويهيئ محركات STT و TTS
  /// 
  /// Returns: true إذا نجحت التهيئة، false إذا فشلت
  /// 
  /// مثال:
  /// ```dart
  /// final service = SpeechService();
  /// final success = await service.initialize();
  /// if (success) {
  ///   print('تم التهيئة بنجاح');
  /// }
  /// ```
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // طلب الأذونات
      final micPermission = await Permission.microphone.request();
      if (!micPermission.isGranted) {
        return false;
      }

      // تهيئة Speech to Text
      final sttAvailable = await _speechToText.initialize(
        onError: (error) => print('STT Error: $error'),
        onStatus: (status) => print('STT Status: $status'),
      );

      // تهيئة Text to Speech
      await _flutterTts.setLanguage('ar-SA'); // Arabic
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _isInitialized = sttAvailable;
      return _isInitialized;
    } catch (e) {
      print('Speech Service initialization error: $e');
      return false;
    }
  }

  /// بدء الاستماع للإدخال الصوتي
  /// 
  /// [onResult] دالة يتم استدعاؤها عند التعرف على النص النهائي
  /// [onError] دالة يتم استدعاؤها عند حدوث خطأ
  /// 
  /// يستمع لمدة 30 ثانية كحد أقصى
  /// يتوقف تلقائياً بعد 3 ثواني من الصمت
  /// 
  /// مثال:
  /// ```dart
  /// await service.startListening(
  ///   onResult: (text) => print('تم التعرف على: $text'),
  ///   onError: (error) => print('خطأ: $error'),
  /// );
  /// ```
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        onError('فشل في تهيئة خدمة التعرف على الصوت');
        return;
      }
    }

    if (_isListening) return;

    try {
      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            onResult(result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: false,
        localeId: 'ar-SA', // Arabic
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );
      _isListening = true;
    } catch (e) {
      onError('خطأ في بدء الاستماع: $e');
    }
  }

  /// إيقاف الاستماع
  /// 
  /// يوقف محرك التعرف على الصوت
  Future<void> stopListening() async {
    if (!_isListening) return;
    
    try {
      await _speechToText.stop();
      _isListening = false;
    } catch (e) {
      print('Error stopping listening: $e');
    }
  }

  /// تحويل النص إلى كلام وقراءته
  /// 
  /// [text] النص المراد قراءته
  /// 
  /// يستخدم اللغة العربية وسرعة قراءة متوسطة
  /// 
  /// مثال:
  /// ```dart
  /// await service.speak('مرحباً بك');
  /// ```
  Future<void> speak(String text) async {
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      print('Error speaking: $e');
    }
  }

  /// إيقاف قراءة النص
  /// 
  /// يوقف محرك TTS فوراً
  Future<void> stopSpeaking() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print('Error stopping speech: $e');
    }
  }

  /// معالجة الأوامر الصوتية وتحويلها إلى أوامر مفهومة
  /// 
  /// [text] النص المراد معالجته
  /// 
  /// Returns: [VoiceCommand] يحتوي على نوع الأمر والبيانات
  /// 
  /// الأوامر المدعومة:
  /// - إضافة مهمة: 'أضف مهمة ...'
  /// - بحث: 'ابحث عن ...'
  /// - عرض المهام: 'اعرض المهام'
  /// - إكمال مهمة: 'اكمل مهمة ...'
  /// - حذف مهمة: 'احذف مهمة ...'
  /// 
  /// مثال:
  /// ```dart
  /// final command = service.processVoiceCommand('أضف مهمة اجتماع غداً');
  /// if (command.type == VoiceCommandType.addTask) {
  ///   print('المهمة: ${command.data['taskText']}');
  /// }
  /// ```
  VoiceCommand processVoiceCommand(String text) {
    final lowerText = text.toLowerCase();
    
    // أوامر إضافة المهام
    if (_containsAny(lowerText, ['أضف', 'اضف', 'add', 'create', 'new'])) {
      final taskText = _extractTaskFromCommand(text);
      return VoiceCommand(
        type: VoiceCommandType.addTask,
        data: {'taskText': taskText},
      );
    }
    
    // أوامر البحث
    if (_containsAny(lowerText, ['ابحث', 'بحث', 'search', 'find'])) {
      final searchQuery = _extractSearchQuery(text);
      return VoiceCommand(
        type: VoiceCommandType.search,
        data: {'query': searchQuery},
      );
    }
    
    // أوامر عرض المهام
    if (_containsAny(lowerText, ['اعرض', 'عرض', 'show', 'display'])) {
      return VoiceCommand(
        type: VoiceCommandType.showTasks,
        data: {},
      );
    }
    
    // أوامر إكمال المهام
    if (_containsAny(lowerText, ['اكمل', 'انهي', 'complete', 'finish', 'done'])) {
      return VoiceCommand(
        type: VoiceCommandType.completeTask,
        data: {'taskText': text},
      );
    }
    
    // أوامر حذف المهام
    if (_containsAny(lowerText, ['احذف', 'امسح', 'delete', 'remove'])) {
      return VoiceCommand(
        type: VoiceCommandType.deleteTask,
        data: {'taskText': text},
      );
    }
    
    // أمر غير معروف
    return VoiceCommand(
      type: VoiceCommandType.unknown,
      data: {'text': text},
    );
  }

  /// يتحقق إذا كان النص يحتوي على أي من الكلمات المحددة
  /// 
  /// [text] النص للبحث فيه
  /// [words] قائمة الكلمات للبحث عنها
  /// Returns: true إذا وجدت أي كلمة
  bool _containsAny(String text, List<String> words) {
    return words.any((word) => text.contains(word));
  }

  /// استخراج نص المهمة من الأمر الصوتي
  /// 
  /// يزيل كلمات الأوامر ويبقي على نص المهمة فقط
  /// 
  /// [command] الأمر الكامل
  /// Returns: نص المهمة بدون كلمات الأوامر
  String _extractTaskFromCommand(String command) {
    final lowerCommand = command.toLowerCase();
    
    // إزالة كلمات الأوامر
    final commandWords = ['أضف', 'اضف', 'add', 'create', 'new', 'مهمة', 'task'];
    String result = command;
    
    for (String word in commandWords) {
      result = result.replaceAll(RegExp(word, caseSensitive: false), '').trim();
    }
    
    return result.isNotEmpty ? result : command;
  }

  /// استخراج نص البحث من الأمر الصوتي
  /// 
  /// يزيل كلمات البحث ويبقي على النص المراد البحث عنه
  /// 
  /// [command] الأمر الكامل
  /// Returns: نص البحث
  String _extractSearchQuery(String command) {
    final lowerCommand = command.toLowerCase();
    
    // إزالة كلمات البحث
    final searchWords = ['ابحث', 'بحث', 'search', 'find', 'عن', 'about'];
    String result = command;
    
    for (String word in searchWords) {
      result = result.replaceAll(RegExp(word, caseSensitive: false), '').trim();
    }
    
    return result.isNotEmpty ? result : command;
  }

  /// هل الخدمة تستمع حالياً؟
  bool get isListening => _isListening;
  
  /// هل تم تهيئة الخدمة؟
  bool get isInitialized => _isInitialized;
  
  /// هل خدمة التعرف على الصوت متاحة؟
  bool get isAvailable => _speechToText.isAvailable;

  /// تنظيف الموارد وإيقاف جميع العمليات
  /// 
  /// يجب استدعاؤها عند الانتهاء من استخدام الخدمة
  void dispose() {
    _speechToText.cancel();
    _flutterTts.stop();
  }
}

/// أنواع الأوامر الصوتية المدعومة
enum VoiceCommandType {
  /// إضافة مهمة جديدة
  addTask,
  
  /// البحث عن مهام
  search,
  
  /// عرض جميع المهام
  showTasks,
  
  /// إكمال مهمة
  completeTask,
  
  /// حذف مهمة
  deleteTask,
  
  /// أمر غير معروف
  unknown,
}

/// نموذج بيانات الأمر الصوتي
/// 
/// يحتوي على نوع الأمر والبيانات المرتبطة به
class VoiceCommand {
  /// نوع الأمر الصوتي
  final VoiceCommandType type;
  
  /// بيانات إضافية خاصة بالأمر
  /// 
  /// مثل:
  /// - addTask: {'taskText': 'نص المهمة'}
  /// - search: {'query': 'نص البحث'}
  final Map<String, dynamic> data;

  /// Constructor للأمر الصوتي
  VoiceCommand({
    required this.type,
    required this.data,
  });
}
