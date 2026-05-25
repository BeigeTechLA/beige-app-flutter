import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../storage/secure_token_storage.dart';

/// Detects first launch after a fresh install and wipes any SharedPreferences
/// that survived via OS-level backup/restore (Android Auto Backup, iCloud
/// restore, ADB backup, etc.).
///
/// Strategy: write a sentinel file inside the app support directory, which is
/// excluded from backup on iOS by default and is wiped on app uninstall on
/// both platforms. If the sentinel is missing on launch, treat this as a
/// fresh install — purge SharedPreferences before any auth state is read.
class InstallMarker {
  static const String _fileName = '.beige_install_marker';

  /// Call from `main()` after `SharedPreferences.getInstance()` and before
  /// the first widget builds. Idempotent on subsequent launches.
  static Future<void> ensureFreshInstallCleared() async {
    final dir = await getApplicationSupportDirectory();
    final marker = File('${dir.path}/$_fileName');

    if (await marker.exists()) return;

    // Fresh install: wipe any SharedPreferences restored from OS backup
    // AND any secure-storage token left behind by Keychain (iOS Keychain
    // persists across uninstall by default).
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await SecureTokenStorage.delete();

    await marker.create(recursive: true);
  }
}
