// lib/controllers/settings.controller.dart
import 'package:flutter/foundation.dart';
import 'package:easyinventory/models/settings.model.dart';
import 'package:easyinventory/controllers/authentication.controller.dart';

/// SettingsController holds settings state and exposes methods the UI calls.
/// It depends on AuthController to handle sign-out and get current user info.
class SettingsController extends ChangeNotifier {
  final AuthController authController;

  Settings _settings = Settings();

  SettingsController({required this.authController});

  // --- state getters ---
  Settings get settings => _settings;
  bool get notificationsEnabled => _settings.notificationsEnabled;
  String get language => _settings.language;

  // --- user info helpers ---
  String get userEmail => authController.currentUser?.email ?? 'Not signed in';
  String? get userPhotoUrl => authController.currentUser?.photoURL;

  // --- mutate state ---
  void toggleNotifications(bool value) {
    _settings = _settings.copyWith(notificationsEnabled: value);
    notifyListeners();
    // TODO: persist to storage (SharedPreferences / Firestore) if needed
  }

  void toggleLanguage() {
    final newLang = (_settings.language == "EN") ? "MY" : "EN";
    _settings = _settings.copyWith(language: newLang);
    notifyListeners();
    // TODO: persist to storage if required
  }

  // --- auth actions ---
  /// Signs out (delegates to AuthController). Returns null on success, error msg otherwise.
  Future<String?> signOut() async {
    try {
      await authController.signOut();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Optionally: load / save settings async from persistence
  Future<void> loadFromMap(Map<String, dynamic>? map) async {
    _settings = Settings.fromMap(map);
    notifyListeners();
  }
}
