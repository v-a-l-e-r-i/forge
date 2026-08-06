import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const int maxAvatarBytes = 5 * 1024 * 1024; // 5 MB
  static const String _bucket = 'avatars';

  Future<String> uploadAvatar({
    required String userId,
    required XFile image,
  }) async {
    final sizeBytes = await image.length();
    if (sizeBytes > maxAvatarBytes) {
      throw ArgumentError('Файл завеликий (максимум 5 МБ).');
    }

    final name = image.name;
    final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
    
    if (!['jpg', 'jpeg', 'png'].contains(ext)) {
      // Якщо розширення не вдалося визначити з імені, пробуємо з MIME-типу
      final mime = image.mimeType;
      if (mime == 'image/png' || mime == 'image/jpeg') {
        // ok
      } else {
        throw ArgumentError('Дозволені формати: jpg, jpeg, png. Отримано: $ext ($name)');
      }
    }

    final effectiveExt = ext.isNotEmpty ? ext : (image.mimeType == 'image/png' ? 'png' : 'jpg');
    final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.$effectiveExt';
    final path = 'avatars/$userId/$fileName';

    try {
      // Конвертуємо в байти для крос-платформної сумісності
      final bytes = await image.readAsBytes();

      await _supabase.storage.from(_bucket).uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(
          contentType: effectiveExt == 'png' ? 'image/png' : 'image/jpeg',
          upsert: false,
        ),
      );

      return _supabase.storage.from(_bucket).getPublicUrl(path);
    } on StorageException catch (e) {
      throw Exception('Не вдалося завантажити аватар: ${e.message}');
    }

  }

  Future<String> uploadAvatarBytes({
    required String userId,
    required Uint8List bytes,
    required String ext,
  }) async {
    if (bytes.length > maxAvatarBytes) {
      throw ArgumentError('Файл завеликий (максимум 5 МБ).');
    }
    final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.$ext';
    final path = 'avatars/$userId/$fileName';
    await _supabase.storage.from(_bucket).uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(
        contentType: ext == 'png' ? 'image/png' : 'image/jpeg',
        upsert: false,
      ),
    );
    return _supabase.storage.from(_bucket).getPublicUrl(path);
  }
}