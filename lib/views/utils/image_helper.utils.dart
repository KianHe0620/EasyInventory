import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Pick an image from camera or gallery. Returns the local file path or null.
  static Future<String?> pickImageLocalPath(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
    );
    if (picked == null) return null;
    return picked.path;
  }

  /// Upload a file to Firebase Storage under user folder and return download URL.
  /// `userId` should be current user's uid.
  static Future<String?> uploadToFirebase(String localPath, {required String userId}) async {
    try {
      final file = File(localPath);
      final filename = p.basename(localPath);
      final ref = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(userId)
          .child('item_images')
          .child('${DateTime.now().millisecondsSinceEpoch}_$filename');

      final task = await ref.putFile(file);
      final url = await task.ref.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('uploadToFirebase error: $e');
      return null;
    }
  }
}
