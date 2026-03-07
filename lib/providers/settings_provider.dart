import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/app_settings.dart';
import '../providers/ai_provider.dart';

// Provider for the Hive box containing settings
final settingsBoxProvider = Provider<Box<AppSettings>>((ref) {
  throw UnimplementedError('settingsBoxProvider must be overridden in main.dart');
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final Box<AppSettings> _box;
  final Ref _ref;

  SettingsNotifier(this._box, this._ref) : super(_getInitialSettings(_box));

  static AppSettings _getInitialSettings(Box<AppSettings> box) {
    if (box.isNotEmpty) {
      return box.getAt(0) ?? const AppSettings();
    }
    return const AppSettings();
  }

  Future<void> updateThemeMode(String mode) async {
    state = state.copyWith(themeMode: mode);
    await _saveSettings();
  }

  Future<void> updateLanguage(String lang) async {
    state = state.copyWith(language: lang);
    await _saveSettings();
  }

  Future<void> toggleNotifications(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _saveSettings();
  }

  Future<void> toggleSound(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    await _saveSettings();
  }

  Future<void> updateSpeechRate(double rate) async {
    state = state.copyWith(speechRate: rate);
    await _saveSettings();
    
    // Apply to SpeechService if available
    try {
      final speechService = _ref.read(speechServiceProvider);
      await speechService.setSpeechRate(rate);
    } catch (e) {
      // SpeechService might not be available, handle gracefully
    }
  }

  Future<void> updateSpeechVolume(double volume) async {
    state = state.copyWith(speechVolume: volume);
    await _saveSettings();
    
    // Apply to SpeechService if available
    try {
      final speechService = _ref.read(speechServiceProvider);
      await speechService.setVolume(volume);
    } catch (e) {
      // SpeechService might not be available, handle gracefully
    }
  }

  Future<void> updateSpeechPitch(double pitch) async {
    state = state.copyWith(speechPitch: pitch);
    await _saveSettings();
    
    // Apply to SpeechService if available
    try {
      final speechService = _ref.read(speechServiceProvider);
      await speechService.setPitch(pitch);
    } catch (e) {
      // SpeechService might not be available, handle gracefully
    }
  }

  Future<void> updateNotificationMinutesBefore(int minutes) async {
    state = state.copyWith(notificationMinutesBefore: minutes);
    await _saveSettings();
  }

  Future<void> toggleExactTimeNotifications(bool enabled) async {
    state = state.copyWith(exactTimeNotificationsEnabled: enabled);
    await _saveSettings();
  }

  Future<void> resetToDefaults() async {
    state = const AppSettings();
    await _saveSettings();
    
    // Apply defaults to SpeechService if available
    try {
      final speechService = _ref.read(speechServiceProvider);
      await speechService.setSpeechRate(state.speechRate);
      await speechService.setVolume(state.speechVolume);
      await speechService.setPitch(state.speechPitch);
    } catch (e) {
      // SpeechService might not be available, handle gracefully
    }
  }

  Future<void> _saveSettings() async {
    try {
      if (_box.isEmpty) {
        await _box.add(state);
      } else {
        await _box.putAt(0, state);
      }
    } catch (e) {
      // Handle save error
    }
  }
}

// Provider for settings state
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final box = ref.watch(settingsBoxProvider);
  return SettingsNotifier(box, ref);
});

// Provider to convert string theme mode to ThemeMode enum
final themeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(settingsProvider);
  switch (settings.themeMode) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
    default:
      return ThemeMode.system;
  }
});
