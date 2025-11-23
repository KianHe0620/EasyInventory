import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

final ImagePicker _picker = ImagePicker();

/// Pick image then crop it. If cropping fails, returns the original picked path.
/// Returns null if user cancelled or picking failed.
Future<String?> pickAndCropImage({required ImageSource source}) async {
  final XFile? picked = await _picker.pickImage(
    source: source,
    maxWidth: 3000,
    maxHeight: 3000,
    imageQuality: 90,
  );
  if (picked == null) return null;

  try {
    final CroppedFile? cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop image',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop image',
          aspectRatioLockEnabled: true,
        ),
      ],
      maxWidth: 1024,
      maxHeight: 1024,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 90,
    );

    if (cropped == null) {
      // user cancelled cropping -> return picked file
      return picked.path;
    }
    return cropped.path;
  } catch (e, st) {
    // Log the error (console). This prevents crash and returns fallback.
    debugPrint('Image crop failed: $e\n$st');
    // return picked image as fallback to avoid crashing the app
    return picked.path;
  }
}
