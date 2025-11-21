// lib/models/settings.model.dart
class Settings {
  bool notificationsEnabled;
  String language; // e.g. "EN", "MY"

  Settings({
    this.notificationsEnabled = true,
    this.language = "EN",
  });

  Settings copyWith({
    bool? notificationsEnabled,
    String? language,
  }) {
    return Settings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toMap() => {
        'notificationsEnabled': notificationsEnabled,
        'language': language,
      };

  factory Settings.fromMap(Map<String, dynamic>? map) {
    if (map == null) return Settings();
    return Settings(
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      language: map['language'] as String? ?? "EN",
    );
  }
}
