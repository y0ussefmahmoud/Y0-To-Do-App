import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/ai_provider.dart';
import '../services/speech_service.dart';

class VoiceInputButton extends ConsumerStatefulWidget {
  final Function(String)? onTextReceived;
  final Function(VoiceCommand)? onCommandReceived;
  final String? tooltip;
  final bool isCompact;

  const VoiceInputButton({
    super.key,
    this.onTextReceived,
    this.onCommandReceived,
    this.tooltip,
    this.isCompact = false,
  });

  @override
  ConsumerState<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends ConsumerState<VoiceInputButton> {
  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceProvider);
    final voiceNotifier = ref.read(voiceProvider.notifier);

    return GestureDetector(
      onTap: () => _handleVoiceInput(voiceNotifier),
      child: Container(
        width: widget.isCompact ? 40 : 56,
        height: widget.isCompact ? 40 : 56,
        decoration: BoxDecoration(
          color: voiceState.isListening 
              ? Colors.red.withOpacity(0.9)
              : Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(widget.isCompact ? 20 : 28),
          boxShadow: [
            BoxShadow(
              color: (voiceState.isListening ? Colors.red : Theme.of(context).primaryColor)
                  .withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          voiceState.isListening ? Icons.mic : Icons.mic_none,
          color: Colors.white,
          size: widget.isCompact ? 20 : 24,
        ),
      ).animate(target: voiceState.isListening ? 1 : 0)
        .scale(duration: 200.ms)
        .then()
        .shimmer(
          duration: 1000.ms,
          color: Colors.white.withOpacity(0.5),
        ),
    );
  }

  Future<void> _handleVoiceInput(VoiceNotifier voiceNotifier) async {
    final voiceState = ref.read(voiceProvider);
    
    if (voiceState.isListening) {
      await voiceNotifier.stopListening();
      return;
    }

    // إظهار dialog للتعليمات
    _showVoiceDialog();

    await voiceNotifier.startListening(
      onResult: (text) {
        Navigator.of(context).pop(); // إغلاق الـ dialog
        _handleVoiceResult(text, voiceNotifier);
      },
    );
  }

  void _showVoiceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.mic, color: Colors.red),
            SizedBox(width: 8),
            Text('الاستماع...'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('تحدث الآن...'),
            const SizedBox(height: 8),
            Text(
              'أمثلة:\n• "أضف مهمة اجتماع غداً"\n• "ابحث عن مهام العمل"',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(voiceProvider.notifier).stopListening();
              Navigator.of(context).pop();
            },
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  void _handleVoiceResult(String text, VoiceNotifier voiceNotifier) {
    if (text.isEmpty) return;

    // معالجة الأمر الصوتي
    final command = voiceNotifier.processCommand(text);
    
    // إظهار النتيجة
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم التعرف على: "$text"'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // تنفيذ الأمر
    if (widget.onCommandReceived != null) {
      widget.onCommandReceived!(command);
    } else if (widget.onTextReceived != null) {
      widget.onTextReceived!(text);
    }

    // قراءة تأكيد الأمر
    _speakConfirmation(command);
  }

  void _speakConfirmation(VoiceCommand command) {
    String confirmation = '';
    
    switch (command.type) {
      case VoiceCommandType.addTask:
        confirmation = 'تم إضافة المهمة';
        break;
      case VoiceCommandType.search:
        confirmation = 'جاري البحث';
        break;
      case VoiceCommandType.showTasks:
        confirmation = 'عرض المهام';
        break;
      case VoiceCommandType.completeTask:
        confirmation = 'تم إكمال المهمة';
        break;
      case VoiceCommandType.deleteTask:
        confirmation = 'تم حذف المهمة';
        break;
      default:
        confirmation = 'لم أفهم الأمر';
    }

    ref.read(voiceProvider.notifier).speak(confirmation);
  }
}

// Compact version for use in text fields
class CompactVoiceButton extends ConsumerWidget {
  final Function(String) onTextReceived;
  final String? tooltip;

  const CompactVoiceButton({
    super.key,
    required this.onTextReceived,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Tooltip(
      message: tooltip ?? 'إدخال صوتي',
      child: VoiceInputButton(
        isCompact: true,
        onTextReceived: onTextReceived,
      ),
    );
  }
}
