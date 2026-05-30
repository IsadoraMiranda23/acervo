import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class UploadService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  // Upload da foto de perfil
  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExtension = imageFile.path.split('.').last;
      final fileName = 'profile_${userId}_$timestamp.$fileExtension';
      final filePath = 'profiles/$fileName';

      print('Iniciando upload para: $filePath');
      print('User ID: $userId');

      // Fazer upload para o storage do Supabase
      final result = await _supabase.storage
          .from('avatars')
          .upload(filePath, imageFile);

      print('Upload concluído! Resultado: $result');

      // Pegar URL pública do arquivo
      final publicUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(filePath);

      print('URL pública: $publicUrl');

      return publicUrl;
    } catch (e) {
      print('Erro detalhado no upload: $e');
      return null;
    }
  }

  // Selecionar imagem da galeria
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Erro ao escolher imagem: $e');
      return null;
    }
  }

  // Tirar foto com a câmera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Erro ao tirar foto: $e');
      return null;
    }
  }
}