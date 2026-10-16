import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class AppFilePickerService {
  AppFilePickerService._();

  static final ImagePicker _picker = ImagePicker();

  /// ===============================
  /// Pick Gallery Image
  /// ===============================

  static Future<File?> pickGalleryImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (pickedFile == null) {
        return null;
      }

      return File(pickedFile.path);
    } catch (e) {
      return null;
    }
  }

  /// ===============================
  /// Pick Camera Image
  /// ===============================

  static Future<File?> pickCameraImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );

      if (pickedFile == null) {
        return null;
      }

      return File(pickedFile.path);
    } catch (e) {
      return null;
    }
  }

  /// ===============================
  /// Pick Document
  /// ===============================

  static Future<File?> pickDocument() async {
    try {
      final PlatformFile? result = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'ppt',
          'pptx',
          'txt',
        ],
      );

      if (result?.path == null) {
        return null;
      }

      return File(result!.path!);
    } catch (e) {
      return null;
    }
  }

  /// ===============================
  /// Pick Audio File
  /// ===============================

  static Future<File?> pickAudio() async {
    try {
      final PlatformFile? result = await FilePicker.pickFile(
        type: FileType.audio,
      );

      if (result?.path == null) {
        return null;
      }

      return File(result!.path!);
    } catch (e) {
      return null;
    }
  }

  /// ===============================
  /// Pick Video File
  /// ===============================

  static Future<File?> pickVideo() async {
    try {
      final XFile? pickedFile = await _picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) {
        return null;
      }

      return File(pickedFile.path);
    } catch (e) {
      return null;
    }
  }

  /// ===============================
  /// Pick Any File
  /// ===============================

  static Future<File?> pickAnyFile() async {
    try {
      final PlatformFile? result = await FilePicker.pickFile();

      if (result?.path == null) {
        return null;
      }

      return File(result!.path!);
    } catch (e) {
      return null;
    }
  }
}
