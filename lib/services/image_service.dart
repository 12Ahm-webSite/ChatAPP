import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  final ImagePicker _picker = ImagePicker();

  // طلب إذن الكاميرا والمعرض
  Future<bool> _requestGalleryPermission() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // اختيار صورة من المعرض
  Future<XFile?> pickImageFromGallery() async {
    try {
      if (!await _requestGalleryPermission()) {
        print('لم يتم منح إذن الوصول للمعرض');
        return null;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1000,
      );
      return image;
    } catch (e) {
      print('خطأ في اختيار الصورة من المعرض: $e');
      return null;
    }
  }

  // التقاط صورة من الكاميرا
  Future<XFile?> pickImageFromCamera() async {
    try {
      if (!await _requestCameraPermission()) {
        print('لم يتم منح إذن الكاميرا');
        return null;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1000,
      );
      return image;
    } catch (e) {
      print('خطأ في التقاط الصورة من الكاميرا: $e');
      return null;
    }
  }

  // اختيار صورة متعددة من المعرض
  Future<List<XFile>> pickMultipleImages() async {
    try {
      if (!await _requestGalleryPermission()) {
        print('لم يتم منح إذن الوصول للمعرض');
        return [];
      }

      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1000,
      );
      return images;
    } catch (e) {
      print('خطأ في اختيار الصور المتعددة: $e');
      return [];
    }
  }

  // ضغط الصورة
  Future<XFile?> compressImage(
    XFile image, {
    int quality = 80,
    int maxWidth = 1000,
  }) async {
    try {
      // في التطبيق الحقيقي يمكن استخدام مكتبة مثل flutter_image_compress
      return image;
    } catch (e) {
      print('خطأ في ضغط الصورة: $e');
      return null;
    }
  }
}
