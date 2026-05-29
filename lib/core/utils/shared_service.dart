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
    final userData = data['user'] ?? {};

    final String token = data['token'] ?? '';
    final int environmentId = userData['environment_id'] ?? -1;
    final String folder = userData['folder'] ?? '';
    final String name = userData['name'] ?? '';
    final String email = userData['email'] ?? '';
    final String profileImageUrl =
        userData['profile_image_url'] ?? '';
    final String designation = userData['designation'] ?? '';
    final String department = userData['department'] ?? '';
    final String departmentId = userData['department_id'] ?? '';

    await SecureTokenStorage.write(token);
    await prefs.setInt('environment_id', environmentId);
    await prefs.setString('folder', folder);
    await prefs.setString('name', name);

    await prefs.setString('email', email);
    await prefs.setString('profile_image_url', profileImageUrl);
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
    final String email = prefs.getString('email') ?? '';
    final String profileImageUrl =
        prefs.getString('profile_image_url') ?? '';


    debugPrint("========== USER DATA ==========");
    debugPrint("NAME  => $name");
    debugPrint("EMAIL => $email");
    debugPrint("IMAGE => $profileImageUrl");
    debugPrint("================================");
    return {
      'name': name,
      'nameInitial':
          name.isNotEmpty ? name.trim().substring(0, 1).toUpperCase() : '',
      'email': email,
      'profile_image_url': profileImageUrl,
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

 //// SharedPreferences
  static Future<void> updateUserData({
    String? name,
    String? email,
    String? profileImageUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (name != null) {
      await prefs.setString('name', name);
    }

    if (email != null) {
      await prefs.setString('email', email);
    }

    if (profileImageUrl != null) {
      await prefs.setString('profile_image_url', profileImageUrl);
    }
  }

}
