import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  bool _isInitialized = false;
  bool _isListening = false;

  // تهيئة الخدمة
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

  // بدء الاستماع
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

  // إيقاف الاستماع
  Future<void> stopListening() async {
    if (!_isListening) return;
    
    try {
      await _speechToText.stop();
      _isListening = false;
    } catch (e) {
      print('Error stopping listening: $e');
    }
  }

  // قراءة النص
  Future<void> speak(String text) async {
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      print('Error speaking: $e');
    }
  }

  // إيقاف القراءة
  Future<void> stopSpeaking() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print('Error stopping speech: $e');
    }
  }

  // معالجة الأوامر الصوتية
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

  bool _containsAny(String text, List<String> words) {
    return words.any((word) => text.contains(word));
  }

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

  // الحصول على حالة الاستماع
  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;
  bool get isAvailable => _speechToText.isAvailable;

  // تنظيف الموارد
  void dispose() {
    _speechToText.cancel();
    _flutterTts.stop();
  }
}

// أنواع الأوامر الصوتية
enum VoiceCommandType {
  addTask,
  search,
  showTasks,
  completeTask,
  deleteTask,
  unknown,
}

// نموذج الأمر الصوتي
class VoiceCommand {
  final VoiceCommandType type;
  final Map<String, dynamic> data;

  VoiceCommand({
    required this.type,
    required this.data,
  });
}
