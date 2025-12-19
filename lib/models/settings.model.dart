class Settings {
  final bool notificationsEnabled;
  final bool notificationsRequested; // track if permission was requested

  Settings({
    this.notificationsEnabled = false,
    this.notificationsRequested = false,
  });

  Settings copyWith({
    bool? notificationsEnabled,
    bool? notificationsRequested,
  }) {
    return Settings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationsRequested: notificationsRequested ?? this.notificationsRequested,
    );
  }

  factory Settings.fromMap(Map<String, dynamic>? map) {
    if (map == null) return Settings();
    return Settings(
      notificationsEnabled: map['notificationsEnabled'] ?? false,
      notificationsRequested: map['notificationsRequested'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'notificationsRequested': notificationsRequested,
    };
  }
}
