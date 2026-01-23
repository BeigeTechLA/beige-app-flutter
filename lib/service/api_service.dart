
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


  Future<dynamic> postMultipartStep3(
      String url, {
        required Map<String, String> fields,
        File? resume,
        File? portfolio,
        List<File>? certificates,
        List<File>? recentWorks,
        List<int>? recentWorkIndexes,
      }) async {
    final dio = Dio();

    FormData formData = FormData.fromMap(fields);

    /// 📄 Resume
    if (resume != null) {
      formData.files.add(
        MapEntry(
          "resume",
          await MultipartFile.fromFile(
            resume.path,
            filename: resume.path.split('/').last,
          ),
        ),
      );
    }

    /// 📁 Portfolio
    if (portfolio != null) {
      formData.files.add(
        MapEntry(
          "portfolio",
          await MultipartFile.fromFile(
            portfolio.path,
            filename: portfolio.path.split('/').last,
          ),
        ),
      );
    }

    /// 📜 Certification files (MULTIPLE)
    if (certificates != null) {
      for (final file in certificates) {
        formData.files.add(
          MapEntry(
            "certifications",
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
      }
    }

    /// 🎬 Recent Work Media + Index
    if (recentWorks != null && recentWorkIndexes != null) {
      for (int i = 0; i < recentWorks.length; i++) {
        formData.files.add(
          MapEntry(
            "recent_work_media",
            await MultipartFile.fromFile(
              recentWorks[i].path,
              filename: recentWorks[i].path.split('/').last,
            ),
          ),
        );

        formData.fields.add(
          MapEntry(
            "recent_work_media_index",
            recentWorkIndexes[i].toString(),
          ),
        );
      }
    }

    final response = await dio.post(
      url,
      data: formData,
      options: Options(
        headers: {
          "Content-Type": "multipart/form-data",
        },
      ),
    );

    return response.data;
  }



  String  getImageURL(String imagePath) {
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
      "Authorization": "Bearer $token",
    };

    /// ✅ CREATE FORM DATA
    FormData formData = FormData.fromMap({
      ...fields,

      /// ✅ BACKEND EXPECTS: profile_photo
      if (imageFile != null)
        "profile_photo": await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
    });



    final response = await dio.post(
      _baseUrl + url,
      data: formData,
    );

    return response.data;
  }






/// Simple GET request



}
