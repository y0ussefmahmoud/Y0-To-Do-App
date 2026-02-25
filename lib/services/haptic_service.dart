import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class HapticService {
  static Future<void> light() async {
    if (!kIsWeb) {
      await HapticFeedback.lightImpact();
    }
  }
  
  static Future<void> medium() async {
    if (!kIsWeb) {
      await HapticFeedback.mediumImpact();
    }
  }
  
  static Future<void> heavy() async {
    if (!kIsWeb) {
      await HapticFeedback.heavyImpact();
    }
  }
  
  static Future<void> selection() async {
    if (!kIsWeb) {
      await HapticFeedback.selectionClick();
    }
  }
  
  static Future<void> success() async {
    if (!kIsWeb) {
      // Try custom vibration pattern for success
      try {
        bool? hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator == true) {
          await Vibration.vibrate(duration: 100, pattern: [0, 50, 50, 50]);
        } else {
          await HapticFeedback.mediumImpact();
        }
      } catch (e) {
        await HapticFeedback.mediumImpact();
      }
    }
  }
  
  static Future<void> error() async {
    if (!kIsWeb) {
      // Try custom vibration pattern for error
      try {
        bool? hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator == true) {
          await Vibration.vibrate(duration: 200, pattern: [0, 100, 100, 100]);
        } else {
          await HapticFeedback.heavyImpact();
        }
      } catch (e) {
        await HapticFeedback.heavyImpact();
      }
    }
  }

  static Future<void> warning() async {
    if (!kIsWeb) {
      // Try custom vibration pattern for warning
      try {
        bool? hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator == true) {
          await Vibration.vibrate(duration: 150, pattern: [0, 75, 75]);
        } else {
          await HapticFeedback.mediumImpact();
        }
      } catch (e) {
        await HapticFeedback.mediumImpact();
      }
    }
  }

  static Future<void> swipeStart() async {
    if (!kIsWeb) {
      await HapticFeedback.selectionClick();
    }
  }

  static Future<void> swipeComplete() async {
    if (!kIsWeb) {
      await HapticFeedback.lightImpact();
    }
  }

  static Future<void> toggle() async {
    if (!kIsWeb) {
      await HapticFeedback.mediumImpact();
    }
  }

  static Future<void> delete() async {
    if (!kIsWeb) {
      await HapticFeedback.heavyImpact();
    }
  }

  static Future<void> buttonPress() async {
    if (!kIsWeb) {
      await HapticFeedback.lightImpact();
    }
  }

  static Future<void> longPress() async {
    if (!kIsWeb) {
      await HapticFeedback.mediumImpact();
    }
  }

  static Future<void> notification() async {
    if (!kIsWeb) {
      // Try custom vibration pattern for notification
      try {
        bool? hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator == true) {
          await Vibration.vibrate(duration: 300, pattern: [0, 100, 50, 100]);
        } else {
          await HapticFeedback.mediumImpact();
        }
      } catch (e) {
        await HapticFeedback.mediumImpact();
      }
    }
  }

  // Check if haptic feedback is available
  static Future<bool> isHapticAvailable() async {
    if (kIsWeb) return false;
    
    try {
      bool? hasVibrator = await Vibration.hasVibrator();
      return hasVibrator ?? true; // Assume available if we can't check
    } catch (e) {
      return true; // Assume available on mobile platforms
    }
  }

  // Enable/disable haptic feedback based on user preference
  static bool _enabled = true;

  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  static bool get isEnabled => _enabled;

  // Safe haptic methods that check if enabled
  static Future<void> safeLight() async {
    if (_enabled) await light();
  }

  static Future<void> safeMedium() async {
    if (_enabled) await medium();
  }

  static Future<void> safeHeavy() async {
    if (_enabled) await heavy();
  }

  static Future<void> safeSelection() async {
    if (_enabled) await selection();
  }

  static Future<void> safeSuccess() async {
    if (_enabled) await success();
  }

  static Future<void> safeError() async {
    if (_enabled) await error();
  }

  static Future<void> safeWarning() async {
    if (_enabled) await warning();
  }

  static Future<void> safeSwipeStart() async {
    if (_enabled) await swipeStart();
  }

  static Future<void> safeSwipeComplete() async {
    if (_enabled) await swipeComplete();
  }

  static Future<void> safeToggle() async {
    if (_enabled) await toggle();
  }

  static Future<void> safeDelete() async {
    if (_enabled) await delete();
  }

  static Future<void> safeButtonPress() async {
    if (_enabled) await buttonPress();
  }

  static Future<void> safeLongPress() async {
    if (_enabled) await longPress();
  }

  static Future<void> safeNotification() async {
    if (_enabled) await notification();
  }
}
