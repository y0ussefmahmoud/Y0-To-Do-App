import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

/// خدمة التعرف على الصوت وتحويل النص إلى كلام
/// 
/// توفر وظائف:
/// - التعرف على الصوت (Speech to Text)
/// - تحويل النص إلى كلام (Text to Speech)
/// - معالجة الأوامر الصوتية
/// - إدارة الموارد تلقائياً مع idle timer
/// 
/// يستخدم Singleton Pattern لضمان instance واحد فقط
/// يدعم اللغة العربية (ar-SA)
/// يحرر الموارد تلقائياً بعد 5 دقائق من عدم الاستخدام
class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  
  /// Factory constructor يرجع نفس الـ instance
  factory SpeechService() => _instance;
  
  /// Private constructor لل Singleton
  SpeechService._internal();

  /// محرك التعرف على الصوت
  SpeechToText? _speechToText;
  
  /// محرك تحويل النص إلى كلام
  FlutterTts? _flutterTts;
  
  /// هل تم تهيئة الخدمة؟
  bool _isInitialized = false;
  
  /// هل الخدمة تستمع حالياً؟
  bool _isListening = false;
  
  /// Timer لتتبع عدم الاستخدام
  Timer? _idleTimer;
  
  /// مدة عدم الاستخدام قبل تحرير الموارد (5 دقائق)
  static const _idleTimeout = Duration(minutes: 5);

  /// تهيئة خدمة التعرف على الصوت
  /// 
  /// يطلب إذن الميكروفون ويهيئ محركات STT و TTS
  /// يبدء idle timer لتحرير الموارد تلقائياً
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
    if (_isInitialized) {
      _resetIdleTimer();
      return true;
    }

    try {
      // طلب الأذونات
      final micPermission = await Permission.microphone.request();
      if (!micPermission.isGranted) {
        debugPrint('❌ لم يتم منح إذن الميكروفون - الصوت لن يعمل');
        return false;
      }
      debugPrint('✅ تم منح إذن الميكروفون بنجاح');

      // تهيئة المحركات
      _speechToText = SpeechToText();
      _flutterTts = FlutterTts();

      // تهيئة Speech to Text مع معالجة أفضل
      debugPrint('🔄 جاري تهيئة Speech to Text...');
      final sttAvailable = await _speechToText!.initialize(
        onError: (error) => debugPrint('❌ STT Error: $error'),
        onStatus: (status) => debugPrint('📊 STT Status: $status'),
      );

      if (!sttAvailable) {
        debugPrint('❌ فشل في تهيئة Speech to Text');
        return false;
      }
      debugPrint('✅ تم تهيئة Speech to Text بنجاح');

      // تهيئة Text to Speech مع معالجة أفضل للغة
      await _initializeTTS();

      _isInitialized = true;

      // بدء idle timer
      _resetIdleTimer();

      debugPrint('🎉 تم تهيئة خدمة الصوت بنجاح');
      return true;
    } catch (e) {
      debugPrint('❌ خطأ في تهيئة خدمة الصوت: $e');
      return false;
    }
  }

  /// إعادة تعيين idle timer
  /// 
  /// يلغي الـ timer القديم ويبدء timer جديد
  void _resetIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(_idleTimeout, _releaseResources);
  }

  /// تهيئة Text to Speech مع معالجة أفضل للغة
  Future<void> _initializeTTS() async {
    if (_flutterTts == null) return;

    try {
      // محاولة اللغة العربية أولاً
      final arabicLanguages = ['ar-SA', 'ar', 'ar-SA-u-nu-latn', 'ar-SA-u-nu-arab'];
      String? selectedLanguage;

      for (final lang in arabicLanguages) {
        final available = await _flutterTts!.isLanguageAvailable(lang);
        if (available) {
          selectedLanguage = lang;
          break;
        }
      }

      // إذا لم تتوفر اللغة العربية، استخدم الإنجليزية كبديل
      if (selectedLanguage == null) {
        final englishAvailable = await _flutterTts!.isLanguageAvailable('en-US');
        selectedLanguage = englishAvailable ? 'en-US' : null;
      }

      // تعيين اللغة المحددة
      if (selectedLanguage != null) {
        await _flutterTts!.setLanguage(selectedLanguage);
        debugPrint('TTS Language set to: $selectedLanguage');
      }

      // تعيين إعدادات الصوت
      await _flutterTts!.setSpeechRate(0.5);
      await _flutterTts!.setVolume(1.0);
      await _flutterTts!.setPitch(1.0);

    } catch (e) {
      debugPrint('Error initializing TTS: $e');
    }
  }

  /// تحرير الموارد
  /// 
  /// يحرر محركات STT و TTS
  /// 
  /// يتم استدعاء هذه الدالة تلقائياً بعد 5 دقائق من عدم الاستخدام
  void _releaseResources() {
    _speechToText?.cancel();
    _flutterTts = null;
    _isInitialized = false;
    _isListening = false;
    debugPrint('Speech resources released due to inactivity');
  }

  /// بدء الاستماع للإدخال الصوتي
  /// 
  /// [onResult] دالة يتم استدعاؤها عند التعرف على النص النهائي
  /// [onError] دالة يتم استدعاؤها عند حدوث خطأ
  /// 
  /// يستمع لمدة 30 ثانية كحد أقصى
  /// يتوقف تلقائياً بعد 3 ثواني من الصمت
  /// يعيد تعيين idle timer عند الاستخدام
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

    if (_isListening || _speechToText == null) return;

    try {
      await _speechToText!.listen(
        onResult: (result) {
          if (result.finalResult) {
            _resetIdleTimer(); // إعادة تعيين timer عند كل نتيجة
            onResult(result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        localeId: 'ar-SA', // Arabic
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
    if (!_isListening || _speechToText == null) return;
    
    try {
      await _speechToText!.stop();
      _isListening = false;
      _resetIdleTimer(); // إعادة تعيين timer عند الإيقاف
    } catch (e) {
      debugPrint('Error stopping listening: $e');
    }
  }

  /// تحويل النص إلى كلام وقراءته
  /// 
  /// [text] النص المراد قراءته
  /// 
  /// يستخدم اللغة العربية وسرعة قراءة متوسطة
  /// يعيد تعيين idle timer عند الاستخدام
  /// 
  /// مثال:
  /// ```dart
  /// await service.speak('مرحباً بك');
  /// ```
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (_flutterTts == null) return;
    
    try {
      await _flutterTts!.speak(text);
      _resetIdleTimer(); // إعادة تعيين timer عند الاستخدام
    } catch (e) {
      debugPrint('Error speaking: $e');
    }
  }

  /// إيقاف قراءة النص
  /// 
  /// يوقف محرك TTS فوراً
  Future<void> stopSpeaking() async {
    if (_flutterTts == null) return;
    
    try {
      await _flutterTts!.stop();
      _resetIdleTimer(); // إعادة تعيين timer عند الإيقاف
    } catch (e) {
      debugPrint('Error stopping speech: $e');
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
  bool get isAvailable => _speechToText?.isAvailable ?? false;

  /// تعيين سرعة القراءة
  /// 
  /// [rate] سرعة القراءة (0.0 - 1.0)
  Future<void> setSpeechRate(double rate) async {
    if (_flutterTts == null) return;
    
    try {
      await _flutterTts!.setSpeechRate(rate);
      _resetIdleTimer(); // إعادة تعيين timer عند الاستخدام
    } catch (e) {
      debugPrint('Error setting speech rate: $e');
    }
  }

  /// تعيين مستوى الصوت
  /// 
  /// [volume] مستوى الصوت (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    if (_flutterTts == null) return;
    
    try {
      await _flutterTts!.setVolume(volume);
      _resetIdleTimer(); // إعادة تعيين timer عند الاستخدام
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }

  /// تعيين نبرة الصوت
  /// 
  /// [pitch] نبرة الصوت (0.5 - 2.0)
  Future<void> setPitch(double pitch) async {
    if (_flutterTts == null) return;
    
    try {
      await _flutterTts!.setPitch(pitch);
      _resetIdleTimer(); // إعادة تعيين timer عند الاستخدام
    } catch (e) {
      debugPrint('Error setting pitch: $e');
    }
  }

  /// تنظيف الموارد وإيقاف جميع العمليات
  /// 
  /// يجب استدعاؤها عند الانتهاء من استخدام الخدمة
  /// يلغي idle timer ويحرر جميع الموارد
  void dispose() {
    _idleTimer?.cancel();
    _releaseResources();
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
