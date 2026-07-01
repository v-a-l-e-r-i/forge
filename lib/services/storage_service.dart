import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadAvatar({
    required String userId,
    required File image,
  }) async {
    final ref = _storage.ref().child(
      'avatars/$userId/avatar.jpg',
    );

    await ref.putFile(image);

    return await ref.getDownloadURL();
  }
}