import 'package:easyinventory/controllers/authentication.controller.dart';
import 'package:easyinventory/controllers/item.controller.dart';
import 'package:easyinventory/controllers/report.controller.dart';
import 'package:easyinventory/controllers/sell.controller.dart';
import 'package:easyinventory/controllers/settings.controller.dart';
import 'package:easyinventory/controllers/smart_report.controller.dart';
import 'package:easyinventory/controllers/supplier.controller.dart';
import 'package:easyinventory/views/authentication/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔹 Register controllers (Dependency Injection)
  Get.put(AuthController());
  Get.put(ItemController());
  Get.put(
    SellController(
      itemController: Get.find()
      )
    );
  Get.put(SupplierController());
  Get.put(
    SettingsController(
      authController: Get.find()
      )
    );
  Get.put(
    ReportController(
      itemController: Get.find(),
      sellController: Get.find(),
    ),
  );
  Get.put(
    SmartReportController(
      itemController: Get.find(), 
      sellController: Get.find()
    )
  );

    
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,

        // ✅ Set primary color (controls dropdown, radio, switch)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A84D0), // your blue
          primary: const Color(0xFF0A84D0),
        ),

        // Optional fine-tuning
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.all(
            const Color(0xFF0A84D0),
          ),
          trackColor: MaterialStateProperty.all(
            const Color(0x330A84D0),
          ),
        ),

        radioTheme: RadioThemeData(
          fillColor: MaterialStateProperty.all(
            const Color(0xFF0A84D0),
          ),
        ),

        dropdownMenuTheme: DropdownMenuThemeData(
          inputDecorationTheme: const InputDecorationTheme(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Color(0xFF0A84D0),
              ),
            ),
          ),
        ),
      ),
      home: LoginScreen(),
    );
  }
}