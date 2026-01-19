import 'package:flutter/foundation.dart';
import 'package:easyinventory/models/settings.model.dart';
import 'package:easyinventory/controllers/authentication.controller.dart';

class SettingsController extends ChangeNotifier {
  final AuthController authController;

  final Settings _settings = Settings();

  SettingsController({required this.authController});

  // --- Getters ---
  Settings get settings => _settings;

  String get userEmail => authController.currentUser?.email ?? 'Not signed in';
  String? get userPhotoUrl => authController.currentUser?.photoURL;

  // --- Auth actions ---
  Future<String?> signOut() async {
    try {
      await authController.signOut();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
