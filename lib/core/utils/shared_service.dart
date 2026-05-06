    import 'package:beige/config/env.dart';
    import 'package:flutter/foundation.dart';
    import 'package:shared_preferences/shared_preferences.dart';

    class SharedService {
      static String imageURL = Env.imageUrl;

      /// Save user login details from API response
      static Future<void> setLoginDetails(Map<String, dynamic> response) async {
        final prefs = await SharedPreferences.getInstance();

        final data = response['data'] ?? {};
        final userData = data['userData'] ?? {};

        // Extract values safely
        final String token = data['token'] ?? '';
        final int environmentId = userData['environment_id'] ?? -1;
        final String folder = userData['folder'] ?? '';
        final String name = userData['name'] ?? '';
        final String designation = userData['designation'] ?? '';
        final String department = userData['department'] ?? '';
        final String departmentId = userData['department_id'] ?? '';

        // Store in SharedPreferences
        await prefs.setString('token', token);
        await prefs.setInt('environment_id', environmentId);
        await prefs.setString('folder', folder);
        await prefs.setString('name', name);
        await prefs.setString('designation', designation);
        await prefs.setString('department', department);
        await prefs.setString('department_id', departmentId);
        await prefs.setBool('isLoggedIn', true);

        debugPrint("✅ Login details saved to SharedPreferences");
      }

      /// Retrieve user data
      static Future<Map<String, dynamic>> getUserData() async {
        final prefs = await SharedPreferences.getInstance();

        String name = prefs.getString('name') ?? '';
        String designation = prefs.getString('designation') ?? '';
        String department = prefs.getString('department') ?? '';
        String departmentId = prefs.getString('department_id') ?? '';
        String token = prefs.getString('token') ?? '';
        int environmentId = prefs.getInt('environment_id') ?? -1;
        String folder = prefs.getString('folder') ?? '';

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

      /// Clear user data on logout
      static Future<void> logout() async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        debugPrint("🗑️ User data cleared from SharedPreferences");
      }

      /// Get stored token
      static Future<String?> getToken() async {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString('token');
      }
    }

