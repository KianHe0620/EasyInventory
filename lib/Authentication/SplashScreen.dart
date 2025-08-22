import 'dart:async';

import 'package:easyinventory/authentication/LoginScreen.dart';
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

    );
  }
}