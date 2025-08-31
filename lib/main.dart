import 'package:easyinventory/authentication/splash.dart';
import 'package:easyinventory/view/dashboard.dart';
import 'package:easyinventory/view/mainScreen.dart';
import 'package:easyinventory/view/suppliers/suppliers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white
      ),
      home: SuppliersPage(),
    );
  }
}