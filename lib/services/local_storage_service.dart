import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // حفظ صورة محلياً
  static Future<String?> saveImage(XFile image) async {
    try {
      final localPath = await _localPath;
      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File localImage = File('$localPath/$fileName');

      await localImage.writeAsBytes(await image.readAsBytes());
      return localImage.path;
    } catch (e) {
      print('خطأ في حفظ الصورة: $e');
      return null;
    }
  }

  // حفظ صوت محلياً
  static Future<String?> saveAudio(String audioPath) async {
    try {
      final localPath = await _localPath;
      final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final File localAudio = File('$localPath/$fileName');

      await File(audioPath).copy(localAudio.path);
      return localAudio.path;
    } catch (e) {
      print('خطأ في حفظ الصوت: $e');
      return null;
    }
  }

  // التحقق من وجود الملف
  static bool fileExists(String path) {
    return File(path).existsSync();
  }

  // حذف ملف
  static Future<bool> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('خطأ في حذف الملف: $e');
      return false;
    }
  }

  // الحصول على حجم الملف
  static Future<int> getFileSize(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      print('خطأ في الحصول على حجم الملف: $e');
      return 0;
    }
  }

  // تنظيف الملفات المؤقتة
  static Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();

      for (var file in files) {
        if (file is File) {
          final age = DateTime.now().difference(file.statSync().modified);
          if (age.inDays > 1) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      print('خطأ في تنظيف الملفات المؤقتة: $e');
    }
  }
}
