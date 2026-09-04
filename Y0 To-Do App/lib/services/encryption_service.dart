// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

/// خدمة التشفير — Encryption Service
///
/// تدير مفتاح AES-256 المستخدم لتشفير صناديق Hive.
/// المفتاح يُوّلَد عشوائياً عند أول تشغيل ويُخزَّن بأمان في:
///   - Android Keystore (عبر flutter_secure_storage)
///   - iOS Keychain (عبر flutter_secure_storage)
///
/// الاستخدام:
/// ```dart
/// final cipher = await EncryptionService.getCipher();
/// final box = await Hive.openBox<Task>('tasksBox', encryptionCipher: cipher);
/// ```
class EncryptionService {
  static const _keyStorageKey = 'y0_hive_aes_key_v1';

  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// الحصول على HiveAesCipher المستخدم لفتح صناديق Hive المشفرة.
  ///
  /// يُنشئ مفتاحاً عشوائياً عند أول استدعاء ويحفظه بأمان.
  /// في الاستدعاءات اللاحقة يُعيد المفتاح المحفوظ.
  static Future<HiveAesCipher> getCipher() async {
    try {
      String? storedKey = await _secureStorage.read(key: _keyStorageKey);

      if (storedKey == null) {
        // توليد مفتاح AES-256 عشوائي (32 بايت = 256 بت)
        final key = _generateSecureKey();
        storedKey = base64UrlEncode(key);
        await _secureStorage.write(key: _keyStorageKey, value: storedKey);
        debugPrint('EncryptionService: New AES-256 key generated and stored.');
      } else {
        debugPrint('EncryptionService: Existing AES-256 key loaded.');
      }

      final keyBytes = base64Url.decode(storedKey);
      return HiveAesCipher(keyBytes);
    } catch (e) {
      debugPrint('EncryptionService: Error accessing secure storage: $e');
      rethrow;
    }
  }

  /// التحقق مما إذا كان المفتاح موجوداً بالفعل في التخزين الآمن.
  static Future<bool> hasStoredKey() async {
    try {
      final key = await _secureStorage.read(key: _keyStorageKey);
      return key != null;
    } catch (e) {
      return false;
    }
  }

  /// توليد مفتاح AES آمن عشوائياً بطول 32 بايت (256 بت).
  static List<int> _generateSecureKey() {
    final random = Random.secure();
    return List<int>.generate(32, (_) => random.nextInt(256));
  }
}
