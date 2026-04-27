
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/env.dart';

class ApiService {
  final String _baseUrl = Env.apiUrl;
  String get baseUrl => _baseUrl;

  static String imageURL = Env.imageUrl;



  Future<Map<String, String>> createAuthorizationHeader() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } else {
      return {
        'Content-Type': 'application/json',
      };
    }
  }


  fetchData(String url) async {
    final headers = await createAuthorizationHeader();

    try {
      final response = await http
          .get(Uri.parse(_baseUrl + url), headers: headers)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Server Error');
      }

    } on SocketException {
      throw Exception("NO_INTERNET");
    } on TimeoutException {
      throw Exception("TIMEOUT");
    } catch (e) {
      throw Exception("UNKNOWN_ERROR");
    }
  }



  Future<dynamic> postData(String url, Map<String, dynamic> data) async {
    try {
      final headers = await createAuthorizationHeader();

      final response = await http.post(
        Uri.parse(_baseUrl + url),
        headers: headers,
        body: jsonEncode(data),
      );

      final bodyRes = json.decode(response.body);

      debugPrint("STATUS CODE => ${response.statusCode}");
      debugPrint("RESPONSE BODY => $bodyRes");

      // ✅ Success
      if (response.statusCode == 200 || response.statusCode == 201) {
        return bodyRes;
      }

      // 🔴 API error (400, 401 etc.)
      return bodyRes;

    } catch (e) {
      return {
        "error": true,
        "message": "Network error"
      };
    }
  }

  Future<Map<String, dynamic>> putData(
      String url, Map<String, dynamic> data) async {
    try {
      final headers = await createAuthorizationHeader();

      final response = await http.put(
        Uri.parse(_baseUrl + url),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update data');
      }
    } on SocketException {
      throw Exception("NO_INTERNET");
    } on TimeoutException {
      throw Exception("TIMEOUT");
    } catch (e) {
      rethrow;
    }
  }

  deleteData(String url) async {
    try {
      final headers = await createAuthorizationHeader();

      final response = await http.delete(
        Uri.parse(_baseUrl + url),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to delete data');
      }
    } on SocketException {
      throw Exception("NO_INTERNET");
    } on TimeoutException {
      throw Exception("TIMEOUT");
    } catch (e) {
      rethrow;
    }
  }




  static Future<String?> getFolder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('folder');  // folder stored while login
  }

  Future<dynamic> postMultipartData(
      String url,
      Map<String, String> fields,
      File? file,
      ) async {
    try {
      var uri = Uri.parse(baseUrl + url);

      var request = http.MultipartRequest('POST', uri);

      /// Add fields
      request.fields.addAll(fields);

      debugPrint("📦 FIELDS => ${request.fields}");

      /// Add file
      if (file != null) {
        debugPrint("📦 FILE PATH => ${file.path}");
        debugPrint("📦 FILE SIZE => ${await file.length()} bytes");

        request.files.add(
          await http.MultipartFile.fromPath(
            'file', // ⚠️ MUST MATCH BACKEND
            file.path,
          ),
        );
      }

      var response = await request.send();

      debugPrint("🟠 STATUS CODE => ${response.statusCode}");

      var responseBody = await response.stream.bytesToString();

      debugPrint("🟢 RESPONSE BODY => $responseBody");

      return jsonDecode(responseBody);

    } catch (e) {
      debugPrint("🔥 MULTIPART ERROR => $e");
      return null;
    }
  }


  String getImageURL(String imagePath) {
    return imageURL + imagePath;
  }


  postDataraw(String url, Map<String, dynamic> data) async {
    final headers = await createAuthorizationHeader();

    final response = await http.post(
      Uri.parse(_baseUrl + url),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final bodyRes = json.decode(response.body);
      return bodyRes;
    } else {
      throw Exception('Failed to post data');
    }
  }


  /// 📌 WORKING MULTIPART POST
  Future<dynamic> postMultipart(
      String url,
      Map<String, String> fields,
      File? imageFile,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    Dio dio = Dio();

    dio.options.headers = {
      "Accept": "application/json",
      if (token.isNotEmpty) "Authorization": "Bearer $token",
    };

    try {
      FormData formData = FormData.fromMap({
        ...fields,
        if (imageFile != null)
          "file": await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split('/').last,
          ),
      });

      final response = await dio.post(
        _baseUrl + url,
        data: formData,
      );

      return response.data;

    } on DioException catch (e) {
      if (e.response != null) {
        // 🔥 Backend ka actual error return karo
        return e.response?.data;
      } else {
        return {
          "error": true,
          "message": "Something went wrong"
        };
      }
    }
  }




/// Simple GET request



}
