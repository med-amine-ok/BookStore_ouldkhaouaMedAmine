import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _imagePicker = ImagePicker();

  // Upload user avatar only
  Future<String?> uploadUserAvatar(String userId, {XFile? imageFile, Uint8List? imageBytes}) async {
    try {
      final String fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = '$userId/$fileName';

      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        await _supabase.storage.from('user-avatars').uploadBinary(filePath, bytes);
      } else if (imageBytes != null) {
        await _supabase.storage.from('user-avatars').uploadBinary(filePath, imageBytes);
      } else {
        return null;
      }

      final String publicUrl = _supabase.storage.from('user-avatars').getPublicUrl(filePath);
      debugPrint('✅ Avatar uploaded: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('❌ Avatar upload error: $e');
      return null;
    }
  }

  // Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      return await _imagePicker.pickImage(source: ImageSource.gallery);
    } catch (e) {
      debugPrint('❌ Gallery pick error: $e');
      return null;
    }
  }

  // Pick image from camera  
  Future<XFile?> pickImageFromCamera() async {
    try {
      return await _imagePicker.pickImage(source: ImageSource.camera);
    } catch (e) {
      debugPrint('❌ Camera pick error: $e');
      return null;
    }
  }
}