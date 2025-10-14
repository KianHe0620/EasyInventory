import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  String language = "EN";
  final String userEmail = "abcd@gmail.com"; // later from Firebase Auth

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 👤 Profile row
              Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      userEmail,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 🚪 Sign out
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  // TODO: integrate FirebaseAuth.instance.signOut()
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Signed out")),
                  );
                },
                child: const Text("Sign Out"),
              ),
              const SizedBox(height: 20),

              // ⚙️ Manage Fields
              ListTile(
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                title: const Text("Manage Fields"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to manage fields page
                },
              ),
              const SizedBox(height: 12),

              // 🌍 Language
              ListTile(
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                title: const Text("Language"),
                trailing: Text(language),
                onTap: () {
                  setState(() {
                    language = (language == "EN") ? "MY" : "EN";
                  });
                },
              ),
              const SizedBox(height: 12),

              // 🔔 Notification
              ListTile(
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                title: const Text("Notification"),
                trailing: Switch(
                  value: notificationsEnabled,
                  onChanged: (val) {
                    setState(() => notificationsEnabled = val);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
