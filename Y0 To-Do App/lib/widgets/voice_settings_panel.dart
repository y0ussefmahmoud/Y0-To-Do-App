import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import 'settings_section.dart';

class VoiceSettingsPanel extends StatelessWidget {
  final AppSettings settings;
  final Function(double) onSpeechRateChanged;
  final Function(double) onSpeechVolumeChanged;
  final Function(double) onSpeechPitchChanged;
  final Function(bool) onSoundToggle;

  const VoiceSettingsPanel({
    super.key,
    required this.settings,
    required this.onSpeechRateChanged,
    required this.onSpeechVolumeChanged,
    required this.onSpeechPitchChanged,
    required this.onSoundToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Column(
        children: [
          const SettingsSection(
            title: 'الإعدادات الصوتية',
            icon: Icons.record_voice_over,
          ),
          
          // Sound Toggle
          SwitchListTile(
            secondary: Icon(
              settings.soundEnabled 
                  ? Icons.volume_up 
                  : Icons.volume_off,
              color: theme.colorScheme.primary,
            ),
            title: const Text('تفعيل الأصوات'),
            subtitle: const Text('تشغيل الأصوات والقراءة الصوتية'),
            value: settings.soundEnabled,
            onChanged: onSoundToggle,
          ),
          
          if (settings.soundEnabled) ...[
            // Speech Rate Slider
            ListTile(
              leading: Icon(
                Icons.speed,
                color: theme.colorScheme.primary,
              ),
              title: const Text('سرعة القراءة'),
              subtitle: Text('${(settings.speechRate * 100).toInt()}%'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () => _testSpeech(context, 'test rate'),
                    tooltip: 'تجربة',
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => onSpeechRateChanged(0.5),
                    tooltip: 'إعادة تعيين',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Slider(
                value: settings.speechRate,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                activeColor: theme.colorScheme.primary,
                onChanged: onSpeechRateChanged,
              ),
            ),
            
            // Speech Volume Slider
            ListTile(
              leading: Icon(
                _getVolumeIcon(settings.speechVolume),
                color: theme.colorScheme.primary,
              ),
              title: const Text('مستوى الصوت'),
              subtitle: Text('${(settings.speechVolume * 100).toInt()}%'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () => _testSpeech(context, 'test volume'),
                    tooltip: 'تجربة',
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => onSpeechVolumeChanged(0.8),
                    tooltip: 'إعادة تعيين',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Slider(
                value: settings.speechVolume,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                activeColor: theme.colorScheme.primary,
                onChanged: onSpeechVolumeChanged,
              ),
            ),
            
            // Speech Pitch Slider
            ListTile(
              leading: Icon(
                Icons.graphic_eq,
                color: theme.colorScheme.primary,
              ),
              title: const Text('نبرة الصوت'),
              subtitle: Text(settings.speechPitch.toStringAsFixed(1)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () => _testSpeech(context, 'test pitch'),
                    tooltip: 'تجربة',
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => onSpeechPitchChanged(1.0),
                    tooltip: 'إعادة تعيين',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Slider(
                value: settings.speechPitch,
                min: 0.5,
                max: 2.0,
                divisions: 15,
                activeColor: theme.colorScheme.primary,
                onChanged: onSpeechPitchChanged,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getVolumeIcon(double volume) {
    if (volume == 0.0) {
      return Icons.volume_off;
    } else if (volume < 0.5) {
      return Icons.volume_down;
    } else {
      return Icons.volume_up;
    }
  }

  void _testSpeech(BuildContext context, String testType) {
    try {
      // This would use the SpeechService to test speech
      // For now, we'll just show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تجربة $testType'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تشغيل الصوت: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}
