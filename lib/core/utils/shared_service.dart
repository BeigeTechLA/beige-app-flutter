import 'package:beige/config/env.dart';
import 'package:beige/core/storage/secure_token_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedService {
  static String imageURL = Env.imageUrl;

  /// Save user login details from API response.
  /// Token goes to secure storage; non-sensitive fields to SharedPreferences.
  static Future<void> setLoginDetails(Map<String, dynamic> response) async {
    final prefs = await SharedPreferences.getInstance();

    final data = response['data'] ?? {};
    final userData = data['userData'] ?? {};

    final String token = data['token'] ?? '';
    final int environmentId = userData['environment_id'] ?? -1;
    final String folder = userData['folder'] ?? '';
    final String name = userData['name'] ?? '';
    final String designation = userData['designation'] ?? '';
    final String department = userData['department'] ?? '';
    final String departmentId = userData['department_id'] ?? '';

    await SecureTokenStorage.write(token);
    await prefs.setInt('environment_id', environmentId);
    await prefs.setString('folder', folder);
    await prefs.setString('name', name);
    await prefs.setString('designation', designation);
    await prefs.setString('department', department);
    await prefs.setString('department_id', departmentId);
    await prefs.setBool('isLoggedIn', true);

    debugPrint("✅ Login details saved");
  }

  /// Retrieve user data (token sourced from secure storage).
  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final String name = prefs.getString('name') ?? '';
    final String designation = prefs.getString('designation') ?? '';
    final String department = prefs.getString('department') ?? '';
    final String departmentId = prefs.getString('department_id') ?? '';
    final String token = await SecureTokenStorage.read() ?? '';
    final int environmentId = prefs.getInt('environment_id') ?? -1;
    final String folder = prefs.getString('folder') ?? '';

    return {
      'name': name,
      'nameInitial':
          name.isNotEmpty ? name.trim().substring(0, 1).toUpperCase() : '',
      'designation': designation,
      'department': department,
      'departmentId': departmentId,
      'token': token,
      'environmentId': environmentId,
      'folder': folder,
    };
  }

  /// Clear all user data on logout — both SharedPreferences and secure storage.
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await SecureTokenStorage.delete();
    debugPrint("🗑️ User data cleared");
  }

  /// Get stored token.
  static Future<String?> getToken() => SecureTokenStorage.read();
}
