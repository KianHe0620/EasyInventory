import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

final _picker = ImagePicker();

/// Pick image from gallery or camera. returns File or null.
Future<File?> pickImage({bool fromCamera = false}) async {
  final XFile? picked = await _picker.pickImage(
    source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    maxWidth: 1200,
    maxHeight: 1200,
    imageQuality: 80,
  );
  if (picked == null) return null;
  return File(picked.path);
}

/// Upload file to Firebase Storage in path users/{uid}/images/{filename}
/// returns public download URL on success.
Future<String?> uploadImageForCurrentUser(File file) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception('Not signed in');

  final ext = file.path.split('.').last;
  final filename = '${DateTime.now().millisecondsSinceEpoch}.$ext';
  final ref = FirebaseStorage.instance
      .ref()
      .child('users')
      .child(user.uid)
      .child('images')
      .child(filename);

  final task = await ref.putFile(file);
  final url = await ref.getDownloadURL();
  return url;
}
