
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as _dio;
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';
 // Make sure AppConfig.apiUrl is correctly set

class ApiService {
  final String _baseUrl = AppConfig.apiUrl;
  String get baseUrl => _baseUrl;

  static String imageURL = AppConfig.imageUrl; // Using image URL from AppConfig



  Future<Map<String, String>> createAuthorizationHeader() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      print('🔐 Sending token: $token');
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } else {
      print('🚫 No token found!');
      return {
        'Content-Type': 'application/json',
      };
    }
  }

  fetchData(String url) async {
    final headers = await createAuthorizationHeader();

    final response =
    await http.get(Uri.parse(_baseUrl + url), headers: headers);

    // final response = await http.get(Uri.parse(_baseUrl + url));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON.
      return json.decode(response.body);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load data');
    }
  }



  postData(String url, Map<String, dynamic> data) async {
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

  Future<Map<String, dynamic>> putData(
      String url, Map<String, dynamic> data) async {
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
  }

  deleteData(String url) async {
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
  }




  static Future<String?> getFolder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('folder');  // folder stored while login
  }

 /* static Future<String> getImageURL(String image) async {
    String folder = await getFolder() ?? ''; // Now calling the static getFolder
    return imageURL + folder + image; // Combine URL with folder and image
  }
*/

 /* static Future<String> getImageURL(String image) async {
    String folder = await getFolder() ?? '';
    return imageURL + folder + image;
  }

  static String getImageURLSync(String folder, String image) {
    return imageURL + folder + image;
  }*/



  /// ✅ Image URL Builder
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
      Map<String, dynamic> fields,
      File? imageFile,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    Dio dio = Dio();

    // Remove JSON header (important for file upload)
    dio.options.headers = {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    };

    // Create FormData
    FormData formData = FormData.fromMap({
      ...fields,
      if (imageFile != null)
        "photo": await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split("/").last,
        )
    });

    print("📤 FINAL MULTIPART DATA: ${formData.fields}");
    print("📸 SENDING IMAGE: ${imageFile?.path}");

    final response = await dio.post(
      _baseUrl + url,
      data: formData,
    );

    return response.data;
  }





/// Simple GET request



}
