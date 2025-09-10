import 'dart:async';

import 'package:easyinventory/views/authentication/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(seconds: 2), (){
      Get.to(LoginScreen());
      });
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text("Logo"),
      ),

    );
  }
}