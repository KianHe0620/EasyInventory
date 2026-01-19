import 'package:easyinventory/views/settings/manage_field.view.dart';
import 'package:flutter/material.dart';
import 'package:easyinventory/controllers/settings.controller.dart';
import 'package:easyinventory/views/authentication/login.dart';
import 'package:easyinventory/controllers/item.controller.dart';
import 'package:get/get.dart';

class SettingsPage extends StatefulWidget {

   SettingsPage({super.key,});

  final SettingsController settingsController = Get.find<SettingsController>();
  final ItemController itemController = Get.find<ItemController>(); 

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
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel',style: TextStyle(color: Colors.black),),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A84D0),
                foregroundColor: Colors.white,
              ),
            child: const Text('Sign out',style: TextStyle(color: Colors.white),)
          ),
        ],
      ),
    );

    if (ok != true) return;

    final err = await ctrl.signOut();
    if (err == null) {
      if (!mounted) return;
      Get.offAll(() => const LoginScreen());
      Get.snackbar('Success', 'Signed out');
    } else {
      Get.snackbar('Failed', 'Sign out failed: $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = ctrl.userEmail;
    final photoUrl = ctrl.userPhotoUrl;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Section
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
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Sign Out Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFF0A84D0),
                ),
                onPressed: _confirmSignOut,
                child: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),

              // Manage Fields
              ListTile(
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                title: const Text('Manage Fields'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Get.to(() => ManageFieldsPage(),);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
