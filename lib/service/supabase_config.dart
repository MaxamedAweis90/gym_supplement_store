import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class SupabaseConfig {
  // Replace these with your actual Supabase credentials
  static const String supabaseUrl = 'https://rokozthjllfouacooeul.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJva296dGhqbGxmb3VhY29vZXVsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA0MjczNjIsImV4cCI6MjA2NjAwMzM2Mn0.lkbY8Erj3cO3X0i_GhFmOED-WiptA3OB5z2UcKIanMI';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  // Upload image to Supabase Storage
  static Future<String?> uploadImage({
    required File imageFile,
    required String bucketName,
    String? fileName,
  }) async {
    try {
      final finalFileName =
          fileName ??
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';

      final response = await client.storage
          .from(bucketName)
          .upload(finalFileName, imageFile);

      if (response.isNotEmpty) {
        final imageUrl = client.storage
            .from(bucketName)
            .getPublicUrl(finalFileName);

        return imageUrl;
      }
      return null;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Delete image from Supabase Storage
  static Future<bool> deleteImage({
    required String imageUrl,
    required String bucketName,
  }) async {
    try {
      final fileName = imageUrl.split('/').last;

      await client.storage.from(bucketName).remove([fileName]);

      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  // Pick image from gallery
  static Future<File?> pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  // Take photo with camera
  static Future<File?> takePhotoWithCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error taking photo: $e');
      return null;
    }
  }

  // Pick file (for any type of file)
  static Future<File?> pickFile({List<String>? allowedExtensions}) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions ?? ['jpg', 'jpeg', 'png', 'webp'],
      );

      if (result != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      print('Error picking file: $e');
      return null;
    }
  }

  // Get image URL with transformations
  static String getImageUrl({
    required String imagePath,
    int? width,
    int? height,
    String? format,
  }) {
    String url = client.storage.from('product-images').getPublicUrl(imagePath);

    // Add transformations if specified
    if (width != null || height != null || format != null) {
      final transformations = <String>[];

      if (width != null) transformations.add('width=$width');
      if (height != null) transformations.add('height=$height');
      if (format != null) transformations.add('format=$format');

      if (transformations.isNotEmpty) {
        url += '?${transformations.join('&')}';
      }
    }

    return url;
  }
}
