import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage for the auth token.
///
/// - iOS: Keychain with `first_unlock_this_device` accessibility — item is
///   bound to this device (no iCloud Keychain sync) and only readable after
///   the user has unlocked the device at least once since boot.
/// - Android: `EncryptedSharedPreferences` (AES-256 GCM, keys in Android
///   Keystore). Keystore keys are not backed up, so even if the encrypted
///   prefs file were restored on reinstall, the decryption key would be
///   gone. Backup is also disabled at the app level via AndroidManifest
///   `allowBackup=false` + `fullBackupContent=false`.
class SecureTokenStorage {
  static const _tokenKey = 'auth_token';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static Future<String?> read() => _storage.read(key: _tokenKey);

  static Future<void> write(String token) =>
      _storage.write(key: _tokenKey, value: token);

  static Future<void> delete() => _storage.delete(key: _tokenKey);
}
