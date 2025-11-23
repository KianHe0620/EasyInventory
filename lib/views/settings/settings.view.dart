// lib/views/settings/settings.page.dart
import 'package:easyinventory/views/settings/manage_field.view.dart';
import 'package:flutter/material.dart';
import 'package:easyinventory/controllers/settings.controller.dart';
import 'package:easyinventory/views/authentication/login.dart';
import 'package:easyinventory/controllers/item.controller.dart';

class SettingsPage extends StatefulWidget {
  final SettingsController settingsController;
  final ItemController itemController; // <-- Added

  const SettingsPage({
    super.key,
    required this.settingsController,
    required this.itemController, // <-- Added
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = widget.settingsController;
    ctrl.addListener(_onCtrlChanged);
  }

  @override
  void dispose() {
    ctrl.removeListener(_onCtrlChanged);
    super.dispose();
  }

  void _onCtrlChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _confirmSignOut() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sign out')),
        ],
      ),
    );

    if (ok != true) return;

    final err = await ctrl.signOut();
    if (err == null) {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Signed out')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Sign out failed: $err')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = ctrl.userEmail;
    final photoUrl = ctrl.userPhotoUrl;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// Profile Section
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                        ? NetworkImage(photoUrl)
                        : null,
                    child: (photoUrl == null || photoUrl.isEmpty)
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      userEmail,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              /// Sign Out
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: _confirmSignOut,
                child: const Text('Sign Out'),
              ),
              const SizedBox(height: 20),

              /// Manage Fields
              ListTile(
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                title: const Text('Manage Fields'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ManageFieldsPage(
                        itemController: widget.itemController,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              /// Language
              ListTile(
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                title: const Text('Language'),
                trailing: Text(ctrl.language),
                onTap: () => ctrl.toggleLanguage(),
              ),
              const SizedBox(height: 12),

              /// Notification
              ListTile(
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                title: const Text('Notification'),
                trailing: Switch(
                  value: ctrl.notificationsEnabled,
                  onChanged: (v) => ctrl.toggleNotifications(v),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
